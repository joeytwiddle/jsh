## On Gentoo, outputs md5sums of all files in the package, suitable for re-comparison later.
## On Debian, prints the names of any files listed in the package contents which are missing from the filesystem.
## TODO: sometimes dpkg -L will output "Package XYZ does not contain any files (!)" - we should detect this.

GROUPNAMEVER="$1" ## or for Debian, PACKAGENAME


if [ -e /var/db/pkg/$GROUPNAMEVER/CONTENTS ]
then

	## Gentoo
	cat /var/db/pkg/$GROUPNAMEVER/CONTENTS |

	grep -v "^dir " |

	while read TYPE FILE CKSUM LENGTH
	do
		md5sum "$FILE"
		echo "$CKSUM  $FILE ($LENGTH)"
		echo
	done

else

	## Debian
	dpkg -L "$GROUPNAMEVER" |

	while read FILE
	do
		[ -e "$FILE" ] || echo "! $FILE"
	done

fi
