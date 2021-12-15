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


# error returns
E_USAGE=64
E_NOINPUT=66
E_UNAVAILABLE=69
E_OSFILE=72
E_CANTCREAT=73

get_cpus()
{
    proc_cpu=/sys/devices/system/cpu/online
    [ -e "$proc_cpu" ] && let "threads = 1 -  `cat $proc_cpu| sed -e 's/-/ - -/'`"
    return
}

required_prog()
{
    if [ -n "$2" ] ; then
	eval "r_prog=\$$2"
	[[ -n "$r_prog" && -e "$r_prog" ]] && return
    fi
    r_prog=""
    [ -e "./$1" ] && r_prog="$PWD/$1"
    [ -e "bin/$1" ] && r_prog="$PWD/bin/$1"
    [[ -n "$p" && -e "$p/$1" ]] && r_prog="$p/$1"
    [[ -n "$p" && -e "$p/bin/$1" ]] && r_prog="$p/bin/$1"
    [ -z "$r_prog" ] && r_prog="`command -v $1`"
    [[ -z "$r_prog" && -n "$p" && -e "$p/$1" ]] && r_prog="$p/$1"
    if [ -n "$r_prog" ] ; then
       [ -n "$2" ] && eval "$2=\$r_prog"
    else
       echo "Required program '$1' not found.  Please install and re-run."
       exit $E_OSFILE
    fi
    return
}

optional_prog()
{
    o_prog=""
    [ -e "./$1" ] && o_prog="$PWD/$1"
    [ -e "bin/$1" ] && o_prog="$PWD/bin/$1"
    [ -z "$o_prog" ] && o_prog="`command -v $1`"
    [ -z "$o_prog" && -n "$p" && -e "$p/$1" ] && o_prog="$p/$1"
    [ -n "$o_prog" && -n "$2" ] && eval "$2=\$o_prog"
    return
}

required_file()
{
    if [ -n "$2" ] ; then
	eval "r_file=\$$2"
	[[ -n "$r_file" && -e "$r_file" ]] && return
    fi
    r_file=""
    [ -e "./$1" ] && r_file="$PWD/$1"
    [ -e "bin/$1" ] && r_file="$PWD/bin/$1"
    [ -n "$p" && -e "$p/$1" ] && r_file="$p/$1"
    [ -z "$r_file" && -n "$p" && -e "$p/$1" ] && r_file="$p/$1"
    if [ -n "$r_file" ] ; then
       [ -n "$2" ] && eval "$2=\$r_file"
    else
       echo "Required file '$1' not found.  Please install/create and re-run."
       exit $E_OSFILE
    fi
    return
}

default_file()
{
    if [ -n "$2" ] ; then
	eval "d_file=\$$2"
	[[ -n "$d_file" && -e "$d_file" ]] && return
    fi
    d_file=""
    [ -e "./$1" ] && d_file="$PWD/$1"
    [ -z "$d_file" && -e "$d/$1" ] && d_file="$d/$1"
    [ -z "$d_file" && -e "$d/models/$1" ] && d_file="$d/models/$1"
    [ -z "$d_file" && -e "bin/$1" ] && d_file="$PWD/bin/$1"
    [ -z "$d_file" && -e "$p/$1" ] && d_file="$p/$1"
    if [ -n "$d_file" ] ; then
	[ -n "$2" ] && eval "$2=\$d_file"
    else
	desc="${3:Data file}"
	echo "$3 '$1' not found."
        exit $E_NOINPUT
    fi
    return
}

encoding_from_filename()
{
    enc="${2:-utf8}"
    if [[ "$1" =~ *latin1* ]] ; then
	enc=iso-8859-1
    elif [[ "$1" =~ *latin2* ]] ; then
        enc=iso-8859-2
    elif [[ "$1" =~ *latin3* ]] ; then
        enc=iso-8859-3
    elif [[ "$1" =~ *latin4* ]] ; then
        enc=iso-8859-4
    elif [[ "$1" =~ *latin5* ]] ; then
        enc=iso-8859-5
    elif [[ "$1" =~ *euc-jp* ]] ; then
        enc=euc-jp
    elif [[ "$1" =~ *euc-kr* ]] ; then
        enc=euc-kr
    elif [[ "$1" =~ *euc-tw* ]] ; then
        enc=euc-tw
    elif [[ "$1" =~ *gb2312* ]] ; then
	enc="gb2312"
    elif [[ "$1" =~ *win1250* ]] ; then
	enc=windows-1250
    elif [[ "$1" =~ *win1251* ]] ; then
	enc=windows-1251
    elif [[ "$1" =~ *win1252* ]] ; then
	enc=windows-1252
    elif [[ "$1" =~ *win1256* ]] ; then
	enc=windows-1256
    fi
    return
}

## end of file ##
