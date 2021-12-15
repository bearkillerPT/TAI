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

# set up default parameters
method="whatlang"

# where to find stuff
srcdir="$HOME/src"
basedir="$usrdir/la-strings"

# find out where this script is located
p="$(dirname $0)"
[ "x$p" != "x." ] || p="$PWD"
[[ "x$p" == x/* ]] || p="$PWD/$p"
# load support functions
[ -e "$p/rbfuncs.sh" ] || { echo "Support functions not found.  Please re-install." ; exit 1 ; }
. $p/rbfuncs.sh
required_prog langid-setup.sh setupfn
. $setupfn

lddir=""
mgdir=""
tcdir=""
lpymodel=""

# program executables
convertprog=iconv
whatlang="$p/whatlang"
mguesser="$p/mguesser"
textcat="$p/testtextcat"
langidpy="python $p/langid-rb.py"
yali="$p/yali-identifier"
ldjar="${srcdir}/langdetect/lib/langdetect.jar"
convert=cat

# program options
db="$basedir/languages.db"
yalidir="$p/yali-models"
ldmem=9600
max=2000
smooth="-b1"
weights=""
cvt=""
bwt=""
swt=""
convert=cat
convertto=""
langdetect="java -Xmx${ldmem}m -jar $ldjar --detectlang -s 0"
smoothing=""

cleanup()
{
    rm -f /tmp/cnt$$ /tmp/ld$$
    exit 0
}

trap cleanup 1

usage()
{
    exit $E_USAGE
}

strip_key()
{
    head -${max} | sed -e 's/^[-a-zA-Z]*	//' | $convert
    return
}

extract_key()
{
    head -${max} | sed -e 's/^\([-a-zA-Z]*\)	.*/\1/' | $convert
    return
}

collect_results()
{
    sed -f /tmp/cnt$$ | sort | uniq -c | sort -nr
    return
}

### apply the selected language identifier to the standard input of this function and
### send the identifier's output to stdout
run_eval()
{
   case "$method" in
      "overhead" )
	 strip_key >/dev/null
	 extract_key
	 ;;
      "langdetect" )
	 strip_key >/tmp/ld$$
	 "$langdetect" -d "$lddir" --line /tmp/ld$$
	 ;;
      "langid.py" )
	 strip_key | "$langidpy" -m $lpymodel --line
	 ;;
      "mguesser" )
         strip_key | "$mguesser" -d"$mgdir" -n1 -L $smoothing
	 ;;
      "textcat" )
	 strip_key | "$textcat" "$tcdir/conf.txt" -l $smoothing
	 ;;
      "YALI" )
	 strip_key | "$yali" --classes "$yalidir/models" --each --input -
	 ;;
      "whatlang" )
	 strip_key | "$whatlang" "-l$db" $smooth $cvt $weights -t -n1
	 ;;
      * )
         echo "Unknown method '$method'"
	 ;;
   esac
   return
}

# set defaults

# process commandline arguments
while [[ $# -gt 0 && "x${1}" == x-* ]]
do
   case "$1" in
      "--db" | "--whatlang" )
         method="whatlang"
         shift
	 db="$1"
	 ;;
      "--max" )
         shift
	 max="$1"
	 ;;
      "--smoothscores" )
         smooth="-b2"
	 ;;
      "--bigrams" )
         shift
	 bwt="b$1"
	 ;;
      "--stopgrams" )
         shift
	 swt="s$1"
	 ;;
      "--mguesser" )
         shift
	 mgdir="$1"
         ;;
      "--textcat" )
         method="textcat"
         shift
	 tcdir="$1"
         ;;
      "--langdetect" )
         method="langdetect"
	 shift
	 lddir="$1"
	 ;;
      "--langid.py" )
	 method="langid.py"
         shift
	 lpymodel="$1"
	 ;;
      "--yali" )
         method="YALI"
	 shift
	 yalidir="$1"
	 ;;
      "--utf8" )
         # force all input files to UTF-8 encoding
         convertto="utf8//TRANSLIT//IGNORE"
	 ;;
      "--utf16be" )
         convertto="utf16be//TRANSLIT//IGNORE"
	 cvt="-16b"
	 ;;
      "--utf16le" )
         convertto="utf16le//TRANSLIT//IGNORE"
	 cvt="-16l"
	 ;;
      "--smoothfreq" )
         shift
	 smoothing="$1"
	 ;;
      * )
         echo "Unknown option $1"
	 usage "$0"
         ;;
   esac
   shift
done

[ -n "$convertto" ] && required_prog iconv convertprog

[[ -n "$bwt" || -n "x$swt" ]] && weights="-W$bwt,$swt"

eval "setup_${method/./} /tmp/cnt$$" Y

files="$#"
export LC_ALL=C
if [ $files == 0 ] ; then
   convert=cat
   [ -n "$convertto" ] && convert="$convertprog -f utf8 -t $convertto"
   run_eval | collect_results
else
   while (( $# > 0 ))
   do
      [ $files -gt 1 ] && echo "=== $1 ==="
      [ -z "$1" ] && continue
      convert=cat
      if [ -n "$convertto" ] ; then
	 encoding_from_filename "$1"
	 convert="$convertprog -f $enc -t $convertto"
      fi
      run_eval <"$1" | collect_results
      shift
   done
fi

cleanup

exit 0
