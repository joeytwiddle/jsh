# jsh-ext-depends: sed
# jsh-depends: ishdbusy findjob ezbtdownload
# OPTIONS="--max_uploads 5 --max_upload_rate 10" # --check_hashes 0"

## When spawning lots of clients:
# OPTIONS="--max_uploads 2 --max_upload_rate 1" # --check_hashes 0"

OPTIONS="$*"

####

# while ishdbusy -v 0
# do sleep 5
# done
# btlaunchmanycurses "$PWD" $OPTIONS
# exit

####

# export DISPLAY=:0

for TORRENT in *.torrent
do

	# echo "$TORRENT"

	## TODO: these escapes should be put in approriate library fn. eg. escaperegexp.  Actually we are targetting findjob's grep, but are we double-escaping because we are going through sh somewhere?
	REGEXP=`
		echo "$TORRENT" |
		sed 's+\[+\\\\[+g;s+\]+\\\\]+g' |
		# sed 's+(+\\\\(+g;s+)+\\\\)+g' |
		cat
	`
	# echo "$REGEXP"
	# if findjob "$REGEXP" # > /dev/null ## problem: catches initial call to screen by inscreendo, the btdownload for which may have since been killed.
	if findjob "$REGEXP" | grep /btdownload # > /dev/null
	then
		echo "already running: $REGEXP"
		echo
		continue
	fi

	echo "Checking hard drive is not busy for $TORRENT ..."
	while ishdbusy -v 0
	do sleep 5
	done
	
	echo "starting: $TORRENT"
	echo

	ezbtdownload "$TORRENT" $OPTIONS &

	sleep 5

done
