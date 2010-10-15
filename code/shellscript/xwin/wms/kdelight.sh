#!/bin/sh
## startkde is slow and worst of all it keeps its loading banner on top of other windows even when they become usable.
## kdelight is intended to start the kwin window manager ASAP, without breaking KDE.  (Thus is actually starts kdeinit first.)
## it also starts the KDE panel kicker, but you don't get a desktop, or any other business startkde might bring with it.

# kwin > /tmp/kwin-$DISPLAY.log 2>&1 &
# sleep 2
# kicker > /tmp/kicker-$DISPLAY.log 2>&1 &
# wait

## TODO: I reduced the sleep times on my faster machine.  Maybe I can detect the optimum time by looking at logfile/stdout of processes?

## Dirty: I start kdeinit and kicker, but fluxbox/compiz instead of kwin!  I can do this early, so I do.
[ "$RUNNING_GENTOO" = 1 ] && TRY_FLUXBOX=true
! which kwin >/dev/null 2>&1 && ! which compiz >/dev/null 2>&1 && TRY_FLUXBOX=true
TRY_FLUXBOX=true
if [ "$TRY_FLUXBOX" ] && [ ! "$DISPLAY" = ":1.0" ]
then
	jshinfo "[kdelight] Starting fluxbox window manager"
	jshinfo "[kdelight]   PATH=$PATH fluxbox=`which fluxbox`"
	fluxbox > /tmp/fluxbox-$DISPLAY.log 2>&1 &
	# $HOME/bin/fluxbox.local > /tmp/fluxbox-$DISPLAY.log 2>&1 &
elif [ "$RUNNING_GENTOO" = 0 ]
then
	compiz &
fi

jshinfo "[kdelight] Starting kdeinit server"
## So that Konqueror doesn't break, we need to start kdeinit ASAP:
kdeinit > /tmp/kdeinit-$DISPLAY.log 2>&1 &
## Otherwise klauncher doesn't work properly (although we don't need to load it):
# klauncher > /tmp/klauncher-$DISPLAY.log 2>&1 &

sleep 5

## Finally the WM!:
jshinfo "[kdelight] Starting kwin window manager"
## This doesn't do --replace, so if either fluxbox or compiz or any other WM is running, we fail and leave that one going.
kwin > /tmp/kwin-$DISPLAY.log 2>&1 &
sleep 10

if [ ! "$RUNNING_GENTOO" = 1 ]
then
	## We want the panel:
	jshinfo "[kdelight] Starting kicker panels"
	kicker > /tmp/kicker-$DISPLAY.log 2>&1 &
fi

## The version of KDE on Morphix needs this started:
which khotkeys >/dev/null 2>&1 &&
khotkeys > /tmp/khotkeys-$DISPLAY.log 2>&1 &

wait
