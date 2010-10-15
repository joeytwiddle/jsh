#!/bin/sh
if test ! -e "$1"; then
  echo "$@ does not exist"
fi
