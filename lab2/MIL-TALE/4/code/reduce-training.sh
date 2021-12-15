#!/bin/bash
# LastEdit: 02sep2015

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

size="$1"
sampler="$2"
input="$3"

[[ -n "$size" && -n "$input" && -e "$input" && -n "$sample" && -e "$sampler" ]] || exit 1

ext="${input##*.}"
output="${input%/*}-${size}/${input##*/}"

#echo "sampling $input to $output ($size bytes)"
#exit 0

if [ "$ext" == "xz" ] ; then
  xzcat "$input" | "$sampler" -b "$size" | xz -7 >"$output"
else # ext==utf8, usually
  "$sampler" -b "$size" <"$input" >"$output"
fi

exit 0
