#!/bin/sh
cat "$@" | tr -d "\015"
