#!/bin/sh
# On xterm with white bg, this comes out as black!  Or does it?  It seems to be better to use cursenorm than cursewhite.
printf "\033[01;37m"
