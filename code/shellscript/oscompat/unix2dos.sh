if [ "$*" ]
then

	for FILE
	do

		cat "$FILE" | unix2dos | pipebackto "$FILE"

	done

else

	CL=`printf "\r"`

	sed "s+$+$CL+"

fi
