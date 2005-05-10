## TODO: not tested: if you ever decide to keep an old version of a config file instead of replacing it with the new one, (presumably because you prefer the configuration of the old default)
##       you should definitely -scan, so hopefully emerge--helpconfig will forget that the one
##       you chose to keep was ever a default (because now that you have decided to keep it, it
##       shouldn't be replaced automatically).
##       Check: I think this script retains the old versions as well with a >> .  What's wrong with > ?

## Also: When are CONTENTS files present or not?  Does that affect the script?
##       Are we checking non-installed packages as well as installed ones (dodgy since we only care about actually installed config files, although unlikely to cause major problems).

## NOTE: not yet tested on /multiple/ updates per conf-file

# CONFIGLIST=/tmp/config-matches.list
CONFIGLIST=$HOME/.jsh_emerge--helpconfig_config-matches.list

# ## DEPRECATED: I think I was trying to speed it up.  But this is no good cos we need to compare against the checksum of the conffile in the /old/ package!
# if [ "$1" = "-new" ]
# then
# 
	# find /etc -iname '._cfg????_*' |
# 
	# while read NEWCONFIG
	# do
		# CONFIG=`echo "$NEWCONFIG" | sed 's+/\._cfg...._+/+'`
		# # PACKAGES=`qpkg -f "$CONFIG" | striptermchars | takecols 1`
		# grep "^[^ ]* $CONFIG " /var/db/pkg/*/*/CONTENTS |
		# sed 's+/var/db/pkg/\([^:]*\)/CONTENTS:\([^ ]*\) \([^ ]*\) \([^ ]*\) \(.*\)+\1 \2 \3 \4 \5+' |
		# while read PACKAGE FILETYPE FILE MD5SUM LENGTH
		# do
			# [ "$FILE" = "$CONFIG" ] || jsherror "Expected $FILE = $CONFIG"
			# EXPECTEDSUM="$MD5SUM  $FILE"
			# GOTSUM=`md5sum "$FILE"`
			# if [ "$EXPECTEDSUM" = "$GOTSUM" ]
			# then
				# echo "$FILE `cursegreen`matches`cursenorm` $PACKAGE"
				# echo "Recommend: mv -f \"$NEWCONFIG\" \"$CONFIG\""
			# else
				# echo "$FILE `cursered`mismatches`cursenorm` $PACKAGE"
				# echo "  expected: $EXPECTEDSUM"
				# echo "  got     : $GOTSUM"
				# echo "If no others match, you could: vimdiff \"$NEWCONFIG\" \"$CONFIG\""
			# fi
		# done	
# 
	# done
# 
	# exit
# 
# fi	

## Original working method:
## For each installed package, the scan looks for any config file which matches its checksum in its portage CONTENTS file.
## Config files which match the package's default are recorded, so that later we can check they haven't changed, and replace them with the latest.
## (This is supposedly more efficient than just recording /all/ the CONTENTS's md5sums for later.)
## (And I guess it is more secure, only recording md5sums for those configs you do have installed.)
# ## # XXXXXX [[[[[[ not accurate: The scan looks through /etc for any config file which matches its checksum in its portage package's CONTENTS file. ]]]]]]

commentstream () {
	sed 's+^+# +'
}

if [ "$1" = -scan ]
then

	ls -l "$CONFIGLIST"

	cd /var/db/pkg

	'ls' -d */* |

	while read GROUPNAMEVER
	do

		cat $GROUPNAMEVER/CONTENTS |
		grep -v "^dir " |

		grep "[^ ]* /etc/" |

		while read TYPE FILE MD5SUM SIZE
		do
			[ -f "$FILE" ] || continue
			EXPECTEDSUM="$MD5SUM  $FILE"
			GOTSUM=`md5sum "$FILE"`
			if [ "$EXPECTEDSUM" = "$GOTSUM" ]
			then
				echo "$GOTSUM `cursegreen`matches`cursenorm` $GROUPNAMEVER"
			else
				echo "$FILE `cursered`mismatches`cursenorm` $GROUPNAMEVER"
			fi
		done

	done |

	pipeboth |

	## Maybe naughty:
	# striptermchars >> "$CONFIGLIST"
	# echo "  added to $CONFIGLIST"
	# ls -l "$CONFIGLIST"
	# echo "Removing duplicates..."
	# cat "$CONFIGLIST" | removeduplicatelines | dog "$CONFIGLIST"
	## Probably better, any reason why not?
	striptermchars > "$CONFIGLIST"

	ls -l "$CONFIGLIST"

elif [ "$1" = -check ]
then

	find /etc -iname '._cfg????_*' |
	while read NEWCONFIG
	do
		CONFIG=`echo "$NEWCONFIG" | sed 's+/\._cfg...._+/+'`
		GOTSUM=`md5sum "$CONFIG"`
		if
			grep "^$GOTSUM matches" "$CONFIGLIST" | commentstream
		then
			echo "# `cursegreen`Therefore it should be fine to:`cursenorm`"
			echo "mv '$NEWCONFIG' '$CONFIG'"
		elif
			grep "^$CONFIG mismatches" "$CONFIGLIST" | commentstream
		then
			echo "# `curseyellow`So you might want to:`cursenorm`"
			echo "vimdiff '$NEWCONFIG' '$CONFIG'"
		else
			echo "# `cursered;cursebold`$CONFIG was not recognised.  You may like to:`cursenorm`"
			echo "vimdiff '$NEWCONFIG' '$CONFIG'"
		fi
		echo
	done

	echo "# No more config files need merging."

elif [ "$1" = fullcheck ]
then

	find /etc -type f |
	while read CONFIG
	do
		GOTSUM=`md5sum "$CONFIG"`
		grep "^$GOTSUM matches" "$CONFIGLIST" ||
		grep "^$CONFIG mismatches" "$CONFIGLIST" ||
		echo "$CONFIG was not recognised."
	done

else

	echo
	echo "emerge--helpconfig [ --help | -scan | -check ]"
	echo
	echo "[ See also: etc-update and dispatch-conf ]"
	echo
	if [ "$1" = --help ]
	then
		echo "Emerge does not appear to know when a new version of a config file should"
		echo "overwrite an old one, even if the old one hasn't changed since it was"
		echo "installed.  This emerge--helpconfig script can solve the problem."
		echo
		echo "  -scan  : makes a record of all current config files which are unchanged from"
		echo "           their package's default."
		echo
		echo "  -check : informs you which old config files can be overridden with new ones"
		echo "           because they haven't changed from the old default."
		echo
		echo "  You need to do -scan before you emerge, because it needs to record the"
		echo "  default for the old config file, in order to know whether it can be replaced"
		echo "  by the new version.  Run -check after an emerge, before the next -scan."
		echo
		echo "  If this doc is confusing, just try it.  It's harmless; it only reports."
	else	
		echo "Don't understand: \"$1\".  Try \"--help\" then \"-check\" then \"-scan\""
	fi	
	echo
	exit 1

fi
