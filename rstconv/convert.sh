#!/usr/bin/env bash


rst2html5.py \
    --stylesheet-path `dirname "$0"`/docutils_basic.css \
    "$1" "$2"
