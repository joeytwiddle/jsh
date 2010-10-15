#!/bin/sh
TMPDIR=`jgettmp unzip`
rm -f "$TMPDIR"
mkdir -p "$TMPDIR"
cp "$@" "$TMPDIR"
cd "$TMPDIR"
gunzip *
konqueror *
