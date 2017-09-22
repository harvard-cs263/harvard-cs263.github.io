#!/usr/bin/env bash


mkdir -p "$2"

for rst in `ls "$1"`; do
    if grep -qF .rst <<< "$rst" ; then
        `dirname "$0"`/convert.sh "$1"/"$rst" "$2"/"${rst%.*}".html
    fi
done
