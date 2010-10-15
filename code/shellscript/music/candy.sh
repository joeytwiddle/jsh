#!/bin/sh
mpg123 -s "$@" | synaesthesia pipe 44100
