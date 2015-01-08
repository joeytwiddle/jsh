#!/bin/sh

TARGET_FOLDER=`lastarg "$@"`

mkdir -p "$TARGET_FOLDER" &&

mv "$@"
