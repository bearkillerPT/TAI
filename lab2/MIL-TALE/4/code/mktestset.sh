#!/bin/bash
# LastEdit: 27aug2015

#  (c) Copyright 2012,2013,2014,2015 Ralf Brown/Carnegie Mellon University	
#      This program is free software; you can redistribute it and/or
#      modify it under the terms of the GNU General Public License as
#      published by the Free Software Foundation, version 3.
#
#      This program is distributed in the hope that it will be
#      useful, but WITHOUT ANY WARRANTY; without even the implied
#      warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#      PURPOSE.  See the GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public
#      License (file COPYING) along with this program.  If not, see
#      http://www.gnu.org/licenses/

# set up default parameters
dir="."
language=""
minlines=100
char=""
#char="-c"
quiet=""

# find out where this script is located
p="$(dirname $0)"
[ "x$p" != "x." ] || p="$PWD"
[[ "x$p" == x/* ]] || p="$PWD/$p"
# load support functions
[ -e "$p/rbfuncs.sh" ] || { echo "Support functions not found.  Please re-install." ; exit 1 ; }
. $p/rbfuncs.sh

unalias rm >&/dev/null
unalias mv >&/dev/null
unalias cp >&/dev/null

usage()
{
    echo "Usage: $(basename $1) [-b] [-d DIR] [-l lang] [-m minl] minwidth maxwidth file [file ...]"
    echo "  Word-wrap input files to at most 'maxwidth' characters (bytes if -b),"
    echo "  and at least 'minwidth' bytes.  If the result is less than 'minl'"
    echo "  (default $minlines) lines in length, merge all text into a single line"
    echo "  and then re-wrap the text.  When -l is specified, add 'lang' (derived"
    echo "  from the filename if 'auto') to the start of each output line.  If -d"
    echo "  is given, the output files will be stored in DIR instead of the current"
    echo "  directory."
    exit $E_USAGE
}

unwrap()
{
    if [ -n "$1" ] ; then
	tr '\n' ' '
    else
	cat
    fi
    return
}

fold_input()
{
    sed -e 's/^[ 	]*//' -e 's/[ 	]*$//' -e 's@[	][<]/a[>]@@' -e 's/$//' "$1" | \
	unwrap "$2" | \
	"$fold" -s $char -w $maxwidth | sed -e 's/﻿//' -e 's/^  *//' -e 's/  *$//' | \
	grep -E "^.{$minwidth}"
    return
}

if [ -n "$LC_ALL" ] ; then
   if [ "x$LC_ALL" == xC ] ; then
      export LC_ALL=
   fi
fi

# process commandline arguments
while [[ $# -gt 0 && "x${1}" == x-* ]]
do
   case "$1" in
      '-b' )
          char="-b"
	  ;;
      '-d' )
          shift
          dir="$1"
	  ;;
      '-l' )
	  shift
	  language="$1"
	  ;;
      '-m' )
          shift
	  minlines="$1"
	  ;;
      '-q' )
          quiet="y"
	  ;;
      * )
          echo "Unrecognized flag $1"
	  usage "$0"
	  exit 2
          ;;
   esac
   shift
done

[[ $# -ge 3 ]] || usage "$0"

required_prog iconv iconv
required_prog fold fold

mkdir -p "$dir"

minwidth="$1"
maxwidth="$2"
shift
shift
while [[ $# -gt 0 ]]
do
   if [ -z "$1" ] ; then
      shift
      continue
   fi
   base="${1##*/}"
   base="${base%.[^.]*}"
   real_out="${dir}/${base/-test/}-test-${minwidth}-${maxwidth}.txt"
   out=$real_out
   file="$1"
   if [ ! -e "$file" ] ; then
      [ -z "$quiet" ] && echo Unable to access $file
      shift
      continue
   fi
   encoding_from_filename "$file" "None"
   if [[ "$enc" != "None" ]] ; then
      "$iconv" -f $enc -t utf8 <"$file" >/tmp/mktin$$
      file=/tmp/mktin$$
      out=/tmp/mktout$$
   fi
   if [ -z "$language" ] ; then
      fold_input "$file" >"$out"
   else
      lang="$language"
      if [ $language == "auto" ] ; then
	 lang="${1##*/}"
	 lang="${lang%%_*}"
      fi
      fold_input "$file" >/tmp/mktest$$
      lines=`wc -l </tmp/mktest$$`
      if [[ $lines -lt $minlines ]] ; then
         # re-do the wrapping using the entire input as one long line to avoid
         #  throwing out short lines as much as possible
	 fold_input "$file" Y >/tmp/mktest$$
         lines=`wc -l </tmp/mktest$$`
      fi
      yes $lang | head -n $lines | paste - /tmp/mktest$$ >"$out"
      rm /tmp/mktest$$
   fi
   if [ "$out" != "$real_out" ] ; then
      "$iconv" -f utf8 -t $enc <"$out" >"$real_out"
      rm "$out"
   fi
   [ "$file" != "$1" ] && rm "$file"
   shift
done

exit 0
