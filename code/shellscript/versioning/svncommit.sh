if [ "$*" ]
then svn commit "$@"
else
	svn status
	jshinfo "Will perform \"svn commit -m ''\" in 5 seconds - press Ctrl+C to abort."
	sleep 5
	verbosely svn commit -m ""
fi

