WHERE="$1"

if [ ! "$WHERE" ]
then

	# echo "help"
	
	WHERE="$PWD"

fi

## For Debian:

PACKAGES_TO_CHECK=`
memo findpkgwith "$WHERE" |
striptermchars | takecols 1 | beforefirst : |
removeduplicatelines
`

INPACKAGES=`jgettmp inPackages`
ONSYSTEM=`jgettmp onSystem`

for PACKAGE in $PACKAGES_TO_CHECK
do
	echo "$PACKAGE" >&2
	memo dpkg -L "$PACKAGE" # | sed "s+$+   [$PACKAGE]+"
done |
grep "$WHERE" |
sort |
removeduplicatelines -adj |
cat > $INPACKAGES

find "$WHERE" | sort > $ONSYSTEM

vimdiff $ONSYSTEM $INPACKAGES

jdeltmp $INPACKAGES $ONSYSTEM


