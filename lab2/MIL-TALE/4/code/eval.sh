!/bin/bash
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

# which operation to perform
method="whatlang"

# find out where this script is located
p="$(dirname $0)"
[[ "x$p" != "x." ]] || p="$PWD"
[[ "x$p" == x/* ]] || p="$PWD/$p"
# load support functions
[ -e "$p/rbfuncs.sh" ] || { echo "Support functions not found.  Please re-install." ; exit 1 ; }
. $p/rbfuncs.sh
required_prog langid-setup.sh setupfn
. $setupfn

# where to find stuff
usrdir="$HOME/src"
basedir="$usrdir/la-strings"
d="$p"
[ "$(basename $d)" == bin ] && d="$(dirname $d)"

# default locations of program executables
score="$basedir/util/score"
whatlang="$basedir/langident/whatlang"
strings="$basedir/la-strings"

langidpy=""
yalimod="$p/yali-models.sh"
java=java
ldjar=""
[ -e "$usrdir/langdetect/lib/langdetect.jar" ] && ldjar="$usrdir/langdetect/lib/langdetect.jar"
[ -e "$p/lib/langdetect.jar" ] && ldjar="$p/lib/langdetect.jar"
[ -e "$(dirname $p)/lib/langdetect.jar" ] && ldjar="$(dirname $p)/lib/langdetect.jar"
ldopts="-Xbatch -XX:+AggressiveOpts -XX:+UseLargePages" #"-Xprof"
ldopts="-Xbatch" #"-Xprof"

# program options
twoletter="y"		# force two-letter ISO codes for YALI?
whatlang_len=1
langdetect_len="--line"
langidpy_len="--line"
mguesser_len=-L
textcat_len=-l
textcat_fp=
ldminmem=2500
ldmem=11700
lddir="$d/langdetect-profiles"
mgdir="$d/mguesser-maps"
tcdir="$d/textcat-lm"
lpymodel="model"
ldequiv="sed -f $TMP/eq_$$"
lpyequiv="sed -f $TMP/eq_$$"
yaliequiv="sed -f $TMP/eq_$$"
yalidir="$d/yali-models"
db="$basedir/languages.db"
[ -e "$d/models/languages.db" ] && db="$d/models/languages.db"
equiv=cat
keyonly="cut -f1"
convertto=""
cvt=""
smoothing=""
batch_mode=

# evaluation configuration (defaults)
minlen=0  ## minimum line length to score
maxlen=0  ## minimum line length to score, 0=unlimited
minlines=100
maxlines=1000
thresh=""
weights=""
bwt=""
swt=""
#thresh="-S10"
embed="0"
raw_only=""
show_misses=""
keep_extract=""

# where to put temporary files
[ -z "$TMP" ] && export TMP=/tmp
tmp1="$TMP/eval$$"
tmp2="$TMP/eval2_$$"
tmp3="$TMP/eval3_$$"
tmpkey="$TMP/evalkey_$$"
str="$TMP/str$$"


cleanup()
{
    rm -f "$TMP/eq$$" "$TMP/eq_$$" "$TMP/eval$$" "$tmp3" "$tmpkey"
    exit 0
}

trap cleanup 1

usage()
{
    echo "Usage: $(basename $0) ..."
    exit $E_USAGE
}

## apply language identifier to $1 and write its output to stdout
## if appropriate, also use gold standard from $2
run_identifier()
{
    case "$method" in
	"overhead" )
            paste "$2" "$1" | $equiv
	    ;;
	"langdetect" )
	    $langdetect $langdetect_len -d $lddir $smoothing "$1" | $ldequiv | $equiv
	    ;;
	"langid.py" )
            $langidpy $langidpy_len -m "$lpymodel" <"$1" | $lpyequiv | $equiv
	    ;;
	"mguesser" )
            "$mguesser" -d$mgdir $mguesser_len -n1 $smoothing <"$1" | $equiv
	    ;;
	"textcat" )
            "$textcat" ${tcdir}/conf.txt $textcat_len $textcat_fp $smoothing <"$1" | $equiv
	    ;;
	"YALI" )
            "$yali" --classes "$yalidir/models" $smoothing --each --input "$1" | $yaliequiv | $equiv
	    ;;
	"whatlang" )
	    if [ -z "$raw_only" && ${whatlang_len} == 1 ] ; then
		$whatlang -t -b2 -n1 "-l$db" $cvt $weights "$1" | $equiv
	    else
		$whatlang -t -b${whatlang_len} -n1 "-l$db" $cvt $weights "$1" | $equiv
	    fi
	    ;;
	* )
            echo "Unknown method '$method'"
	    exit 1
	    ;;
    esac
    return
}

# set default values

# process commandline arguments
while [[ $# -gt 0 && "x${1}" == x-* ]]
do
   case "$1" in
      "--batch" )
         batch_mode="y"
	 ;;
      "--db" | "--whatlang" )
	 shift
	 db="$1"
         ;;
      "--file" )
         langdetect_len="--file"
	 langidpy_len=""
         mguesser_len=""
	 textcat_len="-f"
	 whatlang_len="500000"
	 ;;
      "--misses" )
	 show_misses="y"
	 ;;
      "-S" | "--thresh" )
         shift
	 thresh="-S$1"
	 ;;
      "--embed" )
         # embed N random bytes between lines of text
         shift
	 embed="$1"
	 show_misses="y"
	 ;;
      "--equiv" )
         equiv="sed -f '$TMP/eq$$'"
	 ;;
      "--keep" )
         keep_extract="y"
	 ;;
      "-S7" | "-S10" )
         thresh="$1"
	 ;;
      "--bigrams" )
         shift
	 bwt="b$1"
	 ;;
      "--stopgrams" )
         shift
	 swt="s$1"
	 ;;
      "--smooth" )
         shift
	 smoothing="$1"
	 ;;
      "--overhead" )
         method="overhead"
	 ;;
      "--raw-only" )
         raw_only="y"
	 ;;
      "--langdetect" )
         method="langdetect"
	 shift
	 lddir="$1"
	 ;;
      "--ldmem" )
	 shift
	 ldmem="$1"
	 ;;
      "--ldminmem" )
	 shift
	 ldminmem="$1"
	 ;;
      "--mguesser" )
         method="mguesser"
	 shift
	 mgdir="$1"
	 ;;
      "--textcat" )
         method="textcat"
	 shift
	 tcdir="$1"
	 ;;
      "--langid.py" )
         method="langid.py"
	 shift
	 [ -n "$1"] && lpymodel="$1"
	 ;;
      "--yali" )
         method="YALI"
         shift
         yalidir="$1"
	 ;;
      "--fpsize" )
	 shift
         textcat_fp="-t$1"
	 ;;
      "--min" )
         shift
         minlines="$1"
	 ;;
      "--max" )
         shift
         maxlines="$1"
	 ;;
      "--minlen" )
         shift
         minlen="$1"
	 ;;
      "--maxlen" )
         shift
         maxlen="$1"
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
      * )
         echo "Unknown option $1"
	 ;;
   esac
   shift
done

if [[ -n "$batch_mode" && "x$convertto" == xutf16* ]] ; then
   echo "can't combine --batch and --utf16be/le"
   exit 1
fi

[ -n "$convertto" ] && required_prog iconv iconv

required_prog perl
required_prog prepare_file.sh prep
[ -n "$batch_mode" && ! -e "$score" ] && required_prog score score

[ "$equiv" == "cat" ] || create_lang_equiv_script "$TMP/eq_$$"
eval setup_${method} "$TMP/eq_$$"

## set LangDetect's random seed to 0 so that the results won't vary from run to run
langdetect="$java -Xms${ldminmem}m -Xmx${ldmem}m $ldopts -jar $ldjar --detectlang -s 0"
[[ "$bwt" != "" || "$swt" != "" ]] && weights="-W$bwt,$swt"

export LC_ALL=C
if [ -n "$batch_mode" ) ; then
   rm -f "$tmp3" "$tmpkey"
   for file in $*
   do
      "$prep" "$file" "$tmp1" "$minlines" "$maxlines" "$minlen" "$maxlen" N "$convertto" "$embed"
      if [ -e "$tmp1" ] ; then
         sed -e 's/	.*/	/' "$tmp1" | $equiv >>"$tmpkey"
         sed -e 's/^[^	]*	//' "$tmp1" >>"$tmp3"
         rm -f "$tmp1"
      fi
   done
   if [[ -e "$tmp3" && -e "$tmpkey" ]] ; then
      run_identifier "$tmp3" "$tmpkey" | $keyonly >"$tmp2"
      "$score" "$tmpkey" "$tmp2"
      [ -n "$keep_extract" ] && mv -n "$tmp2" "identified-languages"
   fi
   rm -f "$tmp2" "$tmp3" "$tmpkey"
   exit 0
fi

let files = 0
let totalraw = 0
let totalsm = 0
let totallines = 0
let rawerr = 0
let smootherr = 0
let totalmiss = 0
let totalextra = 0

for file in $*
do
   "$prep" "$file" "$tmp1" "$minlines" "$maxlines" "$minlen" "$maxlen" Y "$convertto" "$embed"
   [ -e "$tmp1" ] || continue
   if [[ "x$convertto" == xutf16* ]] ; then
      lines=`$iconv -f $convertto -t utf8 <"$tmp1" | wc -l`
   else
      lines=`wc -l <"$tmp1"`
   fi
   langr=`head -1 "$file"| $equiv | sed -e 's/	.*//'`
   langs=`head -1 "$file"| $equiv | sed -e 's/	.*//' -e 's/^\(.......\).*/\1/'`
   run_identifier "$tmp1" "$file" >"$tmp2"
   raw=`grep -vc "^${langr}	" "$tmp2"`
   rm -f "$tmp2"
   if [ -n "$show_misses" ] ; then
      $strings -i$db -I1 $thresh -u $weights "$tmp1" | $equiv >$str
      smoothed=`grep -vc "^${langs}	" <$str`
      let extracted = `wc -l <$str`
      if [ $extracted <= $lines ] ; then
         let miss = $lines - $extracted
         let extra = 0
      else
         let miss = 0
         let extra = $extracted - $lines
      fi
   else if [ $method == "whatlang" && -z "$raw_only" ] ; then
      $whatlang -t -b2 -n1 "-l$db" $cvt $weights "$tmp1" | $equiv >$str
      smoothed=`grep -vc "^${langr}	" <$str`
      let miss = 0
      let extra = 0
   else
      let smoothed = 0
      let miss = 0
      let extra = 0
   fi
   rm -f "$tmp1"
   if [ -n "$keep_extract" ] ; then
      mv -n $str ${file}.str
      rm -f $str >/dev/null
   else
      rm -f $str
   fi
   l=$lines
   [ $l == 0 ] && l=1
   percentr=`perl -e "printf "\""%.2f"\"", 100.0 * ${raw} / ${l}"`
   percents=`perl -e "printf "\""%.2f"\"", 100.0 * ${smoothed} / ${l}"`
   base="${file##*/}"
   base="${base%.[^.]*}"
   if [ -n "$show_misses" ] ; then
      echo "${base}: (${langr}) ${raw}/${smoothed} of ${lines} incorrect (${percentr}/${percents}%), $miss misses, $extra extra"
   else
      echo "${base}: (${langr}) ${raw}/${smoothed} of ${lines} incorrect (${percentr}/${percents}%)"
   fi
   r=`echo ${percentr/[.]//}|sed -e 's/^0*\(.\)/\1/'`
   s=`echo ${percents/[.]//}|sed -e 's/^0*\(.\)/\1/'`
   let "totalraw = $totalraw + ${r}"
   let "totalsm = $totalsm + ${s}"
   let "files = $files + 1"
   let "rawerr = $rawerr + $raw"
   let "smootherr = $smootherr + $smoothed"
   let "totallines = $totallines + $lines"
   let "totalmiss = $totalmiss + $miss"
   let "totalextra = $totalextra + $extra"
done
[ $totallines == 0] && totallines=1
if [ $files != 0 ] ; then
   err_r=`perl -e "printf "\""%.3f"\"", ${totalraw} / ${files} * 0.01"`
   err_s=`perl -e "printf "\""%.3f"\"", ${totalsm} / ${files} * 0.01"`
   echo "Processed ${files} files, macro-average error rates = $err_r/${err_s}%"
   rawrate=`perl -e "printf "\""%.3f"\"", 100.0 * ${rawerr} / ${totallines}"`
   smoothrate=`perl -e "printf "\""%.3f"\"", 100.0 * ${smootherr} / ${totallines}"`
   missrate=`perl -e "printf "\""%.3f"\"", 100.0 * ${totalmiss} / ${totallines}"`
   false=`perl -e "printf "\""%.3f"\"", 100.0 * ${totalextra} / ${totallines}"`
   echo "Total errors: $rawerr/$smootherr of $totallines (${rawrate}/${smoothrate}%)"
   if [ -n "$show_misses" ] ; then
      echo "Overall misses = ${totalmiss} (${missrate}%), false alarms = ${false}%"
   fi
fi

exit 0
