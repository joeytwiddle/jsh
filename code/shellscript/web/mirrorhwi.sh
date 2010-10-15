#!/bin/sh
if test "x$1" = "x"; then
  DESTDIR="/home/pgrad/pclark/public_html/hwimirror"
else
  DESTDIR="$1"
fi
mkdir -p $DESTDIR
cd $DESTDIR
wget -A html -l 2 -r -N http://hwi.dyn.dhs.org/
