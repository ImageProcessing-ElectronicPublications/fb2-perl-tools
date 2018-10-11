#!/bin/sh

tfb2=$1
if [ -f "$tfb2" ]
then
    for ti in $(./fb2images.pl -l "$tfb2")
    do
        ./fb2images.pl -r "$ti" "$tfb2"
    done
else
    echo "USAGE: $0 file.fb2"
fi
