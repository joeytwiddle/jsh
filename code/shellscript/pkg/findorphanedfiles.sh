WHERE="$1"

if [ ! "$WHERE" ]
then

	# echo "help"
	
	WHERE="$PWD"

fi

cd / ## For memoing.

INPACKAGES=`jgettmp inPackages`

## For Debian:
## Note: does /not/ use the clever dpkg checksums, so will /not/ detect files whose size/content has changed.

PACKAGES_TO_CHECK=`
## This heuristic uses dpkg -S to find only those packages containing the directory $WHERE
# memo findpkgwith "$WHERE" |
# striptermchars | takecols 1 | beforefirst : |
# removeduplicatelines
## All in one memo:
memo "findpkgwith '$WHERE' | striptermchars | takecols 1 | beforefirst : | removeduplicatelines"
## yuk: memo findpkgwith "$WHERE" '|' striptermchars '|' takecols 1 '|' beforefirst : '|' removeduplicatelines
`

for PACKAGE in $PACKAGES_TO_CHECK
do
	echo "Reading file list for package $PACKAGE" >&2
	# memo dpkg -L "$PACKAGE" | sed "s|$|	[$PACKAGE]|"
	## All in one memo:
	# memo "dpkg -L '$PACKAGE' | sed 's|$|	[$PACKAGE]|'"
	## Inner memo because there is a small chance dpkg-L ... may have been run elsewhere
	memo "memo dpkg-L '$PACKAGE' | sed 's|$|	[$PACKAGE]|'"
	## yuk: memo dpkg -L "$PACKAGE" '|' sed "'s|$|	[$PACKAGE]|'"
done |
grep "^$WHERE" |
removeduplicatelines |
cat > $INPACKAGES

## End of Debian-specific code.

## TODO: rpm version!

OUTPUTKNOWN=/dev/null
# OUTPUTKNOWN=/dev/stdout
# curseblue

find "$WHERE" -not -type d |
while read FILE
do
	grep "^$FILE	" "$INPACKAGES" >> $OUTPUTKNOWN ||
	(
		echo "`cursenorm`$FILE	`cursered;cursebold`NOT FOUND`curseblue`"
	)
done

cursenorm

jdeltmp $INPACKAGES


