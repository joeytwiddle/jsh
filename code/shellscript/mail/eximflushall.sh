## See also: exim -qff

if [ "$1" = -test ]
then TEST=true; shift
fi

if [ ! "$1" ] || [ "$1" = --help ]
then cat << !

eximflushall [ -test ] <command> [ <command>s.. ]

  where each <command> can be one of:

    -peek        Print out email body
    -clearrecipients
    -reroute     Adds debug@hwi.ath.cx to recipients
    -flush       Attempts to send the email
    -remove      Removes the mail

  The -test option forces the script to exit after
  one email has been processed.

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
				env EDITOR=cat exim -Meb "$MSGID" | highlight ".*" yellow
				echo "??????????????????????????????????????????????????????????????????????????????" | highlight ".*" cyan
			;;

			## TODO: Some exim commands (at least the next two) can fail if the message is currently undergoing processing.  What should we do about this?

			### I ph34r this might cause exim to drop the mail immediately!
			-clearrecipients)
				centralise '-' "Marking as delivered all recipients of $MSGID" | highlight ".*" cyan
				exim -Mmad "$MSGID"
			;;

			-reroute)
				centralise '-' "Adding debug@hwi to the recipient list of $MSGID" | highlight ".*" cyan
				exim -Mar "$MSGID" debug@hwi.ath.cx
			;;

			-flush)
				centralise '-' "Asking exim to flush $MSGID" | highlight ".*" cyan
				exim -v -M "$MSGID"
				# # exim -M "$MSGID"
				# # echo "## Response: $?" | highlight ".*" cyan
			;;

			### This one isn't needed if we complete the delivery using methods above.
			-remove)
				centralise '-' "Asking exim to remove $MSGID" | highlight ".*" cyan
				exim -Mrm "$MSGID"
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
