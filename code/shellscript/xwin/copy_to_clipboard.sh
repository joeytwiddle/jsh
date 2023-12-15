#!/usr/bin/env bash

if [ "$(uname)" = Darwin ]
then
	cat "$@" | pbcopy
else
	cat "$@" | xclip -selection c
fi
