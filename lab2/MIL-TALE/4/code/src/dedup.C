/************************************************************************/
/*                                                                      */
/*	LangIdent: long n-gram-based language identification		*/
/*	by Ralf Brown / Carnegie Mellon University			*/
/*									*/
/*  File:     dedup.C	remove (near-)identical lines from a file	*/
/*  Version:  1.25							*/
/*  LastEdit: 28mar2020 						*/
/*                                                                      */
/*  (c) Copyright 2014,2020 Ralf Brown/Carnegie Mellon University	*/
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

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/************************************************************************/
/************************************************************************/

#define MAX_LINE 32768U
#define MIN_FUZZY_LEN 40  // min len to allow near-match to count as duplicate
#define WORD_THRESH 5  // limit ratio of mismatched to total words
#define CHAR_THRESH 6  // limit ratio of mismatched to total chars
#define MIN_SUPERSET 40

/************************************************************************/
/************************************************************************/

static bool debug_trace = false ;
static bool ignore_capitalized = false ;
static bool remove_all = false ;

/************************************************************************/
/************************************************************************/

static void usage(const char *argv0)
{
   fprintf(stderr,"DeDup -- Copyright 2014 Ralf Brown\n") ;
   fprintf(stderr,"Remove duplicate and near-duplicate lines of text from file\n") ;
   fprintf(stderr,"\n") ;
   fprintf(stderr,"Usage: %s [options} <in >out\n",argv0) ;
   fprintf(stderr,"Options:\n") ;
   fprintf(stderr,"\t-a\tremove all near-duplicate lines, not just every other one\n") ;
   fprintf(stderr,"\t-c\tignore capitalized words\n") ;
   fprintf(stderr,"\n") ;
   fprintf(stderr,"Note: requires sorted input.\n") ;
   return ;
}

//----------------------------------------------------------------------

static void skip_number(const char *&ptr)
{
   while (*ptr && isascii(*ptr) &&
	  (isdigit(*ptr) || *ptr == ',' || *ptr == '.'))
      {
      ptr++ ;
      }
   return ;
}

//----------------------------------------------------------------------

static bool word_char(char c)
{
   if (!c)
      return false ;
   if (c >= 0x80)
      return true ;
   return !(isspace(c) || ispunct(c)) ;
}

//----------------------------------------------------------------------

static unsigned skip_word(const char *&ptr)
{
   unsigned skipped = 0 ;
   while (word_char(*ptr))
      {
      ptr++ ;
      skipped++ ;
      }
   return skipped ;
}

//----------------------------------------------------------------------

static unsigned count_words(const char *ptr)
{
   unsigned count = 0 ;
   while (*ptr)
      {
      while (*ptr && !word_char(*ptr))
	 {
	 ptr++ ;
	 }
      skip_word(ptr) ;
      count++ ;
      }
   return count ;
}

//----------------------------------------------------------------------

static bool prefix(const char *line1, const char *line2)
{
  unsigned len1 = strlen(line1) ;
  unsigned len2 = strlen(line2) ;

  if (len1 > len2 || len1 == 0 || len2 < MIN_SUPERSET)
    return false ;
  while (len1 > 1 && (line1[len1-1] == '\r' || line1[len1-1] == '\n'))
     len1-- ;
  return strncmp(line1,line2,len1) == 0 ;
}

//----------------------------------------------------------------------

static bool duplicate(const char *line1, const char *line2)
{
   // note: only works for UTF-8 and 8-bit ASCII supersets like ISO-8859-x
   unsigned len1 = strlen(line1) ;
   unsigned len2 = strlen(line2) ;
   unsigned min_len = (len1 < len2) ? len1 : len2 ;
   unsigned words1 = count_words(line1) ;
   unsigned words2 = count_words(line2) ;
   unsigned mismatch_chars = 0 ;
   unsigned mismatch_words = 0 ;
   char prev = ' ' ;
   while (*line1 && *line2)
      {
      char c1 = *line1 ;
      char c2 = *line2 ;
      if (isascii(c1) && isascii(c2))
	 {
	 if (isdigit(c1) && isdigit(c2))
	    {
	    skip_number(line1) ;
	    skip_number(line2) ;
	    continue ;
	    }
	 }
      if (ignore_capitalized && prev == ' ' && isascii(c1) && isascii(c2) && isupper(c1) && isupper(c2))
	 {
	 skip_word(line1) ;
	 skip_word(line2) ;
	 prev = '\0' ;
	 }
      else if (c1 != c2 && (word_char(c1) ^ word_char(c2)) )
	 {
	 unsigned mis1 = skip_word(line1) ;
	 unsigned mis2 = skip_word(line2) ;
	 mismatch_words++ ;
	 mismatch_chars += (mis1 > mis2) ? mis1 : mis2 ;
	 prev = '\0' ;
	 }
      else
	 {
	 if (c1 != c2)
	    {
	    mismatch_chars++ ;
	    prev = '\0' ;
	    }
	 else
	    {
	    prev = c1 ;
	    }
	 line1++ ;
	 line2++ ;
	 }
      }
   unsigned remainder1 = strlen(line1) ;
   unsigned remainder2 = strlen(line2) ;
   mismatch_chars += (remainder1 > remainder2) ? remainder1 : remainder2 ;
   if (remainder1 + remainder2 > 0) mismatch_words++ ;
   unsigned min_words = (words1 < words2) ? words1 : words2 ;
   if (debug_trace)
      fprintf(stderr,"mismatch: chars = %u/%u, words = %u/%u\n",mismatch_chars,min_len,mismatch_words,min_words) ;
   if (min_len >= MIN_FUZZY_LEN)
      {
      if (mismatch_chars < (min_len / CHAR_THRESH) && mismatch_words <= (min_words / WORD_THRESH))
	 return true ;
      }
   else // if (min_len < MIN_FUZZY_LEN)
      {
      if (mismatch_chars == 0 && mismatch_words == 0)
	 return true ;
      }
   return false ;
}

//----------------------------------------------------------------------

static void dedup(char *prev_line, const char *line, FILE *outfp)
{
   if (remove_all && strcmp(prev_line,line) == 0)
      return ;
   if (*prev_line && prefix(prev_line, line))
      {
      prev_line[0] = '\0' ;
      }
   else if (duplicate(prev_line,line))
      {
      // in a string of duplicates, we only want to eliminate every other one,
      //   so set the previous line to be empty the next time
      if (!remove_all)
	 prev_line[0] = '\0' ;
      }
   else
      {
      fputs(line,outfp) ;
      strcpy(prev_line,line) ;
      }
   return ;
}

//----------------------------------------------------------------------

static void dedup(FILE *infp, FILE *outfp)
{
   bool warned = false ;
   char prev_line[MAX_LINE] ;
   prev_line[0] = '\0' ;
   while (!feof(infp))
      {
      char line[MAX_LINE] ;
      line[MAX_LINE-1] = '\0' ;
      if (!fgets(line,sizeof(line),infp))
	 break ;
      if (line[MAX_LINE-1] != '\0' && !warned)
	 {
	 fprintf(stderr,"Warning: Extremely long line was split\n") ;
	 warned = true ;
	 }
      line[MAX_LINE-1] = '\0' ;
      dedup(prev_line,line,outfp) ;
      }
   return ;
}

//----------------------------------------------------------------------

int main(int argc, char **argv)
{
   const char *argv0 = argv[0] ;
   while (argc > 1 && argv[1][0] == '-')
      {
      switch (argv[1][1])
	 {
	 case 'a':
	    remove_all = true ;
	    break ;
	 case 'c':
	    ignore_capitalized = true ;
	    break ;
	 default:
	    usage(argv0) ;
	    return 1 ;
	 }
      argc-- ;
      argv++ ;
      }
   if (argc > 1)
      {
      // don't handle cmdline names yet
      usage(argv0) ;
      return 2 ;
      }
   else
      {
      dedup(stdin,stdout) ;
      }
   return 0;
}
