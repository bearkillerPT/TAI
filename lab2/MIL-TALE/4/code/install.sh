#!/bin/bash
# LastEdit: 07jun2020

#  (c) Copyright 2012,2013,2014,2015,2020 Ralf Brown/Carnegie Mellon University	
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

# set default options
do_core="y"
testprop=30		# portion of text to use for test file
threads="2"		# conservative default, will try to auto-detect
nocompress="-u"		# default is to leave training sets uncompressed
interactive="y"
do_merge=""
do_merge_test=""
do_all=""
do_samples=""
do_smalltrain=""
do_devtrain=""
show_help=""

# find out where this script is located
p="$(dirname $0)"
[ "x$p" != "x." ] || p="$PWD"
[[ "x$p" == x/* ]] || p="$PWD/$p"
# load support functions
[ -e "$p/rbfuncs.sh" ] || { echo "Support functions not found.  Please re-install." ; exit 1 ; }
. $p/rbfuncs.sh

unalias rm >&/dev/null
rm=/bin/rm
unalias mv >&/dev/null
mv=/bin/mv
unalias ls >&/dev/null
ls=/bin/ls
unalias cp >&/dev/null

## clean up temporaries
cleanup()
{
   [ -n $topdir ] && rm -rf "$topdir/extract$$"
   rm -f /tmp/mult$$
   exit 0
}

trap cleanup 1

usage()
{
    echo "Usage: $(basename $1) [-all] [-merge] [-sample] INSTALLDIR"
    echo "Options:"
    echo "   -all       install all usable languages, not just the core languages"
    echo "   -merge     merge multiple training files for a language+script into one"
    echo "   -mergetest merge multiple test/devtest files as well as training"
    echo "   -sample    install the Sample language texts"
    echo "   -devtrain  generate subset of training including only devtest langs"
    echo "   -r S       generate reduced-size training set of size S bytes"
    echo "   -j N       run N threads in parallel"
    echo "   -c         compress training sets with 'xz'"
    echo "   -help      show this help text"
    echo "Note: -r may be repeated to generate multiple reduced-size sets."
    exit $E_USAGE
}

strip_type()
{
    # filename is iso_COUNTRY.script.langname.source.*
    iso_ctry="${dest%%.*}"
    tail="${dest#*.}"
    scr="${tail%%.*}"
    tail="${tail#*.}"
    name="${tail%%.*}"
    source="$(echo ${tail#*.}|sed -e 's@^.*-comb-@comb-@')"
    dest="${iso_ctry}.${scr}.${name}.${source}"
    return
}

combine_files()
{
    strip_type dest
    iso="$1"
    scr="$2"
    kind="$3"
    if [ -z "$nocompress" ] ; then
	xzcat "${iso}_"*.${scr}.*-${kind}.*| xz -7e >"combine$$/$dest"
    else
	cat "${iso}_"*.${scr}.*-${kind}.* >"combine$$/$dest"
    fi
    rm "${iso}_"*.${scr}.*-${kind}.*
    mv "combine$$/$dest" .
    return
}

# generate test sets for the specified string size (tiny, small, medium, or long)
gen_testsets()
{
   mkdir -p "$topdir/extract$$/testsets-$1"
   pushd "$topdir/extract$$/testsets-$1" >/dev/null
   ln -s .. eval-data
   ln -s "$p/mktestset.sh" .
   bash $mktest -j $threads --$1
   $rm -f eval-data mktestset.sh
   popd >/dev/null
   mkdir "$topdir/extract$$/devtestsets-$1"
   pushd "$topdir/extract$$/devtestsets-$1" >/dev/null
   ln -s .. eval-data
   ln -s "$p/mktestset.sh" .
   bash $mktest -j $threads --$1 --devtest
   $rm -f eval-data mktestset.sh
   popd >/dev/null
   return
}

# set defaults
get_cpus

# process commandline arguments
while [[ $# -gt 0 && "x${1}" == x-* ]]
do
   interactive=""	# command line flags turn off interactive queries
   case "$1" in
      "-all" )
          do_all="y"
	  ;;
      "-sample" )
          do_samples="y"
	  ;;
      "-devtrain" )
	  do_devtrain="y"
	  ;;
      "-core" )
          do_core="y"
	  ;;
      "-nocore" )
          do_core=""
	  ;;
      "-merge" )
	  do_merge="y"
	  ;;
      "-mergetest" )
	  do_merge="y"
	  do_merge_test="y"
	  ;;
      "-r" | "-reduce" )
          shift
          if [ -n "$do_smalltrain" ] ; then
	     do_smalltrain="$do_smalltrain $1"
	  else
	     do_smalltrain="$1"
	  fi
          ;;
      "-j" )
          shift
          threads="$1"
	  ;;
      "-c" | "-comp" )
          nocompress=""
	  ;;
      "-u" | "-uncomp" )
          nocompress="-u"
	  ;;
      "-h" | "-help" | "--help" )
          show_help="y"
          ;;
      * )
          echo "Unrecognized option '$1'"
          show_help="y"
	  ;;
   esac
   shift
done

[[ ( $# == 0 && -z "$interactive" ) || -n "$show_help" ]] && usage "$0"

## evaluate the non-flag part of the command line
if [[ -z "$interactive" || $# -gt 0 ]] ; then
   interactive=""
   topdir="$1"
   [[ "x$topdir" != x/* ]] && topdir="${PWD}/$topdir"
fi

## with no arguments, ask the user for the most important items
if [ -n "$interactive" ] ; then
   echo -n "Destination directory: "
   read topdir
   [[ "x$topdir" != x/* ]] && topdir="${PWD}/$topdir"
   if [ -e "$topdir" ] ; then
      echo "$topdir already exists.  Proceed anyway? (y/N) "
      read answer
      if [[ "x$answer" != xy* && "x$answer" != xY* ]] ; then
         echo Installation cancelled.
         exit $E_CANTCREAT
      fi
   fi
   echo -n "Include 'Additional' languages? (y/N) "
   read answer
   [[ "x$answer" == xy* || "x$answer" == xY* ]] && do_all="y"
   echo -n "Copy 'Sample' languages? (y/N) "
   read answer
   [[ "x$answer" == xy* || "x$answer" == xY* ]] && do_samples="y"
   echo -n "Merge training data into single file per language+script pair? (y/N) "
   read answer
   [[ "x$answer" == xy* || "x$answer" == xY* ]] && do_merge="y"
   if [ -n "$do_merge" ] ; then
      echo -n "Merge test data into single file per language+script? (y/N) "
      read answer
      [[ "x$answer" == xy* || "x$answer" == xY* ]] && do_mergetest="y"
   fi
   echo -n "Compress training sets? (y/N) "
   read answer
   if [[ "x$answer" == xy* || "x$answer" == xY* ]] ; then
      nocompress=""
   else
      nocompress="-u"
   fi
   echo -n "Generate reduced-size training sets? (y/N) "
   read answer
   if [[ "x$answer" == xy* || "x$answer" == xY* ]] ; then
      echo -n "  Enter desired size(s) in bytes, separated by blanks: "
      read do_smalltrain
   else
      do_smalltrain=""
   fi   
   echo -n "Generate devtest-only training set(s)? (y/N) "
   read answer
   [[ "x$answer" == xy* || "x$answer" == xY* ]] && do_devtrain="y"
fi

# figure out top-level directory from which to install
if [ -e "$p/text" ] ; then 
   base="$p/text"
elif [ -e "$(dirname $p)/text" ] ; then
   base="$(dirname $p)/text"
else
   ## assume user has switched to top of distribution archive
   base="$PWD"
   [ -e "$base/text" ] && base="$base/text"
fi

# check for presence of helper scripts and programs
required_prog split-test.sh split
required_prog makealltestsets.sh mktest
required_prog reduce-training.sh sampletrain
required_prog xargs xargs

if [[ -e "$p/src/dehtmlize.C" && ! -e "$p/dehtmlize" ]] ; then
   echo "Attempting to compile helper program 'dehtmlize'"
   (cd "$p/src" ; make dehtmlize >/dev/null || echo Compilation failed &)
   (mv "$p/src/dehtmlize" "$p/" >&/dev/null)
elif [ ! -e "$p/dehtmlize" ] ; then
   echo "Missing helper program 'dehtmlize', please-reinstall"
   exit $E_OSFILE
fi

if [[ -e "$p/src/subsample.C" && ! -e "$p/subsample" ]] ; then
   echo "Attempting to compile helper program 'subsample'"
   (cd "$p/src" ; make subsample >/dev/null || echo Compilation failed &)
   (mv "$p/src/subsample" "$p/" >&/dev/null)
elif [ ! -e "$p/subsample" ] ; then
   echo "Missing helper program 'subsample', please re-install"
   exit $E_OSFILE
fi

## create the directory hierarchy in the user-requested location
mkdir -p "$topdir"
mkdir -p "$topdir/bin"
mkdir -p "$topdir/extract$$"
[ -n "$do_samples" ] && mkdir -p "$topdir/samples"

rm -f "$topdir/extract$$"/* >&/dev/null

## process the core languages into the extraction directory
if [ -n "$do_core" ] ; then
   echo Processing Core languages
   for i in "${base}"/*/
   do
      [ -e "$i" ] || continue
      dname="${i%/*}" ; dname="${dname##*/}"
      echo "   $dname"
      if [ -e "${i}/extract.sed" ] ; then
         "$ls" "${i}"/*xz | "$xargs" -n1 -P$threads bash "$split" -q -H --html-sedscript "${i}/extract.sed" -d "$topdir/extract$$" -p $testprop $nocompress --rm-full
      elif [ -e "${i}/extract-md.sed" ] ; then
         "$ls" "${i}"/*xz | "$xargs" -n1 -P$threads bash "$split" -q -H --md-sedscript "${i}/extract-md.sed" -d "$topdir/extract$$" -p $testprop $nocompress --rm-full
      else
         "$ls" "${i}"/*xz | "$xargs" -n1 -P$threads bash "$split" -q -H -d "$topdir/extract$$" -p $testprop $nocompress --rm-full
      fi
   done
fi

## process the additional languages, if requested
if [ -n "$do_all" ] ; then
   echo Processing Additional languages
   for i in "${base}"/*/Additional/
   do
      [ -e "$i" ] || continue
      dname="${i%/*/*}" ; dname="${dname##*/}"
      echo "   $dname"
      if [ -e "${i}/extract.sed" ] ; then
         "$ls" "${i}"/*xz | "$xargs" -n1 -P$threads bash "$split" -q -H --html-sedscript "${i}/extract.sed" -d "$topdir/extract$$" -p $testprop $nocompress --rm-full
      elif [ -e "${i}/extract-md.sed" ] ; then
         "$ls" "${i}"/*xz | "$xargs" -n1 -P$threads bash "$split" -q -H --md-sedscript "${i}/extract-md.sed" -d "$topdir/extract$$" -p $testprop $nocompress --rm-full
      else
         "$ls" "${i}"/*xz | "$xargs" -n1 -P$threads bash "$split" -q -H -d "$topdir/extract$$" -p $testprop $nocompress --rm-full
      fi
   done
fi

## install the sample texts, if requested
if [ -n "$do_samples" ] ; then
   echo Copying Sample languages
   cp -p "$base/"*"/Samples/"* "$topdir/samples"
   [ -n "$nocompress" ] && unxz "$topdir/samples/"*xz
fi

## merge multiple text files for a language, if requested
if [ -n "$do_merge" ] ; then
   echo Merging multiple files for the same language+script
   pushd "$topdir/extract$$" >/dev/null
   find . -maxdepth 1 -name "*-train.*" | sed -e 's@^.*/@@' -e 's@_[^.]*\([.][^.]*\)[.].*@\1@' | sort | uniq -c \
	| fgrep -v ' 1 ' | sed -e 's@^  *[1-9][0-9]*  *@@' | sort >/tmp/mult$$
   mkdir -p combine$$
   for i in `cat /tmp/mult$$`
   do
      iso="${i%.*}"
      scr="${i#*.}"
      dest="`ls "${iso}_"*.${scr}.*-train.*|head -1`"
      dest="${dest/-train/-comb-train}"
      [ -n "$dest" ] && combine_files $iso $scr train
      if [ -n "$do_merge_test" ] ; then
	 dest="`ls "${iso}_"*.${scr}.*-test.* 2>/dev/null |head -1`"
	 dest="${dest/-test/-comb-test}"
	 [ -n "$dest" ] && combine_files $iso $scr test
         dest="`ls "${iso}_"*.${scr}.*-devtest.* 2>/dev/null |head -1`"
	 dest="${dest/-devtest/-comb-devtest}"
	 [ -n "$dest" ] && combine_files $iso $scr devtest
      fi
   done
   rmdir combine$$
   popd >/dev/null
fi

have_test=""
pushd "$topdir/extract$$" >/dev/null
[[ `find -maxdepth 1 -name \*-test.\*|wc -l` != 0 ]] && have_test="y"
popd >/dev/null

if [ -n "$have_test" ] ; then
   echo Generating test sets
   echo "   Tiny (20-40 chars)"
   gen_testsets tiny
   echo "   Short (25-65 chars)"
   gen_testsets short
   echo "   Medium (80-120 chars)"
   gen_testsets medium
   echo "   Long (120-200 chars)"
   gen_testsets long
fi

## copy the utility programs and scripts
echo Compiling and copying utility programs
pushd "$p/src" >/dev/null
cp -p ../[ce]*.sh "$topdir/bin"
if make interleave score subsample >&/dev/null ; then
   strip interleave score subsample
   cp -p interleave score subsample "$topdir/bin"
   make clean >&/dev/null
else
   echo Compilation failed
fi
popd >/dev/null

## move the results into the final location
echo Moving files to destination directory
if [ -e "$(dirname $p)/ReleaseNumber" ] ; then
   cp -p "$(dirname $p)/ReleaseNumber" "$topdir/"
elif [ -e "$p/ReleaseNumber" ] ; then
   cp -p "$p/ReleaseNumber" "$topdir/"
fi
$rm -rf "$topdir/train/"
mkdir "$topdir/train"
if [ -z "$nocompress" ] ; then
   "$mv" "$topdir/extract$$/"*-train.utf8.xz "$topdir/train/" >&/dev/null
else
   "$mv" "$topdir/extract$$/"*-train.utf8 "$topdir/train/" >&/dev/null
fi
$rm -rf "$topdir/test/"
mkdir "$topdir/test"
"$mv" "$topdir/extract$$/"*-test.utf8 "$topdir/test/" >&/dev/null
$rm -rf "$topdir/devtest/"
mkdir "$topdir/devtest"
"$mv" "$topdir/extract$$/"*-devtest.utf8 "$topdir/devtest" >&/dev/null

for len in tiny short medium long
do
   if [ -e "$topdir/extract$$/testsets-$len" ] ; then
      "$rm" -rf "$topdir/testsets-$len"
      "$mv" "$topdir/extract$$/testsets-$len" "$topdir/"
   fi
   if [ -e "$topdir/extract$$/devtestsets-$len" ] ; then
      "$rm" -rf "$topdir/devtestsets-$len"
      "$mv" "$topdir/extract$$/devtestsets-$len" "$topdir/"
   fi
done

## generate sub-sampled training sets if requested
if [ -n "$do_smalltrain" ] ; then
   echo "Generating reduced-size training set(s)"
   for size in $do_smalltrain
   do
      echo "   $size bytes"
      rm -rf "$topdir/train-$size"
      mkdir -p "$topdir/train-$size"
      find "$topdir/train" -name \*.utf8 | xargs -n1 '-d\n' -P$threads bash "$sampletrain" "$size" "$topdir/bin/subsample"
      find "$topdir/train" -name \*.xz | xargs -n1 '-d\n' -P$threads bash "$sampletrain" "$size" "$topdir/bin/subsample"
   done
fi

## create subset 'devtrain' sets if requested
if [ -n "$do_devtrain" ] ; then
   for tr in "$topdir/train"*
   do
      rm -rf "$topdir/dev$(basename $tr)"
      mkdir -p "$topdir/dev$(basename $tr)"
      pushd "$topdir/dev$(basename $tr)" >/dev/null
      for lang in `find "$topdir/devtest" -maxdepth 1 -type f |sed -e 's@^.*/@@' -e 's@_.*@@'|sort -u`
      do
         ln -s -f "../$(basename $tr)/$lang"_* .
      done
      popd >/dev/null
   done
fi

## let the user know we've finished
train_files=`find "$topdir/train/" -maxdepth 1 -type f|wc -l`
test_files=`find "$topdir/test/" -maxdepth 1 -type f|wc -l`
devtest_files=`find "$topdir/devtest" -maxdepth 1 -type f|wc -l`
train_langs=`find "$topdir/train/" -maxdepth 1 -type f|sed -e 's@^.*/@@' -e 's@_.*@@'|sort -u|wc -l`
test_langs=`find "$topdir/test/" -maxdepth 1 -type f|sed -e 's@^.*/@@' -e 's@_.*@@'|sort -u|wc -l`
devtest_langs=`find "$topdir/devtest/" -maxdepth 1 -type f|sed -e 's@^.*/@@' -e 's@_.*@@'|sort -u|wc -l`
[ $train_langs != $test_langs ] && echo Error: number of training and test languages differ
echo Installation complete, generated $train_files training files and $test_files test files for $train_langs
echo languages, as well as $devtest_files development/tuning files for $devtest_langs languages.
if [ -n "$do_samples" ] ; then
   sample_files=`find "$topdir/samples/" -maxdepth 1 -type f -not -name 00README |wc -l`
   sample_langs=`find "$topdir/samples/" -maxdepth 1 -type f -not -name 00README |sed -e 's@^.*/@@' -e 's@_.*@@'|sort -u|wc -l`
   echo Copied $sample_files sample files for $sample_langs languages.
fi

cleanup

exit 0
