/************************************************************************/
/*                                                                      */
/*	LangIdent: long n-gram-based language identification		*/
/*	by Ralf Brown / Carnegie Mellon University			*/
/*									*/
/*  File:     utf8hist.C  show histogram of char ranges in UTF8 file	*/
/*  Version:  2.00							*/
/*  LastEdit: 31mar2010 						*/
/*                                                                      */
/*  (c) Copyright 2012,2014,2020 Ralf Brown/Carnegie Mellon University	*/
/*      This program is free software; you can redistribute it and/or   */
/*      modify it under the terms of the GNU General Public License as  */
/*      published by the Free Software Foundation, version 3.           */
/*                                                                      */
/*      This program is distributed in the hope that it will be         */
/*      useful, but WITHOUT ANY WARRANTY; without even the implied      */
/*      warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR         */
/*      PURPOSE.  See the GNU General Public License for more details.  */
/*                                                                      */
/*      You should have received a copy of the GNU General Public       */
/*      License (file COPYING) along with this program.  If not, see    */
/*      http://www.gnu.org/licenses/                                    */
/*                                                                      */
/************************************************************************/

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>

/************************************************************************/
/*	Manifest Constants						*/
/************************************************************************/

// granularity of histogram
#define PAGE_SIZE 128
#define PAGE_COUNT 1024

// granularity in bytes of ranges for script merging
#define MERGE_SIZE 16

/************************************************************************/
/*	Helpers								*/
/************************************************************************/

#ifndef lengthof
# define lengthof(x) (sizeof(x)/sizeof(x[0]))
#endif

/************************************************************************/
/*	Types								*/
/************************************************************************/

struct ScriptRange {
   const char* name ;
   size_t start ;
   size_t end ;
   } ;

/************************************************************************/
/*	Data								*/
/************************************************************************/

static const ScriptRange script_names[] = {
   { "latn", 0x0000, 0x0001 },
   { "punc", 0x0009, 0x000B },
   { "punc", 0x0020, 0x0030 },
   { "alnum",0x0030, 0x0040 },
   { "latn", 0x0041, 0x0250 },
   { "IPA ", 0x0250, 0x02B0 },
   { "spac", 0x02B0, 0x0300 },
   { "diacr",0x0300, 0x0370 },
   { "grek", 0x0370, 0x0400 },
   { "cyrl", 0x0400, 0x0530 },
   { "armn", 0x0530, 0x0590 },
   { "hebr", 0x0590, 0x0600 },
   { "arab", 0x0600, 0x0700 },
   { "syrc", 0x0700, 0x0750 },
   { "arab", 0x0750, 0x0780 },
   { "thaa", 0x0780, 0x07C0 },
   { "nkoo", 0x07C0, 0x0800 },
   { "samr", 0x0800, 0x0840 },
   { "mand", 0x0840, 0x0860 },
   { "syrc", 0x0860, 0x0870 },
   { "arab", 0x08A0, 0x0900 },
   { "deva", 0x0900, 0x0980 },
   { "beng", 0x0980, 0x0A00 },
   { "guru", 0x0A00, 0x0A80 },
   { "gujr", 0x0A80, 0x0B00 },
   { "orya", 0x0B00, 0x0B80 },
   { "taml", 0x0B80, 0x0C00 },
   { "telu", 0x0C00, 0x0C80 },
   { "knda", 0x0C80, 0x0D00 },
   { "mlym", 0x0D00, 0x0D80 },
   { "sinh", 0x0D80, 0x0E00 },
   { "thai", 0x0E00, 0x0E80 },
   { "laoo", 0x0E80, 0x0F00 },
   { "tibt", 0x0F00, 0x1000 },
   { "mymr", 0x1000, 0x10A0 },
   { "geor", 0x10A0, 0x1100 },
   { "hang", 0x1100, 0x1200 },
   { "ethi", 0x1200, 0x13A0 },
   { "cher", 0x13A0, 0x1400 },
   { "cans", 0x1400, 0x1680 },
   { "ogam", 0x1680, 0x16A0 },
   { "runr", 0x16A0, 0x1700 },
   { "tglg", 0x1700, 0x1720 },
   { "hano", 0x1720, 0x1740 },
   { "buhd", 0x1740, 0x1760 },
   { "tagb", 0x1760, 0x1780 },
   { "khmr", 0x1780, 0x1800 },
   { "mong", 0x1800, 0x18B0 },
   { "cans", 0x18B0, 0x1900 },
   { "limb", 0x1900, 0x1950 },
   { "tale", 0x1950, 0x1980 },
   { "talu", 0x1980, 0x19E0 },
   { "khmr", 0x19E0, 0x1A00 },
   { "bugi", 0x1A00, 0x1A20 },
   { "lana", 0x1A20, 0x1AB0 },
   { "diacr",0x1AB0, 0x1B00 },
   { "bali", 0x1B00, 0x1B80 },
   { "sund", 0x1B80, 0x1BC0 },
   { "batk", 0x1BC0, 0x1C00 },
   { "lepc", 0x1C00, 0x1C50 },
   { "olck", 0x1C50, 0x1C80 }, // Ol Chiki
   { "cyrl", 0x1C80, 0x1C90 },
   { "geor", 0x1C90, 0x1CC0 },
   { "sund", 0x1CC0, 0x1CD0 },
   { "vedic", 0x1CD0, 0x1D00 },
   { "phon", 0x1D00, 0x1E00 },
   { "latn", 0x1E00, 0x1F00 },
   { "grek", 0x1F00, 0x2000 },
   { "punc", 0x2000, 0x2070 },
   // { "supr", 0x2070, 0x20A0 }, // superscripts and subscripts
   { "zsym", 0x20A0, 0x20D0 }, // currency symbols
   { "diacr",0x20D0, 0x2100 },
   { "zsym", 0x2100, 0x2200 },
   { "math", 0x2200, 0x2300 },
   { "tech", 0x2300, 0x2400 },
   { "ctrl", 0x2400, 0x2440 },
   { "ocr",  0x2440, 0x2460 },
   { "alnum",0x2460, 0x2500 },
   { "box",  0x2500, 0x2580 },
   { "shape",0x2580, 0x2600 },
   { "zsym", 0x2600, 0x2700 },
   { "ding", 0x2700, 0x27C0 },
   { "math", 0x27C0, 0x27F0 },
   { "arrow",0x27F0, 0x2800 },
   { "brai", 0x2800, 0x2900 },
   { "arrow",0x2900, 0x2980 },
   { "math", 0x2980, 0x2B00 },
   { "zsym", 0x2B00, 0x2C00 },
   { "glag", 0x2C00, 0x2C60 },
   { "latn", 0x2C60, 0x2C80 },
   { "copt", 0x2C80, 0x2D00 },
   { "geor", 0x2D00, 0x2D30 },
   { "tfng", 0x2D30, 0x2D80 },
   { "ethi", 0x2D80, 0x2DE0 },
   { "cyrl", 0x2DE0, 0x2E00 },
   { "punc", 0x2E00, 0x2E80 },
   { "han",  0x2E80, 0x2F00 },
   { "punc", 0x3000, 0x3040 },
   { "kana", 0x3040, 0x3100 },
   { "cjk",  0x3200, 0x3400 },
   { "han",  0x3400, 0x4DC0 },
   { "han",  0x4E00, 0xA000 },
   { "yiii", 0xA000, 0xA4D0 },
   { "vaii", 0xA500, 0xA640 },
   { "cyrl", 0xA640, 0xA6A0 },
   { "sylo", 0xA800, 0xA830 },
   { "saur", 0xA880, 0xA8E0 },
   { "deva", 0xA8E0, 0xA900 },
   { "kali", 0xA900, 0xA930 },
   { "java", 0xA980, 0xA9E0 },
   { "cham", 0xAA00, 0xAA60 },
   { "ethi", 0xAB00, 0xAB30 },
   { "hang", 0xAC00, 0xD800 },
   { "surr", 0xD800, 0xE000 },
   { "priv", 0xE000, 0xF900 },
   { "cjk",  0xF900, 0xFB00 },
   { "latn", 0xFB00, 0xFB50 }, // alphabetic presentation forms
   { "arab", 0xFB50, 0xFE00 }, // Arabic presentation forms
   { "arab", 0xFE80, 0xFF00 }, // Arabic presentation forms
   { "wide", 0xFF00, 0xFFF0 },
   { "unk",  0xFFFD, 0xFFFE },
   { "linb", 0x10000, 0x10100 },
   { "grek", 0x10140, 0x10190 },
   { "goth", 0x10330, 0x10350 },
   { "lina", 0x10600, 0x10780 },
   { "cakm", 0x11100, 0x11150 }, // Chakma
   { "mahj", 0x11150, 0x11180 }, // Mahajani
   { "shrd", 0x11180, 0x111E0 }, // Sharada
   { "sinh", 0x111E0, 0x11200 },
   { "newa", 0x11400, 0x11480 },
   { "mong", 0x11660, 0x11680 },
   { "xsux", 0x12000, 0x12550 }, // Cuneiform
   { "egyp", 0x13000, 0x13440 },
   { "tang", 0x17000, 0x18B00 },
   { "kana", 0x1B000, 0x1B170 },
   { "grek", 0x1D200, 0x1D250 },
   { "math", 0x1D400, 0x1D800 },
   { "zsym", 0x1F300, 0x1F600 }, // Arabic math symbols
   { "zsye", 0x1F600, 0x1F650 }, // emoticons
   { "arrow",0x1F800, 0x1F900 },
   { "zsym", 0x1F900, 0x1FC00 },
   { "han",  0x20000, 0x2A6E0 },
   { "han",  0x2A700, 0x2EBE0 },
   { "han",  0x2F800, 0x2FA20 },
   { "han",  0x30000, 0x31350 },
   { "???",  0x31400, 0x40000 }	// sentinel and catch-all for merging
   } ;

/************************************************************************/
/************************************************************************/

static void usage(const char *argv0)
{
   fprintf(stderr,"Usage: %s [-h] [-s] [file ...]\n",argv0) ;
   fprintf(stderr,"\t-h\tshow this usage summary\n") ;
   fprintf(stderr,"\t-s\tshow script for each codepoint range\n") ;
   fprintf(stderr,"\t-S\tshow counts for each known ISO 15924 script\n") ;
   exit(1) ;
}

//----------------------------------------------------------------------

static unsigned get_codepoint(FILE *fp)
{
   unsigned codepoint = fgetc(fp) ; ;
   if (codepoint >= 0x80 && codepoint != (unsigned)EOF)
      {
      // figure out how many bytes make up the code point, and put the
      //   highest-order bits stored in the first byte into the
      //   codepoint variable
      unsigned byte = codepoint ;
      unsigned extra = 0 ;
      if ((byte & 0xE0) == 0xC0)
	 {
	 codepoint = (byte & 0x1F) ;
	 extra = 1 ;
	 }
      else if ((byte & 0xF0) == 0xE0)
	 {
	 codepoint = (byte & 0x0F) ;
	 extra = 2 ;
	 }
      else if ((byte & 0xF8) == 0xF0)
	 {
	 codepoint = (byte & 0x07) ;
	 extra = 3 ;
	 }
      else if ((byte & 0xFC) == 0xF8)
	 {
	 codepoint = (byte & 0x03) ;
	 extra = 4 ;
	 }
      else if ((byte & 0xFE) == 0xFC)
	 {
	 codepoint = (byte & 0x01) ;
	 extra = 5 ;
	 }
      // read in the additional bytes specified by the high bits of the
      //   codepoint's first byte
      for (size_t i = 1 ; i <= extra ; i++)
	 {
	 byte = fgetc(fp) ;
	 if (byte == (unsigned)EOF)
	    return codepoint ;
	 else if ((byte & 0xC0) != 0x80)
	    break ;			// invalid UTF8
	 // each extra byte gives us six more bits of the codepoint
	 codepoint = (codepoint << 6) | (byte & 0x3F) ;
	 }
      }
   return codepoint ;
}

//----------------------------------------------------------------------

static size_t init_merging(unsigned*& page_map, unsigned& unmapped_pages)
{
   size_t maxcp = 0 ;
   // find the highest code point referenced
   for (size_t i = 0 ; i < lengthof(script_names) ; ++i)
      {
      if (script_names[i].end > maxcp)
	 maxcp = script_names[i].end ;
      }
   // allocate the page map
   maxcp /= MERGE_SIZE ;
   page_map = new unsigned[maxcp] ;
   unmapped_pages = maxcp ;
   // default all codepoints to the sentinel unknown script
   std::fill(page_map,page_map+maxcp,lengthof(script_names)-1) ;
   // remember which items we've already processed
   bool processed[lengthof(script_names)] ;
   std::fill(processed,processed+lengthof(processed),false) ;
   // now iterate through the script records, setting up the mappings
   for (size_t i = 0 ; i < lengthof(script_names) ; ++i)
      {
      if (processed[i])
	 continue ;
      processed[i] = true ;
      for (size_t cp = script_names[i].start ; cp < script_names[i].end ; cp += MERGE_SIZE)
	 {
	 page_map[cp/MERGE_SIZE] = i ;
	 }
      // find any other records with the same name and map them to the first occurrence
      for (size_t j = i+1 ; j < lengthof(script_names) ; ++j)
	 {
	 if (processed[j] || strcmp(script_names[i].name,script_names[j].name) != 0)
	    continue ;
	 processed[j] = true ;
	 for (size_t cp = script_names[j].start ; cp < script_names[j].end ; cp += MERGE_SIZE)
	    {
	    page_map[cp/MERGE_SIZE] = i ;
	    }
	 }
      }
   return lengthof(script_names) ;
}

//----------------------------------------------------------------------

static void count_chars(FILE *fp, size_t page_counts[], unsigned num_pages, const unsigned* map)
{
   while (!feof(fp))
      {
      unsigned codepoint = get_codepoint(fp) ;
      unsigned page ;
      if (map)
	 {
	 page = codepoint / MERGE_SIZE ;
	 if (page >= num_pages)
	    page = num_pages-1 ;
	 page_counts[map[page]]++ ;
	 }
      else
	 {
	 page = codepoint / PAGE_SIZE ;
	 if (page < num_pages)
	    page_counts[page]++ ;
	 }
      }
   return ;
}

//----------------------------------------------------------------------

static void print_page_number(unsigned pagenum)
{
#if PAGE_SIZE == 128
   fprintf(stdout,"%3X%c\t",pagenum/2,(pagenum%2)?'h':'l') ;
#else /* PAGE_SIZE == 256 */
   fprintf(stdout,"%3X\t",pagenum) ;
#endif
   return ;
}

//----------------------------------------------------------------------

static void print_script_name(size_t page_start)
{
   for (size_t i = 0 ; i < lengthof(script_names) ; ++i)
      {
      if (script_names[i].start <= page_start && page_start < script_names[i].end)
	 {
	 fprintf(stdout,"%s\t",script_names[i].name) ;
	 return ;
	 }
      }
   fprintf(stdout,"???\t") ;
   return ;
}

//----------------------------------------------------------------------

static void print_histogram(const size_t page_counts[], unsigned num_pages, bool show_scripts, bool merge)
{
   if (merge)
      {
      for (unsigned i = 0 ; i < num_pages ; ++i)
	 {
	 if (page_counts[i] > 0)
	    {
	    fprintf(stdout,"%s\t%7lu\n",script_names[i].name,page_counts[i]) ;
	    }
	 }
      return ;
      }
   for (unsigned i = 0 ; i < num_pages ; ++i)
      {
      if (page_counts[i] > 0)
	 {
	 print_page_number(i) ;
	 if (show_scripts)
	    print_script_name(i*PAGE_SIZE) ;
	 fprintf(stdout,"%7lu\n",page_counts[i]) ;
	 }
      }
   return ;
}

//----------------------------------------------------------------------

int main(int argc, char **argv)
{
   const char *argv0 = argv[0] ;
   bool show_scripts = false ;
   bool merge_scripts = false ;
   while (argc > 1 && argv[1][0] == '-')
      {
      switch (argv[1][1])
	 {
	 case 's':
	    show_scripts = true ;
	    break ;
	 case 'S':
	    merge_scripts = true ;
	    break ;
	 case 'h':
	 default:
	    usage(argv0) ;
	    return 1 ;
	 }
      argc-- ;
      argv++ ;
      }
   size_t* page_counts ;
   unsigned num_pages ;
   unsigned unmapped_pages ;
   unsigned* page_map ;
   if (merge_scripts)
      {
      num_pages = init_merging(page_map, unmapped_pages) ;
      }
   else
      {
      page_map = nullptr ;
      num_pages = PAGE_COUNT ;
      unmapped_pages = PAGE_COUNT ;
      }
   page_counts = new size_t[num_pages] ;
   if (argc > 1)
      {
      while (argc > 1)
	 {
	 const char *filename = argv[1] ;
	 argv++ ;
	 argc-- ;
	 if (filename && *filename)
	    {
	    FILE *fp = fopen(filename,"rb") ;
	    if (fp)
	       {
	       std::fill(page_counts,page_counts+num_pages,0) ;
	       count_chars(fp,page_counts,unmapped_pages, page_map) ;
	       fclose(fp) ;
	       fprintf(stdout,"=== %s ===\n",filename) ;
	       print_histogram(page_counts,num_pages,show_scripts, merge_scripts) ;
	       }
	    }
	 }
      }
   else
      {
      std::fill(page_counts,page_counts+num_pages,0) ;
      count_chars(stdin,page_counts,unmapped_pages, page_map) ;
      print_histogram(page_counts,num_pages,show_scripts, merge_scripts) ;
      }
   delete page_counts ;
   return 0 ;
}
