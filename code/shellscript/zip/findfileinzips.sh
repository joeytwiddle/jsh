if [ "$1" = "" ]
then
	echo
	echo "findfileinzips <file_pattern> <zip/jar/tgz_file>s..."
	echo
	exit 1
fi

FILEPAT="$1"
shift
for ZIPFILE
do
	if endswith "$ZIPFILE" .zip .ZIP
	then VIEWCOM="unzip -v"
	elif endswith "$ZIPFILE" .jar .JAR
	then VIEWCOM="jar tf"
	elif endswith "$ZIPFILE" .tar.gz .TAR.GZ .tgz .TGZ
	# elif contains "$ZIPFILE" "\(.tar.gz\|.TAR.GZ\|.tgz\|.TGZ\)"
	then VIEWCOM="tar tfz"
	elif endswith "$ZIPFILE" .tar.bz2 .TAR.BZ2# .tgj .TGJ
	then VIEWCOM="tar tfj"
	elif endswith "$ZIPFILE" .tar .TAR
	then VIEWCOM="tar tf"
	elif endswith "$ZIPFILE" .rar .RAR
	then VIEWCOM="echo"; echo "Don't know how to unzip rar: $ZIPFILE" >&2
	else VIEWCOM="echo"; echo "Don't know how to unzip: $ZIPFILE" >&2
	fi
	# echo ":: $VIEWCOM $ZIPFILE" >&2
	( $VIEWCOM "$ZIPFILE" || ( echo "Error running: $VIEWCOM $ZIPFILE" >&2 ) ) |
	# $VIEWCOM "$ZIPFILE" |
	grep "$FILEPAT" &&
	echo "  \_ Found in $ZIPFILE" && echo
done
