# jsh-depends: memo find
# jsh-ext-depends: readlink find
# jsh-depends-ignore: hwibot faster_jsh_colors.init
# jsh-ext-depends-ignore: ionice link

if [ "$1" = "" ] || [ "$1" = --help ]
then
pager << !

findlinksmatching <part_of_link_target_path>

  produces a list of symlinks which may point to or through the given file or
  path.  It basically searches all symlinks on the system for those where the
  link target contains the string provided.

  The string is treated as a word, and should not start or end in '/' as these
  are added automatically.  Otherwise it is treated as a regexp, and may
  contain '/'s.

  Uses memo to build a cache of the whole system on the first call, but make
  later calls respond quickly.  (If you are not root, you will naturally see
  errors about inaccessible files on the first pass.)

Output indicators:

  =   a working symlink (green)
  ?   a symlink whose target is missing (red)
  !   an old symlink which is no longer a symlink (yellow)

FLM_FAST=1 findlinksmatching ...

  displays directly from the cache, does not check the current status of
  link targets.  Presents . indicator and no colors.

TODO: Make FLM_FAST default to on, export var to turn it off (enable colors).

Examples:

  % findlinksmatching alternatives/mail
  /usr/bin/mail -> /etc/alternatives/mail

  % findlinksmatching cpp
  /etc/alternatives/cpp -> /usr/bin/cpp
  /lib/cpp -> /etc/alternatives/cpp
  /usr/share/doc/gcc -> cpp

  % findlinksmatching bash
  /bin/sh.distrib -> bash
  /bin/rbash -> bash

  % findlinksmatching ash
  /bin/sh.distrib -> ash
  /bin/rbash -> ash

  % FLM_FAST=1 findlinksmatching . | grep '\.u$'

If you are worried about breaking symlinks during a session, keep watch:

  % ionice -n 3 nice -n 5  jwatch -oneway -delay 20 findlinksmatching .

This relies on colors so it can notice when the alive/broken state changes.
You can refresh the symlink list whilst it is running from another shell:

  % memo findlinksmatching blah

!
exit 0
fi

## CONSIDER: Why haven't we checked for symlinks whose targets have changed?  Because as long as it works, we don't care...

search="$1"

. "$JPATH"/tools/faster_jsh_colors.init

## find / can take a long time, and meanwhile be heavy enough to affect system
## performance.  So we reduce processor and io-usage if possible.
be_nice="nice -n 5"
if which ionice >/dev/null 2>&1
then be_nice="$be_nice ionice -c 3 -n 7"
fi

## NOTE: Much of the below came from rmlink_safely.
##
## /proc /sys and /dev contain symlinks which we are not interested in, and may
## appear in chroots also, not just in / .  We cannot exclude all of these with
## -xdev, and that might also discard filesystems we do want to search.
##
## So we exclude contents of all folders named proc, but only contents of root
## /dev/ and /sys/ because sometimes good folders take those names!  (I never
## use the folder name proc.)
##
## There are a bunch of other things I exclude too, notably all folders I have
## bind-mounted, and GNU OS files (I assume you are not removing OS-handled
## symlinks.)
##
# excludeBindMounts=`mount | grep '[(,]bind[,)]' | takecols 3`
      # -o -path '**/usr/**' -o -path '**/etc/**' -o -path '**/lib/**' \
      # -o -path '**/var/**' -o -path '**/opt/**' \
      # -o -path '**/bin/**' -o -path '**/sbin/**' \
MEMO_IGNORE_EXITCODE=true MEMO_IGNORE_DIR=true memo -t '16 days' \
  $be_nice find / -path '**/RECLAIM/**' \
      -o -path '**/proc/**' -o -path '/dev/**' -o -path '/sys/**' \
      -o -path '**/hwibot/dev/**' -o -path '**/hwibot/mnt/**' -o -path '**/hwibot/home/**' \
      -o -path '/oldhwibaks/**' -o -path '**/etc.*/**' \
    -prune \
      -o -type l -printf '%p%l\n' |
# 2>/dev/null

grep --line-buffered "\(\|.*/\)$search\(/\|$\)" |

## NOTE: We are using the delimeter  in four places in this file!
while IFS="" read link target
do

	if [ -n "$FLM_FAST" ]
	then

		## Fast but not up-to-date, uses cached target:
		nowTarget="$target"
		echo ". $link -> $nowTarget"

	else

		## Up-to-date, reflects what the target is now:
		nowTarget="`readlink "$link"`"
		[ "$nowTarget" = "" ] && nowTarget="($target)"

		if [ -d "$link" ] || [ -f "$link" ] || [ -e "$link" ] # I added -e cos I feel we should accept links to non-files-or-dirs, e.g. devices?
		then echo "$CURSEGREEN""=$CURSENORM $link -> $CURSEGREEN$nowTarget""$CURSENORM"
		elif [ ! -L "$link" ]
		then echo "$CURSEYELLOW$CURSEBOLD""!$CURSEBOLD$CURSENORM$CURSEYELLOW$CURSEBOLD $link $CURSEBOLD$CURSENORM-> $nowTarget""$CURSEBOLD$CURSENORM"
		else echo "$CURSERED$CURSEBOLD""?$CURSEBOLD$CURSENORM $link -> $CURSERED""$nowTarget""$CURSENORM"
		fi

	fi

done

