## Produces a list of symlinks which may point to or through the given file or
## path.  It basically searches all symlinks on the system for those where the
## link target contains the string provided.  The string may not start or end
## in '/' as these are added automatically, to ensure the word matches a node.
## The string is treated as a regexp, and may contain '/'s.
##
## Examples:
##
##   % findlinksmatching alternatives/mail
##   /usr/bin/mail -> /etc/alternatives/mail
##
##   % findlinksmatching cpp
##   /etc/alternatives/cpp -> /usr/bin/cpp
##   /lib/cpp -> /etc/alternatives/cpp
##   /usr/share/doc/gcc -> cpp
##
##   % findlinksmatching bash
##   /bin/sh.distrib -> bash
##   /bin/rbash -> bash
##
##   % findlinksmatching ash
##   /bin/sh.distrib -> ash
##   /bin/rbash -> ash
##
## If you are worried about breaking symlinks during a session, keep watch:
##
##   % ionice -n 3 nice -n 5  jwatch -delay 20 findlinksmatching .
##
## This relies on colors so it can notice when the alive/broken state changes.
## You can refresh the symlink list whilst it is running from another shell:
##
##   % memo findlinksmatching blah
##

# folder="`basename "$1"`"
folder="$1"

. "$JPATH"/tools/faster_jsh_colors.init

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
  find / -path '**/RECLAIM/**' \
      -o -path '**/proc/**' -o -path '/dev/**' -o -path '/sys/**' \
      -o -path '**/hwibot/dev/**' -o -path '**/hwibot/mnt/**' -o -path '**/hwibot/home/**' \
      -o -path '/oldhwibaks/**' -o -path '**/etc.*/**' \
    -prune \
      -o -type l -printf '%p%l\n' |
# 2>/dev/null

grep --line-buffered "\(\|.*/\)$folder\(/\|$\)" |

## NOTE: We are using the delimeter  in four places in this file!
while IFS="" read link target
do
	if [ -d "$link" ] || [ -f "$link" ]
	then echo "$link -> $CURSEGREEN""$target""$CURSENORM"
	else echo "$link -> $CURSERED$CURSEBOLD""$target""$CURSEBOLD$CURSENORM"
	fi
done

