#!/bin/sh

tnocomp=""
tcomp="identify"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="jpegtran"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="gifsicle"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="optipng"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="advpng"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="stat"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
if [ "+$tnocomp" != "+" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

tfb2=$1
if [ -f "$tfb2" ]
then
    for ti in $(./fb2images.pl -l "$tfb2")
    do
        ./fb2images.pl -x "$ti" "$tfb2"
        TYPE=$(identify "$ti" | grep -E -o 'JPEG|GIF|PNG')
        tsz0=$(stat -c %s "$ti")
        echo "$ti: $tsz0"
        case "$TYPE" in
            JPEG)
                tmpjp="$ti.p.$$.jpg"
                tmpjn="$ti.n.$$.jpg"
                jpegtran -copy none -optimize -perfect -progressive -outfile "$tmpjp" "$ti"
                jpegtran -copy none -optimize -perfect -outfile "$tmpjn" "$ti"
                if [ -f "$tmpjp" -a -f "$tmpjn" ]; then
                    S_PROG=$(stat -c %s "$tmpjp")
                    S_NORM=$(stat -c %s "$tmpjn")
                    echo " normal: $S_NORM"
                    echo " progressive: $S_PROG"
                    if [ $S_PROG -ge $S_NORM ]
                    then
                        mv -f "$tmpjn" "$ti"
                        rm -f "$tmpjp"
                    else
                        mv -f "$tmpjp" "$ti"
                        rm -f "$tmpjn"
                    fi
                fi
            ;;
            GIF)
                gifsicle -O2 -b "$ti"
            ;;
            PNG)
                optipng  -q -fix "$ti"
                tsize=$(stat -c %s "$ti")
                echo " optipng: $tsize"
                advpng -z -4 -q "$ti"
                tsize=$(stat -c %s "$ti")
                echo " advpng: $tsize"
            ;;
        esac
        tsz1=$(stat -c %s "$ti")
        if [ $tsz1 -lt $tsz0 ]
        then
            echo " $((100*$tsz1/$tsz0))%"
            ./fb2images.pl -r "$ti" "$tfb2"
            ./fb2images.pl -a "$ti" "$tfb2"
        else
            echo " (skip)"
        fi
        rm -fv "$ti"
    done
else
    echo "USAGE: $0 file.fb2"
fi
