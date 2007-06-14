# jsh-ext-depends: sed
# jsh-depends: ishdbusy findjob ezbtdownload
# OPTIONS="--max_uploads 5 --max_upload_rate 10" # --check_hashes 0"

## When spawning lots of clients:
# OPTIONS="--max_uploads 2 --max_upload_rate 1" # --check_hashes 0"

## I naughtily just hosed USER_OPTIONS, but it can now be exported instead.
# USER_OPTIONS="$*"
ONLY_RESUME_TORRENT_MATCHING="$*"

####

# while ishdbusy -v 0
# do sleep 5
# done
# btlaunchmanycurses "$PWD" $OPTIONS
# exit

####

# export DISPLAY=:0

# for HASH_OPTIONS in "--check_hashes 0" ""
for HASH_OPTIONS in ""
do

	for TORRENT in *.torrent
	do

		if [ "$ONLY_RESUME_TORRENT_MATCHING" ] && ! contains "$TORRENT" "$ONLY_RESUME_TORRENT_MATCHING"
		then
			jshinfo "Skipping $TORRENT"
			continue
		fi

		# echo "$TORRENT"

		## First we check to see if this torrent is already running (using findjob and expecting the torrent file name in the process's arguments)
		## Forget this: These escapes could be put in approriate library fn. eg. escaperegexp.  Well we do now have toregexp, but here we actually are targetting findjob's grep, but are we double-escaping because we are going through sh somewhere?
		REGEXP=`
			echo "$TORRENT" |
			sed 's+\[+\\\\[+g;s+\]+\\\\]+g' |
			# sed 's+(+\\\\\\(+g;s+)+\\\\\\)+g' | ## TODO: there is still a problem with ()s but this doesn't fix it!
			# sed 's+(+.+g;s+)+.+g' | ## did this?  idk!  maybe it did!  when did they break?!
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

		ezbtdownload "$TORRENT" $USER_OPTIONS $HASH_OPTIONS &

		sleep 5

	done

	if [ "$HASH_OPTIONS" ]
	then
		echo "Waiting to see if any failed with $HASH_OPTIONS, before trying without."
		sleep 30
	fi

done
