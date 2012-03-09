#!/bin/sh
## See also: exim -qff

EXIM=`which exim`
[ -x "$EXIM" ] || EXIM=`which exim4`
if [ ! -x "$EXIM" ]
then
	error "Couldn't find exim or exim4"
	exit 1
fi

if [ "$1" = -test ]
then TEST=true; shift
fi

if [ ! "$1" ] || [ "$1" = --help ]
then cat << !

eximflushall [ -test ] <commands>...

  performs a few useful actions on emails in the mailq.

  The -test option performs the action only on the first mail in the queue.
  Without it all mails in the queue are processed!

  The available <commands> are:

    -peek        Print out email body
    -clearrecipients
    -reroute     Adds debug@hwi.ath.cx to recipients
    -flush       Attempts to send the email
    -remove      Removes the mail

!
# -status      Print out email details
# -addrecipient <recipient_address>
exit 1
fi

mailq |

# grep -v "\*\*\* frozen \*\*\*$" |

takecols 3 | grep -v '^$' |

while read MSGID
do

	## TODO: make the following commands to eximflush:

	# debug "MSGID=$MSGID"
	# continue

	echo "==============================================================================" | highlight ".*" cyan
	mailq | grep -A2 "$MSGID"
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" | highlight ".*" cyan

	for COMMAND in "$@"
	do

		[ "$DEBUG" ] && debug "[eximflushall] Doing $COMMAND"

		case "$COMMAND" in

			# -status)
			# ;;

			-peek)
				## No longer with exim4 -Meb:
				# env EDITOR=cat $EXIM -Meb "$MSGID" | highlight ".*" yellow
				$EXIM -Mvb "$MSGID" | highlight ".*" yellow
				echo "??????????????????????????????????????????????????????????????????????????????" | highlight ".*" cyan
			;;

			## TODO: Some exim commands (at least the next two) can fail if the message is currently undergoing processing.  What should we do about this?

			### I ph34r this might cause exim to drop the mail immediately (we can't do -reroute afterwards)!
			-clearrecipients)
				centralise '-' "Marking as delivered all recipients of $MSGID" | highlight ".*" cyan
				$EXIM -Mmad "$MSGID"
			;;

			-reroute)
				centralise '-' "Adding joey@neuralyte.org to the recipient list of $MSGID" | highlight ".*" cyan
				$EXIM -Mar "$MSGID" joey@neuralyte.org
			;;

			-flush)
				centralise '-' "Asking exim to flush $MSGID" | highlight ".*" cyan
				$EXIM -v -M "$MSGID"
				# # exim -M "$MSGID"
				# # echo "## Response: $?" | highlight ".*" cyan
			;;

			### This one isn't needed if we complete the delivery using methods above.
			-remove)
				centralise '-' "Asking exim to remove $MSGID" | highlight ".*" cyan
				$EXIM -Mrm "$MSGID"
			;;

			*)
				error "Command \"$COMMAND\" not recognised."
				exit 1
			;;

		esac

	done

	echo "==============================================================================" | highlight ".*" cyan
	echo
	[ "$TEST" ] && break

done
