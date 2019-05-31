#!/usr/bin/env bash

if [ -n "$1" ]
then COLUMNS="$1"; shift
fi

if [ -z "$COLUMNS" ]
then COLUMNS="$(tput cols)"
fi

cut -c1-"$COLUMNS"
