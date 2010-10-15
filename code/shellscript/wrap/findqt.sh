#!/bin/sh
find "$@" | sed "s| |\\\\\ |" | sed "s|^|\"|" | sed "s|$|\"|" | tr "\n" " "
