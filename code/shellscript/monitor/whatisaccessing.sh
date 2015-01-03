f="$1"
if [ -d "$f" ] || [ -f "$f" ]
then listopenfiles . | grep "`realpath "$f"`"
else
	echo "whatsisaccessing <file/dir> lists processes reading or blocking that FS node."
	exit 1
fi

# Alternative, probably faster:
#fuser "$f"

# See also: monitorfileaccess
