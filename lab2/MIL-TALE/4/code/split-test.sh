#!/bin/bash -x
# LastEdit: 07jun2020

#  (c) Copyright 2012,2013,2014,2015,2018,2020 Ralf Brown/Carnegie Mellon University	
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
exitcode=0

second=""
nostrong=""
de_html=""
want_prop=""
no_compress=""
rm_whole=""
vrbose="y"
have_html_sed=""
have_md_sed=""
skip_intro="y"
def_prop=30
dir=""

# define the temporary files
unwrap=/tmp/unwrap$$.sed
unsfm=/tmp/unsfm$$.sed
unSE=/tmp/unSE$$.sed
unHTM=/tmp/unHTM$$.sed

# file extensions
sfm1="*.sfm"
sfm2="*.SFM"
sfm3="*.usfm"
htm="*.htm"
md="*.md"
chapters="*.txt"
#chapters="*[0-9].txt"

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
shopt -s expand_aliases

cleanup()
{
    rm -f $unwrap $unsfm $unSE $unHTM /tmp/unsfm$$.txt
    exit $exitcode
}

trap cleanup 1

usage()
{
    echo "Usage: $(basename $1) [-H] [-s] [-2] [-p N] [-d D] zipfile [zipfile ...]"
    echo "Options:"
    echo "   -H    run text through 'dehtmlize'"
    echo "   -2    use *second* line of each chapter if no verse numbers"
    echo "   -s    extract from each file without using 'strong' tag"
    echo "   -p N  extract every Nth line of text for the test set"  
    echo "   -u    leave training set(s) uncompressed"
    echo "   -d D  store results in directory D"
    echo "   -I    include introductory text from USFM/.sfm files"
    echo "Description:"
    echo "  Split the text files contained in 'zipfile' into training and test sets,"
    echo "  using the verse number if available to extract the first verse of each"
    echo "  chapter as test data, or the first/second line of each file if verse"
    echo "  numbers are not available.  Text not extracted for testing is placed"
    echo "  in the training file.  If more than 3,300,000 bytes is available for"
    echo "  training, an additional 1/30 is split off for development/tuning."
    exit $E_USAGE
}

create_SE_script()
{
    if [ ! -e $unSE ] ; then
	cat >$unSE <<EOF
s@@@
s@[<]strong[>][0-9]*[<]/strong[>]@ @g
s@[\\]it[*]* @@g
s@[\\]f[rkt] @@g
s@ [(][-0-9.–]*[)]@ @
s@[\\]f [^\\]*[\\]f[*] @ @g
/^\$/,\$d
/^charset=/,\$d
s/[<]Ts[>]/\
/g
s/[<]C[MIL][>]/\
/g
s/[<]TS[12][>]//gm
s/[<]RF[>].*[<]Rf[>]//gm
s/[<]RF[>]/ /gm
s/[<]Rf[>]//gm
s/[<]PI[012]*[>]//gm
s@[<]/*i[>]@@gm
s@[<]sup[>][1-9][0-9]*[<]/sup[>]@@gm
s/[<]TS3[>].*\n//gm
s/^[<]p[>].*\$//gm
EOF
    fi
    return
}

create_unwrap_script()
{
    if [ ! -e $unwrap ] ; then
	cat >$unwrap <<EOF
:loop
N
s@[\\\\]bd[ *]@@g
s@[\\\\]bdit[ *]@@g
s@[\\\\]bk[ *]@@g
s@[\\\\]em[ *]@@g
s@[\\\\]it[ *]@@g
s@[\\\\]n[do][ *]@@g
s@[\\\\]ndx[ *]@@g
s@[\\\\]ord[ *]@@g
s@[\\\\]pn[ *]@@g
s@[\\\\]qt[ *]@@g
s@[\\\\]sc[ *]@@g
s@[\\\\]tl[ *]@@g
s@[\\\\]si[qs][ *]@@g
s@[\\\\]w[ *]@@g
s@[\\\\]w[ghj][ *]@@g
s@[\\\\]sc @ @g
s@[\\\\]sc[*]@@g
t clear
:clear
s@\n\([^\\]\)@ \1@
t loop
s@\n\([\\]fr\)@ \1@
t loop
s@\n\([\\]x[o*]\)@ \1@
t loop
s@\n\([\\]rq\)@ \1@
t loop
s@\n\([\\]k[*]\)@ \1@
t loop
P
D
EOF
    fi
    return
}

create_SFM_script()
{
    if [ ! -e $unsfm ] ; then
	[ -n "$skip_intro" ] && echo "1,/^[\\\\]c /d" >$unsfm
        cat >>$unsfm <<EOF
s@@@g
s@ @ @g
s@[\\\\][+]ior[1-9]* .*\$@@
s@[\\\\][+]h .*\$@@
s@[\\\\][+][sw] @@g
s@[\\\\][+]@\\\\@g

/^[\\\\]ide* /d
/^[\\\\]sts /d
/^[\\\\]rem /d
/^[\\\\]lit /d
/^[\\\\]periph /d
/^[\\\\]h[1-9]* /d
/^[\\\\]toc[1-9]* /d
/^[\\\\]imt[1-9]* /d
/^[\\\\]i[mpqs][1-9]* /d
/^[\\\\]i[mp][riq] /d
/^[\\\\]ili[1-9]* /d
/^[\\\\]io[t1-9]* /d
/^[\\\\]i[be] /d
/^[\\\\]imte[1-9]* /d
/^[\\\\]mte*[1-9]* /d
/^[\\\\]ms[1-9]* /d
/^[\\\\]mr /d
/^[\\\\]s[r1-9]* /d
/^[\\\\][bcdr] /d
/^[\\\\]sp /d
/^[\\\\]c[lp] /d
/^[\\\\][mp] *\$/d
/^[\\\\]pmc* *\$/d
/^[\\\\]p[br] *\$/d
/^[\\\\]ph[1-9]* *\$/d
/^[\\\\]nb *\$/d
/^[\\\\]q[cmr1-9]* *\$/d
/^[\\\\]t[chr][r1-9]* *\$/d
/^[\\\\]e[fx] /d
/^[\\\\]esb /,/^[\\\\]esbe/d
/^[\\\\]cp /d
/^[\\\\]pc /d
/^[\\\\]t[ch][1-9]*/d
/^[\\\\][^ \\]*\$/d
/^[\\\\]li[1-9]* *\$/d
/^[\\\\]fig [^\\\\]*\$/d
/^[\\\\]fig[*] *\$/d

s@^[\\\\]li[1-9]* @@
s@^[\\\\][mp] @@g
s@^[\\\\][mp]i[1-9]* @@g
s@^[\\\\]pm[cor]* @@g
s@^[\\\\]ph[1-9]* @@g
s@^[\\\\]cls* @@g
s@^[\\\\]cd @@g
s@^[\\\\]nb @@g
s@^[\\\\]p[cr] @@g
s@^[\\\\]q[cmr1-9]* @@g
s@^[\\\\]v \([1-9][-,0-9]*\) @<strong>\\1</strong> @g
s@^[\\\\]iex [-0-9: —]*@@
s@[\\\\]bd[ *]@@g
s@[\\\\]bdit[ *]@@g
s@[\\\\]bk[ *]@@g
s@[\\\\]em[ *]@@g
s@[\\\\]it[ *]@@g
s@[\\\\]n[do][ *]@@g
s@[\\\\]ndx[ *]@@g
s@[\\\\]ord[ *]@@g
s@[\\\\]pn[ *]@@g
s@[\\\\]qt[ *]@@g
s@[\\\\]sc[ *]@@g
s@[\\\\]tl[ *]@@g
s@[\\\\]si[gqs][ *]@@g
s@[\\\\]sls[ *]@@g
s@[\\\\]w[ *]@@g
s@[\\\\]w[ghj][ *]@@g
s@[\\\\]sc @ @g
s@[\\\\]sc[*]@@g
s@[\\\\]qac[ *]@@g
s@[\\\\]add [^\\\\]*[\\\\]add[*]@@g
s@[\\\\]ca [^\\\\]*[\\\\]ca[*] @@g
s@[\\\\]cat [^\\\\]*[\\\\]cat[*]@@g
s@[\\\\]ior[1-9]* [^\\\\]*[\\\\]ior[*] *@@g
s@[\\\\]iqt[1-9]* [^\\\\]*[\\\\]iqt[*] *@@g
s@[\\\\]k [^\\\\]*[\\\\]k[*] \[tab\] *@ @g
s@[\\\\]k [^\\\\]*[\\\\]k[*] *@@g
s@[\\\\]pro [^\\\\]*[\\\\]pro[*] *@@g
s@[\\\\]va[^\\\\]*[\\\\]va[*] @@g
s@[\\\\]vp[^\\\\]*[\\\\]vp[*] @@g
s@[\\\\]fig [^\\\\]*[\\\\]fig[*] *@@g
s@[\\\\]fig .*\$@@
s@[\\\\]fig[*]@@
s@[\\\\]x[koqt] [^\\\\]*@@gm
s@[\\\\]x[koqt][*]@@gm
s@[\\\\]x[no]t [^\\\\]*[\\\\]x[no]t[*] *@@gm
s@[\\\\]xdc [^\\\\]*[\\\\]xdc[*] *@@gm
s@[\\\\]xt [^\\\\]*[\\\\]xt[*]@@g
s@[\\\\]xt [^\\\\]*[\\\\]x[*]@\\\\x*@g
s@[\\\\]x [^\\\\]*[\\\\]x[*] *@@gm
s@[\\\\]x .*\$@@gm
s@[\\\\]x[*]@@gm
s@[\\\\]rq .*[\\\\]rq[*] *@@g
s@[\\\\]rq .*\$@@g
s@[\\\\]rq[*] *@@g
s@[\\\\]ior[1-9]* .*\$@@g
s@[\\\\]ior[*] *@@g
s@[\\\\]ztoc .*\$@@
s@^\(.*\)\([\\\\]f [^\\\\]*.*\)[\\\\]f[*]\(.*\)\$@\\1 \\3\\n\\2@g
s@^\(.*\)[\\\\]fe [^\\\\]*\(.*\)[\\\\]fe[*]\(.*\)\$@\\1 \\3\\n\\2@gm
s@[\\\\]fe* .*\$@@gm
s@[\\\\]fr [0-9][-0-9.:]* @@gm
s@[\\\\]fr [^ ][^ ]* [0-9][-0-9.:]* @@gm
s@[\\\\]fr[ *]@@gm
s@[\\\\]fv [0-9]*[\\\\]fv[*]@\\n@gm
s@[\\\\]fm [^\\\\]*[\\\\]fm[*]@ @gm
s@[\\\\]f[klpv] [^\\\\]*@@gm
s@[\\\\]fqa [^\\\\]*@@gm
s@[\\\\]fdc [^\\\\]*[\\\\]fdc[*] *@@gm
s@[\\\\]f[tq][*]* *@@gm
s@[\\\\]f @\\n@g
s@[\\\\]f[a-z][*] *@@gm
s@[\\\\]qs \([^\\\\]*\)[\\\\]qs[*] *@\\n\\1\\n@gm
s@[\\\\]f[*]@@gm
s@[\\\\]v \([1-9][-,0-9]*\) @\\n<strong>\\1</strong> @gm
s@~@ @gm
s@//@\\n@gm
EOF
    fi
    return
}

# set defaults

# process commandline arguments
while [[ $# -gt 0 && "x${1}" == x-* ]]
do
   case "$1" in
      "-d" )
         shift
         dir="${1}/"
	 mkdir -p "${1}"
	 ;;
      "-p" )
         shift
	 want_prop="$1"
	 ;;
      "-q" )
         vrbose=""
	 ;;
      "-s" )
         nostrong="y"
	 ;;
      "-u" )
         no_compress="y"
	 ;;
      "-2" )
	 second="y"
	 ;;
      "-H" )
         de_html="y"
	 ;;
      "-I" )
         skip_intro=""
	 ;;
      "--html-sedscript" )
         shift
         cp -ip "$1" "$unHTM"
	 have_html_sed="y"
	 ;;
      "--md-sedscript" )
         shift
         cp -ip "$1" "$unHTM"
	 have_md_sed="y"
	 ;;
      "--rm-full" )
         rm_whole="y"
	 ;;
   esac
   shift
done

[[ $# -ge 1 ]] || usage "$0"

required_prog subsample subsample


if [ -n "$de_html" ] ; then
   required_prog dehtmlize dehtmlize
   unstrong()
      {
      $dehtmlize | sed -e 's@&nbsp;@ @g' -e 's@^.*[<]strong[>][0-9]*[<]/strong[>] *@@' -e 's@[<]/*strong[>]@@g' -e 's@^[ 	][ 	]*@@' -e 's@[ 	]*$@@' -e '/^$/d'
      }
else
   unstrong()
      {
      sed -e 's@&nbsp;@ @g' -e 's@^.*[<]strong[>][0-9]*[<]/strong[>] *@@' -e 's@[<]/*strong[>]@@g' -e 's@^[ 	][ 	]*@@' -e 's@[ 	]*$@@' -e '/^$/d'
      }
fi

extr="${dir:-.}/EXTRACT$$"

for i in $*
do
   have_strong=""
   keep_whole=""
   zip="$i"
   [[ x$zip != x/* ]] && zip="${PWD}/${zip}"
   file_ext="${i##*.}"
   if [[ ".$file_ext" == .zip || ".$file_ext" == .xz || "$file_ext" == .gz ]] ; then
      base="$(basename $i)"
      base="${base%.*}"
   elif [[ ".$file_ext" == .txt || ".$file_ext" == .utf8 || "$file_ext" == .ascii ]] ; then
      base="$(basename $i)"
   else # assume .tgz or .txz
      base="$(basename $i)"
      base="${base%.*}"
   fi
   base="${base/[-]bible/}"
   base="${base/[-]nt/}"
   baseext="${base##*.}"
   [[ "$baseext" == utf8 || "$baseext" == txt ]] && base="${base%.*}"
   [[ "$baseext" == sfm || "$baseext" == nt ]] && base="${base%.*}"
   lang="${base%%__*}"
   train="${dir}${lang}-train.utf8"
   test="${dir}${lang}-test.utf8"
   whole="${dir}${lang}-all.utf8"
   devtest="${dir}${lang}-devtest.utf8"
   [ -n "$vrbose" ] && echo Processing $zip
   mkdir -p "$extr"
   rm -f "$train" "$test" "$whole"
   zipext="$(basename $zip)"
   zipext="${zipext##*.}"
   if [[ $zipext == xz || $zipext == gz ]] ; then
      ext=unxz
      [[ $zipext == gz ]] && ext=gunzip
      if [[ `$ext <$zip | head -1 | fgrep -c '<TS1>'` == 1 ]] ; then
         ## create SED script if necessary
	 create_SE_script
         $ext <$zip | sed -f $unSE | unstrong >"$whole"
      else
         $ext <$zip | grep -v '^[<]p[>]' | unstrong >"$whole"
      fi
      prop="$def_prop"
   else # .zip or compressed tar file
      pushd "$extr" >/dev/null
      keep_whole="y"  ## we have multiple files to be concatenated
      if [ ".$file_ext" == .tgz ] ; then
         tar xf "$zip" --use-compress-program=gzip
	 if [ `find -type d|grep -v '^[^.]'|wc -l` != 0 ] ; then
	    mv */* . >&/dev/null
	 fi
      elif [ ".$file_ext" == .txz ] ; then
         tar xf "$zip" --use-compress-program=xz
	 if [ `find -type d|grep -v '^[^.]'|wc -l` != 0 ] ; then
	    mv */* . >&/dev/null
	 fi
      else # .zip
         unzip -q "$zip" >/dev/null
      fi
      base="${zip##*/}"
      base="${base%.*}"
      [ -e "${base}" ] && mv "${base}/"* . >&/dev/null
      popd >/dev/null
      prop=""
   fi
   [ -n "$want_prop" ] && prop="$want_prop"
   if ls "$extr/"${chapters} >&/dev/null ; then
      fgrep -q -s 'strong>1<' /dev/null "$extr/"${chapters} && have_strong="y"
   fi
   [ -n "$nostrong" ] && have_strong=""
   ## process files in SFM format
   if ls "$extr/"${sfm1} >&/dev/null || ls "$extr/"${sfm2} >&/dev/null || ls "$extr/"${sfm3} >&/dev/null ; then
      for bk in "$extr/"${sfm1} "$extr/"${sfm2} "$extr/"${sfm3}
      do
         [ "x$bk" == x/dev/null ] && continue
	 [ -e "$bk" ] || continue
	 ## skip front matter
	 [[ `head -1 <"$bk" |fgrep -c -e 'id FRT' -e 'id GLO' -e 'id TDX'` != 0 ]] && continue
         ## create SED scripts if necessary
	 create_unwrap_script
	 create_SFM_script
         if [ -n "$prop" ] ; then
	    sed -f $unwrap "$bk" | sed -f $unsfm | unstrong | grep ^.. >>"$whole"
         else
	    sed -f $unwrap "$bk" | sed -f $unsfm >>"$whole"
            fgrep 'strong>1<' /tmp/unsfm$$.txt | unstrong |grep ^.. >>"$test"
   	    fgrep -v 'strong>1<' /tmp/unsfm$$.txt | unstrong | grep ^.. >>"$train"
         fi
      done
   fi
   ## extract text from HTML files
   if ls "$extr/"${htm} >&/dev/null ; then
      for i in "$extr/"${htm}
      do
	 tail="${i##*/}"
         [[ ${tail} == copr.htm || ${tail} == copyright* || ${tail} == *COPYRIGHT* ]] && continue
         if [ -z "$have_html_sed" ] ; then
	    echo "Error: no HTML extractor specified for ${zip}!"
	    cleanup
	    exit 2
         fi
         sed -f "$unHTM" "$i" >"${i%.[^/]*}.txt"
      done
   fi
   ## extract text from Markdown files
   if ls "$extr/"${md} "$extr/content/"${md} >&/dev/null ; then
      for i in "$extr/"${md} "$extr/content/"${md}
      do
	 tail="${i##*/}"
         [[ ${tail} == copr.htm || ${tail} == copyright* || ${tail} == *COPYRIGHT* ]] && continue
         if [ -z "$have_md_sed" ] ; then
	    echo "Error: no Markdown extractor specified for ${zip}!"
	    cleanup
	    exit 2
         fi
	 dest="${i%.[^/]*}.txt"
         sed -f "$unHTM" "$i" >"${dest/content//}.txt"
      done
   fi
   ## process plain-text files with optional <strong>NNN</strong> markup
   if ls "$extr/"${chapters} >&/dev/null ; then
      unset noclobber
      for ch in  "$extr/"${chapters}
      do
         if [ -n "$prop" ] ; then
            grep . "$ch" | unstrong >>"$whole"
         elif [ -n "$have_strong" ] ; then
            fgrep 'strong>1<' "$ch" | unstrong >>"$test"
	    fgrep -v 'strong>1<' "$ch" | unstrong >>"$train"
         elif [ -n "$second" ] ; then
            grep . "$ch" | head -n 2 | tail -1 | unstrong >>"$test"
            grep . "$ch" | head -n 1 | unstrong >>"$train"
            grep . "$ch" | tail -n +3 | unstrong >>"$train"
         else
	    grep . "$ch" | head -n 1 | unstrong >>"$test"
            grep . "$ch" | tail -n +2 | unstrong >>"$train"
         fi
         rm "$ch"
      done
   fi
   if [ -n "$prop" ] ; then
      ## check whether the specified extraction proportion gives a
      ##   reasonable amount (>=40K) of test data
      if [ ! -e "$whole" ] ; then
	  echo "Did not generate ${whole##*/}, skipping test-set creation"
      else
	  size=`wc -c <"$whole"`
	  [ -n "$size" ] || size=0
	  let "ratio = $size / 40000"
	  if [[ $ratio -lt $prop ]] ; then
	      [[ $ratio -lt 10 ]] && ratio=10
              [ -n "$vrbose" ] && echo Adjusting test-set ratio downward to $ratio get sufficient test data
	      prop="$ratio"
	  fi
	  "$subsample" -i "-r$train" $prop <"$whole" >"$test"
	  [[ -z "$keep_whole" || -n "$rm_whole" ]] && rm -f "$whole"
      fi
   fi
   ## if we have more than 3.3M training data, we can generate a devtest
   if [ -e "$train" ] ; then
      bigenough=`wc -c <"$train"`
      if [[ $bigenough -ge 3300000 ]] ; then
      # split off an extra 1/30th to use as devtest data
	 rm -f /tmp/split$$
	 "$subsample" -i -r/tmp/split$$ 30 <"$train" >"$devtest"
	 mv /tmp/split$$ "$train"
	 [ -n "$vrbose" ] && wc "$train" "$devtest" "$test"
      else
	  [ -n "$vrbose" ] && wc "$train" "$test"
      fi
   fi
   rm -rf "$extr"
   if [ -z "$no_compress" ] ; then
      rm -f "${train}.xz"
      xz -7 "$train"
   fi
done # for i in $ *

cleanup

exit $exitcode
