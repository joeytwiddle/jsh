# Lists all versions of packages available for download.

# Note, this is responsive to the sources in sources.list,
# which is not necessarily all the sources you have info on!

(
	echo "PACKAGE	VERSION	STATUS	SOURCE"
	(
		memo apt-cache dump |
		grep "^\(Package\| Version\|[ ]*File\): " |
		# This sed fails for non-traditional archives (lacking dist/ dir):
		sed "s|File: .*/\([^_]*\).*dists_\([^_]*\).*|File: \1 \2|" |
		sed "s|File: /var/lib/dpkg/status|File: local_only unknown|" |
		awk '	{
			if ( $1 == "Package:" )
				{ PACK=$2 }
			if ( $1 == "Version:" )
				{ VER=$2 }
			if ( $1 == "File:" )
				{ PROVIDER=$2 ; STAT=$3; print PACK "\t" VER "\t" STAT "\t" PROVIDER }
		} ' |
		if test "$1" = ""; then
			cat
		else
			grep "$1"
		fi
	)
) |
column -t
