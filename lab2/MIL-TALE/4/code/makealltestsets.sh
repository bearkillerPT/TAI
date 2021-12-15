#!/bin/bash
# LastEdit: 21feb2018

#  (c) Copyright 2012,2013,2014,2015,2018 Ralf Brown/Carnegie Mellon University	
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
def_min=25
def_max=65
def_minline=100
min=$def_min
max=$def_max
minline=$def_minline
threads="4"
testtype="test"

# find out where this script is located
p="$(dirname $0)"
[ "x$p" != "x." ] || p="$PWD"
[[ "x$p" == x/* ]] || p="$PWD/$p"
# load support functions
[ -e "$p/rbfuncs.sh" ] || { echo "Support functions not found.  Please re-install." ; exit 1 ; }
. $p/rbfuncs.sh

usage()
{
    echo "Usage: $(basename $1) [options]"
    echo "Options:"
    echo "  -j N      run N threads in parallel"
    echo "  --min N   set minimum line length to N bytes"
    echo "  --max N   set maximum line length to N characters"
    echo "  --tiny    shorthand for --min 20 --max 40"
    echo "  --short   shorthand for --min $def_min --max $def_max (default)"
    echo "  --medium  shorthand for --min 80 --max 120"
    echo "  --long    shorthand for --min 120 --max 200"
    echo "  --devtest use *-devtest files instead of *-test"
    exit $E_USAGE
}

# set defaults
get_cpus

# process commandline arguments
while [[ $# -gt 0 && "x${1}" == x-* ]]
do
   case "$1" in
      '--min' )
         shift
	 min="$1"
	 ;;
      '--max' )
         shift
	 max="$1"
	 ;;
      '--lines' )
         shift
	 minline="$1"
	 ;;
      '-j' )
         shift
         threads="$1"
	 ;;
      '--devtest' )
	 testtype="devtest"
	 ;;
      '--tiny' )
         min=20
	 max=40
	 ;;
      '--short' )
         min=$def_min
	 max=$def_max
	 minline=$def_minline
	 ;;
      '--medium' )
         min="80"
	 max="120"
	 ;;
      '--long' )
         min="120"
	 max="200"
	 ;;
      '--help' )
	 usage "$0"
	 ;;
      * )
         echo "Unknown option '$1'"
	 usage "$0"
	 ;;
   esac
   shift
done

required_prog mktestset.sh mktest
required_prog xargs xargs

shopt -s nullglob
ls eval-data/*.*-${testtype}.* eval-data/*/*.*-${testtype}.* | \
    grep -v -e '~$' -e '[.]unused$' -e '[.]bak$' -e '/unused/' | \
    "$xargs" -n1 '-d\n' -P$threads "$mktest" -l auto -m "$minline" "$min" "$max"

# some overrides of the above automatic language selection
"$mktest" -q -l ipk -m "$minline" "$min" "$max" eval-data/ScriptureEarth/esk_US.Inupiatun-NW-Alaska-test.utf8

## character-set overrides
if [ -e eval-data/pt_PT.Dwelle-test.latin1.txt ]; then
    (export LC_ALL=pt_PT.iso-8859-1 ; "$mktest" -q -l auto -m "$minline" $min $max eval-data/pt_PT.Dwelle-test.latin1.txt )
fi
if [ -e eval-data/Misc/jiv_EC.Shuar-test.latin1.txt ]; then
    (export LC_ALL=pt_PT.iso-8859-1 ; "$mktest" -q -l auto -m "$minline" $min $max eval-data/Misc/jiv_EC.Shuar-test.latin1.txt )
fi
if [ -e eval-data/ro_RO.Romanian-DWelle-test.latin2.txt ]; then
    (export LC_ALL=ro_RO.iso-8859-2 ; "$mktest" -q -l auto -m "$minline" $min $max eval-data/ro_RO.Romanian-DWelle-test.latin2.txt )
fi

exit 0
