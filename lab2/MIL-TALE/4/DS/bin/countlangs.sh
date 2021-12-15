#!/bin/bash

# find out where this script is located
p="$(dirname $0)"
[ "x$p" != "x." ] || p="$PWD"
[[ "x$p" == x/* ]] || p="$PWD/$p"
# by default, assume we were in the 'code' subdir of the LangID corpus
base="${p}/../text"

[ -n "$1" ] && base="$1"

[ ! -e "${base}/Wikipedia" ] && [ -e "${base}/text" ] && base="${base}/text"
[ ! -e "${base}/Wikipedia" ] && echo "Corpus not found" && exit 1

wiki_core="$(ls ${base}/Wikipedia/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
wiki_add="$(ls ${base}/Wikipedia/Additional/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
wiki_samp="$(ls ${base}/Wikipedia/Samples/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
wiki_tot="$(ls ${base}/Wikipedia/{,Additional/,Samples/}*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

ebib_core="$(ls ${base}/ebible.org/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
ebib_add="$(ls ${base}/ebible.org/Additional/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
ebib_samp="$(ls ${base}/ebible.org/Samples/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
ebib_tot="$(ls ${base}/ebible.org/{,Additional/,Samples/}*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

bcom_core="$(ls ${base}/bible.com/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
bcom_add="$(ls ${base}/bible.com/Additional/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
bcom_samp="$(ls ${base}/bible.com/Samples/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
bcom_tot="$(ls ${base}/bible.com/{,Additional/,Samples/}*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

borg_core="$(ls ${base}/bibles.org/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
borg_add="$(ls ${base}/bibles.org/Additional/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
borg_samp="$(ls ${base}/bibles.org/Samples/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
borg_tot="$(ls ${base}/bibles.org/{,Additional/,Samples/}*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

se_core="$(ls ${base}/ScriptureEarth/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
se_add="$(ls ${base}/ScriptureEarth/Additional/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
se_samp="$(ls ${base}/ScriptureEarth/Samples/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
se_tot="$(ls ${base}/ScriptureEarth/{,Additional/,Samples/}*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

d43_core="$(ls ${base}/Door43/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
d43_add="$(ls ${base}/Door43/Additional/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
d43_samp="$(ls ${base}/Door43/Samples/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
d43_tot="$(ls ${base}/Door43/{,Additional/,Samples/}*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

png_core="$(ls ${base}/PNG.Bible/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
png_add="$(ls ${base}/PNG.Bible/Additional/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
png_samp="$(ls ${base}/PNG.Bible/Samples/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
png_tot="$(ls ${base}/PNG.Bible/{,Additional/,Samples/}*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

allb_core="$(ls -1d ${base}/{bible.com,bibles.org,Door43,ebible.org,eWord,PNG.Bible,PublicDomain,ScriptureEarth}/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
allb_add="$(ls -1d ${base}/{bible.com,bibles.org,Door43,ebible.org,eWord,PNG.Bible,PublicDomain,ScriptureEarth}/Additional/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
allb_samp="$(ls -1d ${base}/{bible.com,bibles.org,Door43,ebible.org,eWord,PNG.Bible,PublicDomain,ScriptureEarth}/Samples/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
allb_tot="$(ls -1d ${base}/{bible.com,bibles.org,Door43,ebible.org,eWord,PNG.Bible,PublicDomain,ScriptureEarth}/{,Additional/,Samples/}*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

ep_core="$(ls -1d ${base}/Europarl/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
ep_add="$(ls -1d ${base}/Europarl/Additional/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
ep_samp="$(ls -1d ${base}/Europarl/Samples/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
ep_tot="$(ls -1d ${base}/Europarl/{,Additional/,Samples/}*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

oth_core="$(ls -1d ${base}/{OtherBibles,ProjectGutenberg}/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
oth_add="$(ls -1d ${base}/{OtherBibles,ProjectGutenberg}/Additional/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
oth_samp="$(ls -1d ${base}/{OtherBibles,ProjectGutenberg}/Samples/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
oth_tot="$(ls -1d ${base}/{OtherBibles,ProjectGutenberg}/{,Additional/,Samples/}*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"

all_core="$(ls ${base}/*/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
all_add="$(ls ${base}/*/Additional/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
all_samp="$(ls ${base}/*/Samples/*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
all_tot="$(ls ${base}/*/{,Additional/,Samples/}*xz|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"


echo "========= 	Core	Add	Sample	Total	===="
echo "ebible.org	${ebib_core}	${ebib_add}	${ebib_samp}	${ebib_tot}"
echo "ScriptureEarth	${se_core}	${se_add}	${se_samp}	${se_tot}"
echo "Door43.org	${d43_core}	${d43_add}	${d43_samp}	${d43_tot}"
echo "bible.com 	${bcom_core}	${bcom_add}	${bcom_samp}	${bcom_tot}"
echo "bibles.org 	${borg_core}	${borg_add}	${borg_samp}	${borg_tot}"
echo "PNG.Bible 	${png_core}	${png_add}	${png_samp}	${png_tot}"
echo "*AllBibles   	${allb_core}	${allb_add}	${allb_samp}	${allb_tot}"
echo "Wikipedia 	${wiki_core}	${wiki_add}	${wiki_samp}	${wiki_tot}"
echo "Europarl    	${ep_core}	${ep_add}	${ep_samp}	${ep_tot}"
echo "Other     	${oth_core}	${oth_add}	${oth_samp}	${oth_tot}"
echo "*Overall  	${all_core}	${all_add}	${all_samp}	${all_tot}"

if [ -e ${base}/Restricted ]; then
  rst_core="$(ls ${base}/Restricted/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
  rst_add="$(ls ${base}/Restricted/Additional/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
  rst_samp="$(ls ${base}/Restricted/Samples/*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
  rst_tot="$(ls ${base}/Restricted/{,Additional/,Samples/}*xz 2>/dev/null|sed -e 's@^.*/@@' -e 's@_.*$@@'|sort -u|wc -l)"
  echo "[Restrict]  	${rst_core}	${rst_add}	${rst_samp}	${rst_tot}"
fi

echo -n "Distinct scripts in corpus: "
ls ${base}/*/{,Additional/,Samples/}*xz \
    | sed -e 's@^.*/@@' -e 's@[.]t*xz@@' -e 's@[.]utf8@@' -e 's@^[^.]*[.]\([a-z][a-z][a-z][a-z]\)[.].*@\1@' \
	  -e 's@^[^.]*[.]\([a-z][a-z][a-z]\)[.].*@\1@' -e 's@^han[st]$@han@'|sort -u|wc -l

exit 0
