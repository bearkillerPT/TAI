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

create_lang_equiv_script()
{
    cat >"$1" <<EOF
s/^acm/ar/
s/^apd/ar/
s/^ary/ar/
s/^arz/ar/
s/^shu/ar/
s/^gsw/de/
s/^pfl/de/
s/^pdc/de/
s/^bar/de/
s/^vls/nl/
s/^zea/nl/
s/^jai/jac/
s/^id	/zsm	/
s/^bs	/hr	/
s/^p[er]s/fas/
s/^glk/fas/
s/^kpv/kv/
s/^kaz/kk/
s/^tz[cesu]/tzz/
s/^qu[bfghjlptwyz]/qu/
s/^qv[cehimnoswz]/qu/
s/^qwh/qu/
s/^qx[hnor]/qu/
s/azz/nah/
s/nc[hjl]/nah/
s/ngu/nah/
s/nh[eiw]/nah/
s/^csy/ctd/
s/^pck/ctd/
s/^zom/ctd/
s/^yue/cmn/
s/^zh	/cmn	/
s/^wuu/cmn/
s/^gan/cmn/
s/^plt/mg/
s/^tpi/pe/
s/^pcm/pe/
s/^ckb/ku/
s/^kmr/ku/
s/^sdh/ku/
s/^tot/tku/
s/^acc/acr/
EOF
### Egyptian, Chadian, and Moroccan Arabic -> Arabic (MSA)
### SwissGerman, Bavarian, Palatinate, PADutch -> German
### Vlaams, Zealandic -> Dutch
### Indonesian -> Standard Malay
### Bosnian -> Croatian
### Eastern/Western Farsi, Gilaki -> Farsi macro-language
### Komi-Zyrian -> Komi
### various Tzotzils -> Tzotzil Zinacantan
### all Quechuas and Quichuas -> Quechua macro-language
### all Nahuatls -> Aztecan
### Sorani(Central) Kurdish and Kurmanji (Northern Kurdish) -> Kurdish macro-l
### Sizang/Paite Chin and Zomi -> Tedim Chin (all Northern Kuki-Chin languages)
### Wu/Gan Chinese and Cantonese -> Mandarin Chinese
### Plateau Malagasy -> Malagasy
### Tok Pisin and Nigerian Pidgin to Pidgin English
### Patla-Chicontla Totonac (obsoleted ISO) -> Upper Necaxa Totonac
### Achi-de-Cubulco (obsoleted ISO) -> Achi Rabinal
   return
}

setup_overhead()
{
    # nothing to be done
    smoothing=""
    cat >"$1" <<EOF
EOF
    return
}

setup_langdetect()
{
    #required_prog langdetect langdetect
    if [ -z "$ldjar" ] ; then
        echo Did not find langdetect.jar.
	exit 1
    fi
    default_file langdetect-profiles lddir "Language model"
    [ -n "$smoothing" ] && smoothing="-S $smoothing"
    # reformat output and remove model-specific digits; optionally also strip out echoed input
    cat >"$1" <<'EOF'
s@^[^:]*:\[\([^:]*\):[0-9.]*\]$@\1	@
s@^\([^	0-9]*\)[0-9][0-9]*	@\1	@
EOF
    [ -n "$2" ] && cat >>"$1" <<EOF
s/	.*//
EOF
    return
}

setup_langidpy()
{
    required_prog langid-rb.py lidpy
    landigpy="python $lidpy"
    default_file model lpymodel "Language model"
    [ -n "$smoothing" ] && echo Frequency smoothing ignored for langid.py -- Not Yet Implemented
    smoothing=""
    # reformat output and remove model-specific digits; optionally also strip out echoed input
    cat >"$1" <<'EOF'
s@^[(]'\([^']*\)',.*[)]$@\1	@
s@^\([^	0-9]*\)[0-9][0-9]*	@\1	@
EOF
    [ -n "$2" ] && cat >>"$1" <<EOF
s/	.*//
EOF
    return
}

setup_mguesser()
{
    required_prog mguesser mguesser
    default_file mguesser-maps mgdir "Language model"
    [ -n "$smoothing" ] && smoothing="-s$smoothing"
    # strip out echoed input from results
    echo "" >"$1"
    [ -n "$2" ] && cat >>"$1" <<EOF
s/	.*//
EOF
    return
}

setup_textcat()
{
    required_prog testtextcat textcat
    default_file textcat-lm tcdir "Language model"
    [ -n "$smoothing" ] && smoothing="-s$smoothing"
    # strip out echoed input from results
    echo "" >"$1"
    [ -n "$2" ] && cat >>"$1" <<EOF
s/	.*//
EOF
    return
}

setup_whatlang()
{
    required_prog whatlang whatlang
    [[ -z "$raw_only" && ! -e "$strings" ]] && required_prog la-strings strings
    default_file languages.db db "Language model"
    [ -n "$smoothing" ] && echo Frequency smoothing ignored for whatlang -- must be applied while building models
    smoothing=""
    # strip out echoed input from results
    echo "" >"$1"
    [ -n "$2" ] && cat >>"$1" <<EOF
s/	.*//
EOF
    return
}

setup_YALI()
{
    required_prog yali-identifier
    required_prog yali-models.sh yalimod
    [ -n "$smoothing" ] && smoothing="--smooth $smoothing"
    # build the model list if it doesn't yet exist
    [ ! -e "$yalidir/models" ] && "$yalimod" "$yalidir"
    default_file yali-models yalidir "Language model"
    # ensure non-empty ids and a tab on each line so that subsequent
    #   processing works correctly; also strip off per-model disambiguating digits
    cat >"$1" <<EOF
s@^\$@UNK@
s@\$@	@
s@^\([^	0-9]*\)[0-9][0-9]*	@\1	@
EOF
    [ -n "$2" ] && cat >>"$1" <<EOF
s/	.*//
EOF
    [ -n "$twoletter"] && cat >>"$1" <<EOF
s@^afr@af@
#s@^@am@
s@^arg@an@
s@^ara@ar@
#s@^@ay@
#s@^@az@
#s@^@ba@
s@^bul@bg@
#s@^@bn@
#s@^@bo@
#s@^@br@
s@^bos@bs@
s@^cat@ca@
#s@^@ce@
#s@^@ch@
#s@^@co@
s@^ces@cs@
#s@^@cv@
s@^cym@cy@
s@^dan@da@
s@^deu@de@
#s@^@dv@
#s@^@el@
s@^eng@en@
#s@^@eo@
s@^spa@es@
s@^est@et@
s@^eus@eu@
s@^fin@fi@
#s@^@fo@
s@^fra@fr@
#s@^@ga@
#s@^@gd@
#s@^@gl@
#s@^@gu@
#s@^@gv@
s@^hat@ha@
s@^heb@he@
#s@^@hi@
s@^hrv@hr@
#s@^@ht@
#s@^@hu@
s@^hye@hy@
#s@^@id@
#s@^@ig@
#s@^@io@
s@^isl@is@
s@^ita@it@
#s@^jpn@ja@
#s@^@jv@
#s@^@ka@
#s@^@kg@
#s@^@kk@
#s@^@kl@
#s@^@kn@
s@^kor@kr@
#s@^@ku@
#s@^@kv@
#s@^@kw@
#s@^@ky@
#s@^@la@
#s@^@lt@
#s@^@lv@
#s@^@mg@
#s@^@mi@
s@^mkd@mk@
#s@^@ml@
#s@^@mn@
#s@^@mr@
#s@^@mt@
#s@^@my@
#s@^@nd@
#s@^@ne@
#s@^@nl@
s@^nno@nn@
s@^nor@no@
#s@^@oc@
s@^oss@os@
#s@^@pa@
s@^pol@pl@
s@^por@pt@
s@^ron@ro@
s@^rus@ru@
#s@^@rw@
#s@^@sc@
#s@^@se@
#s@^@si@
s@^slk@sk@
s@^slv@sl@
#s@^@so@
s@^srp@sr@
#s@^@st@
#s@^@su@
s@^swe@sv@
s@^swa@sw@
s@^tam@ta@
s@^tel@te@
#s@^@tg@
s@^tha@th@
#s@^@ti@
#s@^@tk@
s@^tgl@tl@
#s@^@tn@
#s@^@to@
s@^tur@tr@
#s@^@ts@
#s@^@ug@
s@^ukr@uk@
s@^urd@ur@
s@^uzb@uz@
s@^vie@vi@
#s@^@vo@
#s@^@wa@
#s@^@wo@
s@^xho@xh@
s@^yid@yi@
s@^yor@yo@
s@^zho@zh@
s@^zul@zu@
EOF
    return
}

## end of file
