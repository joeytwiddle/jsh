#!/bin/bash

TMP=`jgettmp getenvlike-$1`

(

echo "# Clear current environment."
env |
sed 's+^\([^=]*\)=\(.*\)$+export \1=""+;
     s+^[^=]*$++'

echo

echo "# Restore given environment."
cat "$1" |
sed 's+^\([^=]*\)=\(.*\)$+export \1="\2"+;
     s+^[^=]*$++'

echo
echo "zsh"

) |
sed "s/^.*'$//" |
sed "s+^export \(.\|'.'\|EUID\|WORDCHARS\)=.*$++" > $TMP

chmod a+x $TMP

$TMP

# jdeltmp $TMP

