if [ "$1" = --help ]
then
cat << !

findorphanedfiles [ <directory> ]

  will display files in that directory which do not belong to an installed
  package (currently dpkg/Debian only; TODO: rpm and ebuild).

  It first determines all packages which *do* have files in the directory, then
  extracts the file listing of each package, and then looks for files present
  on the system but which are not included in the listings.

  Slow package listing extraction causes it runs slowly if the directory is
  affected by lots of packages, but it might run faster in subdirectories.

  Note: does /not/ refer to the stored dpkg checksums, so will /not/ detect
  files whose size/content has changed, only those unexpectedly present.

!
exit 1
fi

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


