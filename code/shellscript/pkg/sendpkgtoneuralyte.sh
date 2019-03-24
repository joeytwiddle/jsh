#!/bin/sh

## This is like getpkgfromhwi, but works in the opposite direction.  This pushes a package from the current machine to the remote machine, where it may be used via 'includepath'.

PKGNAME="$1"
DESTFOLDER="myroots_64/$PKGNAME"

dpkg -L $PKGNAME | filesonly -inclinks | withalldo tar cjv |
ssh joey@neuralyte.org "mkdir '$DESTFOLDER' && cd '$DESTFOLDER' && tar xj"

