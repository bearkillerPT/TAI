#!/bin/bash
# LastEdit: 03sep2015

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

# default settings
tmp=/tmp/prep$$

# find out where this script is located
p="$(dirname $0)"
[[ "x$p" != "x." ]] || p="$PWD"
[[ "x$p" == x/* ]] || p="$PWD/$p"
# load support functions
[ -e "$p/rbfuncs.sh" ] || { echo "Support functions not found.  Please re-install." ; exit 1 ; }
. $p/rbfuncs.sh

if [[ $# != 9 ]] ; then
   echo "Usage: $0:t src prepared minlines maxlines minlen maxlen {Y|N} cvtto embedcount"
   echo "(only $# args given)"
   exit $E_USAGE
fi

src="$1"
prepared="$2"
minlines="$3"
maxlines="$4"
minlen="$5"
maxlen="$6"
strip_key=""
[ "x$7" == "xY" ] && strip_key="y"
convertto="$8"
embed="$9"

if [ -n "$strip_key" ] ; then
   sed -e 's/^[^	]*	//' "$src" | head -$maxlines >"$prepared"
else
   head -$maxlines "$src" >"$prepared"
fi
lines=`wc -l <"$prepared"`
if [[ $lines -lt $minlines ]] ; then
   rm -f "$prepared"
   exit 1
fi
if [[ $minlen != 0 ]] ; then
   (export LC_ALL=C ; egrep "^.{$minlen,}" "$prepared" >$tmp)
   mv $tmp "$prepared"
   lines=`wc -l <"$prepared"`
fi
if [[ $maxlen != 0 ]] ; then
   let max = $maxlen + 1
   (export LC_ALL=C ; egrep -v "^.{$max,}" "$prepared" >$tmp)
   mv $tmp "$prepared"
   lines=`wc -l <"$prepared"`
fi
if [ -n "$convertto" ] ; then
   required_prog iconv convert
   encoding_from_filename "${src##*/}"
   $convert -f $enc -t $convertto <"$prepared" >$tmp
   mv $tmp "$prepared"
fi
if [[ $embed != "0" ]] ; then
   required_prog add-random.sh addrand
   xargs -n1 '-d\n' <"$prepared" "$addrand" $embed >$tmp
   mv $tmp "$prepared"
fi

exit 0
