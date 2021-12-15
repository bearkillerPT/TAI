/************************************************************************/
/*                                                                      */
/*	LangIdent: long n-gram-based language identification		*/
/*	by Ralf Brown / Carnegie Mellon University			*/
/*									*/
/*  File:     score.C	evaluation of language identification results	*/
/*  Version:  1.25							*/
/*  LastEdit: 22mar2020 						*/
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

#include <algorithm>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

using namespace std ;

/************************************************************************/
/************************************************************************/

#define MAX_LINE 32768U

/************************************************************************/
/************************************************************************/

class Counts
   {
   public:
      Counts() ;
      Counts(std::string* key) : m_lang(key) {}

      // accessors
      const auto language() const { return m_lang  ; }
      size_t correct() const { return m_correct ; }
      size_t incorrect() const { return m_incorrect ; }
      size_t fuzzy() const { return  m_fuzzymatch ; }

      // modifiers
      void addCorrect() { ++m_correct ; }
      void addIncorrect() { ++m_incorrect ; }
      void addFuzzy() { ++m_fuzzymatch ; }

      // comparison
      bool operator< (const Counts& other) const { return m_lang && other.m_lang && m_lang < other.m_lang ; }

   private:
      std::string* m_lang { nullptr } ;
      size_t       m_correct { 0 } ;
      size_t       m_incorrect { 0 } ;
      size_t       m_fuzzymatch { 0 } ;
   } ;

typedef std::vector<Counts> CountVector ;
typedef std::unordered_map<std::string,size_t> LangMap ;

/************************************************************************/
/************************************************************************/

static void usage(const char *argv0)
{

   exit(2) ;
}

//----------------------------------------------------------------------

static void trim_line(char *line, bool strip_multiple)
{
   char *tab = strchr(line,'\t') ;
   if (tab)
      *tab = '\0' ;
   char *nl = strchr(line,'\n') ;
   if (nl)
      *nl = '\0' ;
   if (strip_multiple)
      {
      char *comma = strchr(line,',') ;
      if (comma)
	 *comma = '\0' ;
      }
   return ;
}

//----------------------------------------------------------------------

static void update_stats(LangMap& langmap, CountVector& counts, char* key, char* eval, bool show_fuzzy)
{
   bool correct = strcmp(key,eval) == 0 ;
   bool fuzzy = false ;
   if (show_fuzzy)
      {
      //TODO
      }
   std::string keystr(key) ;
   auto mapentry = langmap.insert({ keystr, counts.size() } ) ;
   size_t index ;
   if (mapentry.second)
      {
      index = mapentry.first->second ;
      }
   else
      {
      // not yet present,so add it
      index = counts.size() ;
      auto keystr = new std::string(key) ;
      counts.push_back(Counts(keystr)) ;
      }
   Counts& langinfo = counts[index] ;
   if (correct)
      langinfo.addCorrect() ;
   else
      langinfo.addIncorrect() ;
   if (fuzzy)
      langinfo.addFuzzy() ;
   return ;
}

//----------------------------------------------------------------------

static void print_stats(const LangMap &langmap, CountVector& counts, bool show_fuzzy)
{
   if (counts.size() == 0)
      {
      cout << "No statistics" << endl ;
      return ;
      }
   std::sort(counts.begin(),counts.end()) ;
   unsigned num_langs = 0 ;
   double global_error_rate = 0.0 ;
   size_t global_incorrect = 0 ;
   size_t global_total = 0 ;
   if (show_fuzzy)
      {
      printf("Rate(%%)\tErrors\tTotal\tFuzzy\tLanguage\n") ;
      printf("=========================================\n") ;
      }
   else
      {
      printf("Rate(%%)\tErrors\tTotal\tLanguage\n") ;
      printf("=================================\n") ;
      }
   for (auto cnt : counts)
      {
      num_langs++ ;
      size_t correct = cnt.correct() ;
      size_t incorrect = cnt.incorrect() ;
      size_t fuzzy = cnt.fuzzy() ;
      size_t total = correct + incorrect ;
      const auto lang = cnt.language() ;
      double error_rate = total ? (incorrect / ((double)total)) : 0.0 ;
      if (show_fuzzy)
	 {
	 printf("%7.2f\t%6lu\t%6lu\t%6lu\t%s\n",100.0 * error_rate,incorrect,total,fuzzy,lang->c_str()) ;
	 }
      else
	 {
	 printf("%7.2f\t%6lu\t%6lu\t%s\n",100.0 * error_rate,incorrect,total,lang->c_str()) ;
	 }
      global_error_rate += error_rate ;
      global_incorrect += incorrect ;
      global_total += total ;
      }
   if (num_langs > 0)
      {
      if (show_fuzzy)
	 printf("=========================================\n") ;
      else
	 printf("=================================\n") ;
      printf("LANGUAGE COUNT = %u\n",num_langs) ;
      printf("AVERAGES:  micro = %7.3f%%\tmacro = %7.3f%%\n",
	     100.0 * (global_incorrect / (double)global_total),
	     100.0 * (global_error_rate / num_langs)) ;
      }
   return ;
}

//----------------------------------------------------------------------

static bool score_results(FILE *keyfp, FILE *evalfp, bool show_fuzzy)
{
   LangMap lang_to_counts_map(10000) ;
   CountVector per_language_counts ;
   size_t line_count = 0 ;
   while (!feof(keyfp) && !feof(evalfp))
      {
      char key[MAX_LINE] ;
      char eval[MAX_LINE] ;
      bool got_key = fgets(key,sizeof(key),keyfp) != 0 ;
      bool got_eval = fgets(eval,sizeof(eval),evalfp) != 0 ;
      if (!got_key && !got_eval)
	 break ;
      else if (!got_key || !got_eval)
	 {
	 cerr << "Error reading from file after " << line_count << " lines"
	      << endl ;
	 return false ;
	 }
      line_count++ ;
      trim_line(key,false) ;
      trim_line(eval,!show_fuzzy) ;
      update_stats(lang_to_counts_map,per_language_counts,key,eval,show_fuzzy) ;
      }
   print_stats(lang_to_counts_map, per_language_counts, show_fuzzy) ;
   if (!feof(keyfp))
      {
      cerr << "Evaluation output is too short" << endl ;
      return false ;
      }
   else if (!feof(evalfp))
      {
      cerr << "Key file is too short" << endl ;
      return false ;
      }
   return true ;
}

//----------------------------------------------------------------------

int main(int argc, char **argv)
{
   bool show_fuzzy = false ;
   if (argv[1] && strcmp(argv[1],"-f") == 0)
      {
      show_fuzzy = true ;
      argv++ ;
      argc-- ;
      }
   if (argc < 2)
      usage(argv[0]) ;
   const char *keyfile = argv[1] ;
   const char *evalfile = argv[2] ;

   FILE *keyfp = fopen(keyfile,"r") ;
   FILE *evalfp = fopen(evalfile,"r") ;
   bool success = false ;
   if (keyfp && evalfp)
      {
      success = score_results(keyfp,evalfp,show_fuzzy) ;
      }
   if (keyfp)
      fclose(keyfp) ;
   if (evalfp)
      fclose(evalfp) ;
   return success ? 0 : 1 ;
}
