if endswith "$1" "\.ogg"
then ogg123 "$@"
else mpg123 -b 10000 "$@" > /dev/null 2>&1
fi

# mplayer "$@" |
# (
	# while read LINE
	# do
		# if [ "$LINE" = "Starting playback..." ]
		# then
			# cat
			# break
		# fi
	# done
# 
# )
