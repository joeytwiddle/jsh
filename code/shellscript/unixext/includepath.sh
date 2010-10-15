#!/bin/sh
# Usage: . includepath <root-prefix>

## TODO: maybe rename or alias it to "addroot", to re-use chroot terminology.

## TODO: absoluteise "$1" in case user is being lazy?

## Random thought: I would like to add more clever stuff to jsh
##                 eg. scripts such as these which should be sourced could try to check this with eg. ". ishouldbesourced" (actually I doubt that would work easily!)
##                 But I find myself stopping myself
##                 When I realise that really scripts should be higher-order and compiled and in fact no longer pure sh at all.
##                 I'm not ready to go that far, so it seems silly to try to add more advanced stuff to jsh out of proportion with its limitations.
## Conclusion: keep it hacky (philosophy unchanged!)

if test "$1" = -after
then
	NEWROOT="$2"
	PATH="$PATH:$NEWROOT/bin:$NEWROOT/usr/bin"
	MANPATH="$MANPATH:$NEWROOT/man"
	LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NEWROOT/lib:$NEWROOT/usr/lib"
else
	NEWROOT="$1"
	PATH="$NEWROOT/bin:$NEWROOT/usr/bin:$PATH"
	MANPATH="$NEWROOT/man:$MANPATH"
	LD_LIBRARY_PATH="$NEWROOT/lib:$NEWROOT/usr/lib:$LD_LIBRARY_PATH"
fi

export PATH;
export MANPATH;
export LD_LIBRARY_PATH;
