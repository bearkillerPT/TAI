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

# select the compiler
CC=gcc
CPP=g++

# general compilter flags
CCFLAGS=-Wall

# assume at least an AMD Athlon64 or 64-bit-capable Intel CPU
CPUDEF=-march=native -m64

# optimization flags: full optimization or debug build?
OPTFLAGS=-O3
#OPTFLAGS=-Og -ggdb3

all: \
	bin/interleave \
	bin/icuconv \
	bin/icutrans \
	bin/dedup \
	bin/dehtmlize \
	bin/score \
	bin/subsample \
	bin/utf8hist

strip:
	strip bin/*

clean:
	rm bin/*
	rmdir bin

bin/dedup: src/dedup.C

bin/dehtmlize: src/dehtmlize.C

bin/interleave: src/interleave.c

bin/icuconv: src/icuconv.C
	@mkdir -p bin
	$(CPP) $(OPTFLAG) $(CPUDEF) $(CCFLAGS) -o $@ $< -licuuc

bin/icutrans: src/icutrans.C
	@mkdir -p bin
	$(CPP) $(OPTFLAG) $(CPUDEF) $(CCFLAGS) -o $@ $< -licuuc -licutu -licui18n

bin/score: src/score.C

bin/utf8hist: src/utf8hist.C

bin/subsample: src/subsample.C

#########################################################################
# define the default compile rule

bin/% : src/%.C
	@mkdir -p bin
	$(CPP) $(OPTFLAG) $(CPUDEF) $(CCFLAGS) -o $@ $<

