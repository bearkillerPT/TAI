/************************************************************************/
/*                                                                      */
/*	LangIdent: long n-gram-based language identification		*/
/*	by Ralf Brown / Carnegie Mellon University			*/
/*									*/
/*  File:     subsample.C  utility program to sample lines of text	*/
/*  Version:  2.00							*/
/*  LastEdit: 31mar20	 						*/
/*                                                                      */
/*  (c) Copyright 2012,2013,2014,2020 Carnegie Mellon University	*/
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

#include <iostream>
#include <memory.h>
#include <random>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

using namespace std ;

/************************************************************************/
/*	Manifest Constants						*/
/************************************************************************/

/************************************************************************/
/*	Helpers								*/
/************************************************************************/

#ifndef lengthof
# define lengthof(x) (sizeof(x)/sizeof(x[0]))
#endif

/************************************************************************/
/*	Types								*/
/************************************************************************/

typedef vector<string> StringList ;

struct ScriptInfo {
   const char* name ;
   unsigned    boundaries[30] ;  // enough for 15 ranges
   } ;

/************************************************************************/
/*	Global Data							*/
/************************************************************************/

// bit flags for code points 0x000000 to 0x10FFFF
static vector<bool> desired_chars(0x110000) ;
static vector<bool> ignorable_chars(0x110000) ;

static double min_ratio = 0.6 ;

//----------------------------------------------------------------------

static const ScriptInfo scripts[] =
   {
   //12345678901234567890123//  max length of string
   { "arab (Arabic)", 		0x0600, 0x0700, 0x0750, 0x0780, 0x08A0, 0x0900, 0xFB50, 0xFE00, 0xFE70, 0xFF00, 0x1EE00, 0x1EF00 },
   { "armn (Armenian)",		0x0530, 0x0590 },
   { "bali (Balinese)",		0x1B00, 0x1B80 },
   { "batk (Batak)",		0x1BC0, 0x1C00 },
   { "beng (Bengali)",		0x0980, 0x0A00 },
   { "bopo (Bopomofo)",		0x3100, 0x3130, 0x31A0, 0x31C0 },
   { "bugi (Buginese)", 	0x1A00, 0x1A20 },
   { "buhd (Buhid)",		0x1740, 0x1760 },
   { "copt (Coptic)", 		0x2C80, 0x2D00, 0x102E0, 0x10300 },
   { "cans (Aboriginal Syll)", 	0x1400, 0x1680, 0x18B0, 0x1900 },
   { "cher (Cherokee)",		0x13A0, 0x1400, 0xAB70, 0xABC0 },
   { "cyrl (Cyrillic)",		0x0400, 0x0530, 0x1C80, 0x1C90 },
   { "deva (Devanagari)",	0x0900, 0x0980, 0xA8E0, 0xA900 },
   { "eqyp (Egyptian Hiero)",	0x13000, 0x13440 },
   { "ethi (Ethiopic)",		0x1200, 0x13A0, 0x2D80, 0x2DE0, 0xAB00, 0xAB30 },
   { "geor (Georgian)",		0x10A0, 0x1100, 0x1C90, 0x1CC0, 0x2D00, 0x2D30 },
   { "goth (Gothic)",		0x10330, 0x10350 },
   { "grek (Greek)",		0x0370, 0x0400, 0x1F00, 0x2000, 0x10140, 0x10190, 0x1D200, 0x1D250 },
   { "gujr (Gujarati)",		0x0A80, 0x0B00 },
   { "guru (Gurmuki)",		0x0A00, 0x0A80 },
   { "hans (Simp Chinese)",	},
   { "hant (Trad Chinese)",	},
   { "hang (Hangul)",		0x1100, 0x1200, 0x3130, 0x3190, 0xA960, 0xA980, 0xAC00, 0xD800 },
   { "hebr (Hebrew)",		0x0370, 0x0400 },
   { "java (Javanese)",		0xA980, 0xA9E0 },
   { "kali (Kayah Li)",		0xA900, 0xA930 },
   { "kana (Japanese Kana)",	0x3040, 0x3100, 0x31F0, 0x3200, 0x1B100, 0x1B170 },
   { "khmr (Khmer)",		0x1780, 0x1800, 0x19E0, 0x1A00 },
   { "knda (Kannada)",		0x0C80, 0x0D00 },
   { "kore (Korean)",		0x1100, 0x1200, 0x3130, 0x3190, 0xA960, 0xA980, 0xAC00, 0xD800 },
   { "laoo (Lao)",		0x0E80, 0x0F00 },
   { "latn (Latin)",		0x0020, 0x0250, 0x1E00, 0x1F00, 0x2C60, 0x2C80, 0xA720, 0xA800, 0xAB30, 0xAB70, 0xFF00, 0xFF5F },
   { "lepc (Lepcha)",		0x1C00, 0x1C50 },
   { "limb (Limbu)",		0x1900, 0x1950 },
   { "lisu (Lisu)",		0xA4D0, 0xA500, 0x11FB0, 0x11FC0 },
   { "mlym (Malayalam)",	0x0D00, 0x0D80 },
   { "mong (Mongolian)",	0x1800, 0x18B0, 0x11660, 0x11680 },
   { "mymr (Myanmar)",		0x1000, 0x10A0, 0xA9E0, 0xAA00, 0xAA60, 0xAA80 },
   { "newa (Newari)",		0x11400, 0x11480 },
   { "nkoo (N'Ko)",		0x07C0, 0x0800 },
   { "orya (Oriya/Odia)",	0x0B00, 0x0B80 },
   { "samr (Samaritan)",	0x0800, 0x0840 },
   { "saur (Saurashtra)",	0xA880, 0xA8E0 },
   { "sinh (Sinhalese)",	0x0D80, 0x0E00, 0x111E0, 0x11200 },
   { "sund (Sundanese)",	0x1B80, 0x1BC0, 0x1CC0, 0x1CD0 },
   { "sylo (Syloti Nagri)",	0xA800, 0xA830 },
   { "syrc (Syriac)",		0x0700, 0x0750, 0x0860, 0x08A0 },
   { "taml (Tamil)",		0x0B80, 0x0C00, 0x11FC0, 0x12000 },
   { "telu (Telugu)",		0x0C00, 0x0C80 },
   { "tfng (Tifinagh/Berber)",	0x2D30, 0x2D80 },
   { "tglg (Tagalog)",		0x1700, 0x1720 },
   { "thaa (Thaana)",		0x0780, 0x07C0 },
   { "thai (Thai)",		0x0E00, 0x0E80 },
   { "tibt (Tibetan)",		0x0F00, 0x0F80 },
   { "vaii (Vai)",		0xA500, 0xA640 },
   { "yiii (Yi)",		0xA000, 0xA4D0 },
   } ;

/************************************************************************/
/************************************************************************/

static void usage(const char *argv0)
{
   cerr << "Usage: " << argv0 << " [options] count <inputfile" << endl ;
   cerr << "Randomly extract 'count' lines from the input file and write them to\n"
           "standard output.\n"
           "\n"
           "Options: (per-line pre-sampling)\n"
           "\t-cCH\tsample lines containing mostly given chars\n"
           "\t  -Cx\trequire at least x%%, def=60\n"
           "\t-lX\tsample lines more than 'X' bytes in length\n"
           "\t-LX\tsample lines less than 'X' bytes in length\n"
           "Options: (output size)\n"
           "\t-b\tuniformly sample approx. 'count' bytes in total\n"
           "\t-i\tsample every 'count'th line ('count' is interval, not total)\n"
           "\t-u\tsample uniformly-spaced lines instead of random lines\n"
           "Options: (output control)\n"
           "\t-rF\twrite non-sampled (rejected) lines to file F\n"
           "\n"
           "Notes:\n"
           "When pre-sampling is used, the contents of the 'reject' file may not be in\n"
           "the original input order.  Specify a count of '0' to use pre-sampling only.\n"
           "This program requires enough memory to store all text which passes the pre-\n"
           "sampling filters.\n"
	<< endl ;
   exit(1) ;
}

//------------------------------------------------------------------------

static void print_width(ostream& out, size_t width, const char* str)
{
   size_t len = strlen(str) ;
   out << '\t' ;
   while (width > 0 && len > 0)
      {
      out << (*str++) ;
      --len ;
      --width ;
      }
   while (width > 0)
      {
      out << ' ' ;
      --width ;
      }
   return ;
}

//------------------------------------------------------------------------

static void usage_scripts(const char* script)
{
   if (script && *script)
      cerr << "Unknown script '" << script <<"' for flag -c" << endl  ;
   cerr << "Known scripts:" << endl ;
   for (size_t i = 0 ; 3*i < lengthof(scripts) ; ++i)
      {
      print_width(cerr,23,scripts[3*i].name) ;
      if (3*i+1 < lengthof(scripts))
	 {
	 print_width(cerr,23,scripts[3*i+1].name) ;
	 if (3*i+2 < lengthof(scripts))
	    print_width(cerr,23,scripts[3*i+2].name) ;
	 }
      cerr << endl ;
      }
   exit(1) ;
}

/************************************************************************/
/*	Unicode functionality						*/
/************************************************************************/

static size_t next_codepoint(const char*& utf8)
{
   unsigned char c = *((unsigned char*)utf8) ;
   ++utf8 ;
   if (c < 0x80)
      {
      return c ;
      }
   else if (c < 0xC0)
      {
      // error: broken UTF8 encoding!
      // skip any remaining continuation bytes
      while ((c = *((unsigned char*)utf8)) >= 0x80 && c < 0xC0)
	 ++utf8 ;
      return c ;
      }
   unsigned cont = 0 ;
   size_t codepoint ;
   if (c < 0xE0)
      {
      cont = 1 ;
      codepoint = (c & 0x1F) ;
      }
   else if (c < 0xF0)
      {
      cont = 2 ;
      codepoint = (c & 0x0F) ;
      }
   else if (c < 0xF8)
      {
      cont = 3 ;
      codepoint = (c & 0x07) ;
      }
   else if (c < 0xFC)
      {
      cont = 4 ;
      codepoint = (c & 0x03) ;
      }
   else if (c < 0xFE)
      {
      cont = 5 ;
      codepoint = (c & 0x01) ;
      }
   else
      {
      // error: broken UTF8 encoding!
      return 0 ;
      }
   // collect the continuation bytes
   for (size_t i = 0 ; i < cont ; ++i)
      {
      c = *((unsigned char*)utf8) ;
      ++utf8 ;
      if ((c & 0xC0) != 0x80)
	 return codepoint ;		// broken UTF8!
      codepoint = (codepoint << 6) | (c & 0x3F) ;
      }
   return codepoint ;
}

//----------------------------------------------------------------------

static void count_codepoints(const string& line, size_t &desired, size_t &total)
{
   const char* c_line = line.c_str() ;
   desired = 0 ;
   total = 0 ;
   if (!c_line)
      return ;
   while (*c_line)
      {
      size_t cp = next_codepoint(c_line) ;
      if (!ignorable_chars[cp])
	 {
	 ++total ;
	 if (desired_chars[cp])
	    ++desired ;
	 }
      }
   return ;
}

//----------------------------------------------------------------------

static bool check_desired_codepoints(const string& line)
{
   size_t desired_cp ;
   size_t total_cp ;
   count_codepoints(line,desired_cp,total_cp) ;
   return desired_cp >= min_ratio * total_cp ;
}

//----------------------------------------------------------------------

static void set_ignorable_chars()
{
   std::fill(ignorable_chars.begin(),ignorable_chars.begin()+0x0021,true) ;  // control chars and blank
   std::fill(ignorable_chars.begin()+'0',ignorable_chars.begin()+'9',true) ;  // control chars and blank
   std::fill(ignorable_chars.begin()+0x02B0,ignorable_chars.begin()+0x0370,true) ; // diacritics
   std::fill(ignorable_chars.begin()+0x2000,ignorable_chars.begin()+0x2070,true) ; // general punctuation
   std::fill(ignorable_chars.begin()+0x20A0,ignorable_chars.begin()+0x2150,true) ; // symbols
   std::fill(ignorable_chars.begin()+0x2190,ignorable_chars.begin()+0x2400,true) ; // arrows, math, technical syms
   std::fill(ignorable_chars.begin()+0x2500,ignorable_chars.begin()+0x2600,true) ; // boxes, blocks, shapes
   std::fill(ignorable_chars.begin()+0x2600,ignorable_chars.begin()+0x27C0,true) ; // symbols + dingbats
   std::fill(ignorable_chars.begin()+0x27C0,ignorable_chars.begin()+0x2800,true) ; // math, arrows
   std::fill(ignorable_chars.begin()+0x2900,ignorable_chars.begin()+0x2C00,true) ; // math, arrows, symbols
   std::fill(ignorable_chars.begin()+0x2E00,ignorable_chars.begin()+0x2E80,true) ; // punctuations
   std::fill(ignorable_chars.begin()+0x3000,ignorable_chars.begin()+0x3040,true) ; // CJK symbols + punctuation
   std::fill(ignorable_chars.begin()+0xFE00,ignorable_chars.begin()+0xFE10,true) ; // variation selectors
   std::fill(ignorable_chars.begin()+0xFFF0,ignorable_chars.begin()+0x10000,true) ; // specials
   return ;
}

//----------------------------------------------------------------------

static bool parse_char_filter(const char* opt)
{
   if (strcmp(opt,"han") == 0 || strcmp(opt,"hans") == 0 || strcmp(opt,"hant") == 0 ||
      strcmp(opt,"kore") == 0)	// CJK
      {
      std::fill(desired_chars.begin()+0x2E80,desired_chars.begin()+0x2F00,true) ;
      std::fill(desired_chars.begin()+0x3000,desired_chars.begin()+0x3040,true) ;  // punct and syms
      std::fill(desired_chars.begin()+0x3100,desired_chars.begin()+0x3130,true) ;  // Bopomofo
      std::fill(desired_chars.begin()+0x31A0,desired_chars.begin()+0x31C0,true) ;  // Bopomofo Ext
      std::fill(desired_chars.begin()+0x31C0,desired_chars.begin()+0x3200,true) ;  // strokes
      std::fill(desired_chars.begin()+0x3300,desired_chars.begin()+0x4DC0,true) ;
      std::fill(desired_chars.begin()+0x4E00,desired_chars.begin()+0xA000,true) ;
      std::fill(desired_chars.begin()+0xF900,desired_chars.begin()+0xFB00,true) ;
      std::fill(desired_chars.begin()+0xFE30,desired_chars.begin()+0xFE50,true) ;
      std::fill(desired_chars.begin()+0x20000,desired_chars.begin()+0x2A6E0,true) ;
      std::fill(desired_chars.begin()+0x2A700,desired_chars.begin()+0x2EBE0,true) ;
      std::fill(desired_chars.begin()+0x2F800,desired_chars.begin()+0x2FA20,true) ;
      std::fill(desired_chars.begin()+0x30000,desired_chars.begin()+0x3134B,true) ;
      if (strcmp(opt,"kore") != 0)	// Korean needs to add Hangul below
	 return true ;
      }
   if (opt && strlen(opt) == 4 && isalpha(opt[0]))
      {
      // check whether this is a known name
      for (unsigned i = 0 ; i < lengthof(scripts) ; ++i)
	 {
	 if (strncmp(scripts[i].name,opt,4) == 0)
	    {
	    // it's a match, so set the specified ranges
	    for (size_t j = 0 ; j < lengthof(scripts[i].boundaries) ; j += 2)
	       {
	       if (scripts[i].boundaries[j+1] == 0)
		  break  ;
	       size_t s = scripts[i].boundaries[j] ;
	       size_t e = scripts[i].boundaries[j+1] ;
	       std::fill(desired_chars.begin()+s, desired_chars.begin()+e, true) ;
	       }
	    return true ;
	    }
	 }
      }
   if (isalpha(opt[0]) && islower(opt[0]))
      {
      // user requesting a mapping by name, but we didn't recognize it
      usage_scripts(opt) ;
      return false ;
      }
   //TODO: parse explicit numeric ranges
   return false ;
}

/************************************************************************/
/************************************************************************/

static void take_uniform_bytes(const StringList& lines, size_t sample_size, FILE *rejectfp)
{
   if (lines.empty())
      return ;
   size_t total_bytes = 0 ;
   for (const auto l : lines)
      {
      total_bytes += l.size() ;
      }
   double sample_rate = (sample_size + 1.0) / (double)total_bytes ;
   size_t sampled_bytes = 0 ;
   total_bytes = 0 ;
   for (const auto line : lines)
      {
      size_t len = line.size() ;
      if (sampled_bytes <= (total_bytes * sample_rate))
	 {
	 fputs(line.c_str(),stdout) ;
	 fputc('\n',stdout) ;
	 sampled_bytes += len ;
	 }
      else if (rejectfp)
	 {
	 fputs(line.c_str(),rejectfp) ;
	 fputc('\n',rejectfp) ;
	 }
      total_bytes += len ;
      }
   return ;
}

//----------------------------------------------------------------------

static void take_uniform_sample(const StringList& lines, size_t sample_size, FILE *rejectfp)
{
   if (lines.empty())
      return ;
   size_t numlines = lines.size() ;
   double interval = sample_size / (double)numlines ;
   double count = interval/2.0 ;
   for (const auto line : lines)
      {
      FILE* fp = (floor(count + interval) > floor(count)) ? stdout : rejectfp ;
      if (fp)
	 {
	 fputs(line.c_str(),fp) ;
	 fputc('\n',fp) ;
	 }
      count += interval ;
      }
   return ;
}

//----------------------------------------------------------------------

static void take_random_sample(const StringList& lines, size_t sample_size, FILE *rejectfp)
{
   size_t numlines = lines.size() ;
   if (sample_size >= numlines)
      {
      for (const auto line : lines)
	 {
	 fputs(line.c_str(),stdout) ;
	 fputc('\n',stdout) ;
         }
      }
   else
      {
      random_device rd ;
      mt19937_64 random_engine(rd()) ;	// seed generator while constructing it
      uniform_real_distribution<> randnum(0.0,1.0) ;
      size_t unsampled = numlines ;
      for (const auto line : lines)
	 {
	 if (randnum(random_engine) * unsampled < sample_size)
	    {
	    fputs(line.c_str(),stdout) ;
	    fputc('\n',stdout) ;
	    --sample_size ;
	    }
	 else if (rejectfp)
	    {
	    fputs(line.c_str(),rejectfp) ;
	    fputc('\n',rejectfp) ;
	    }
	 --unsampled ;
	 }
      }
   return ;
}

//----------------------------------------------------------------------

int main(int argc, char **argv)
{
   bool uniform_sample = false ;
   bool use_bytes = false ;
   bool use_interval = false ;
   bool use_length = false ;
   bool use_chars = false ;
   unsigned min_length = 0 ;
   unsigned max_length = (unsigned)~0 ;
   const char *reject_file = 0 ;
   const char *argv0 = argv[0] ;
   while (argc > 1 && argv[1][0] == '-')
      {
      switch (argv[1][1])
	 {
	 case 'b':
	    use_bytes = true ;
	    use_interval = false ;
	    uniform_sample = false ;
	    break ;
	 case 'c':
	    use_chars = parse_char_filter(argv[1]+2) ;
	    break ;
	 case 'C':
	    if (argv[1][2])
	       {
	       int ratio = atoi(argv[1]+2) ;
	       if (ratio > 0 && ratio < 100)
		  min_ratio = ratio/100.0 ;
	       }
	    break ;
	 case 'i':
	    use_interval = true ;
	    use_bytes = false ;
	    uniform_sample = false ;
	    break ;
	 case 'l':
	    min_length=atoi(argv[1]+2) ;
	    use_length = true ;
	    break ;
	 case 'L':
	    max_length=atoi(argv[1]+2) ;
	    use_length = true ;
	    break ;
	 case 'r':
	    reject_file = argv[1]+2 ;
	    break ;
	 case 'u':
	    uniform_sample = true ;
	    use_bytes = false ;
	    use_interval = false ;
	    break ;
	 default:
	    cerr << "Unrecognized option " << argv[1] << endl << endl ;
	    usage(argv0) ;
	    break ;
	 }
      argc-- ;
      argv++ ;
      }
   size_t sample_size = (argc >= 2) ? atoi(argv[1]) : 0 ;
   if (argc < 2)
      {
      if (!use_length && !use_chars)
	 usage(argv0) ;
      }
   if (sample_size == 0 && !use_interval)
      sample_size = ~0 ;
   if (use_chars)
      set_ignorable_chars() ;
   FILE *rejectfp = nullptr ;
   if (reject_file && *reject_file)
      {
      rejectfp = fopen(reject_file,"w") ;
      }
   StringList lines ;
   size_t numlines = 0 ;
   while (!cin.eof())
      {
      string line ;
      std::getline(cin,line) ;
      if (cin.fail())
	 break ;
      bool want_line = true ;
      if (use_length)
	 {
	 unsigned len = line.size() ;
	 if (len < min_length || len > max_length)
	    want_line = false ;
	 }
      else if (use_interval)
	 {
	 want_line = (numlines % sample_size == 0) ;
	 }
      if (use_chars && want_line)
	 {
	 want_line = check_desired_codepoints(line) ;
	 }
      if (want_line)
	 {
	 lines.push_back(line) ;
         }
      else if (rejectfp)
	 {
	 fputs(line.c_str(),rejectfp) ;
	 fputc('\n',rejectfp) ;
	 }
      numlines++ ;
      }
   if (sample_size == (size_t)~0 || use_interval)
      {
      // output all lines that passed the pre-filter
      take_uniform_sample(lines,numlines,rejectfp) ;
      }
   else if (use_bytes)
      {
      take_uniform_bytes(lines,sample_size,rejectfp) ;
      }
   else if (uniform_sample)
      {
      take_uniform_sample(lines,sample_size,rejectfp) ;
      }
   else
      {
      take_random_sample(lines,sample_size,rejectfp) ;
      }
   if (rejectfp)
      fclose(rejectfp) ;
   return 0 ;
}
