# jsh-ext-depends-ignore: from
# jsh-depends: cursebold cursered cursenorm takecols apt-list-all pkgversions drop
## For Debian/apt-based-systems, lists those packages you have installed for which a newer version is available in the security repository.
## I.e. it suggests to you what security upgrades you should make.

## TODO: apt-list does not appeat to be memoing correctly!
## Also, this earlier version looked more efficient.

# ## List all packages from Debian's security archive site:
# apt-list from security.debian.org |
# takecols 1 |
#
# ## For each of them, list installed version of package:
# while read PKG
# do
#
# 	# apt-list -installed pkg "$PKG"
#
# 	if \
# 		apt-list -installed pkg "$PKG" |
# 		grep "$PKG" > /dev/null
# 	then

# export IKNOWIDONTHAVEATTY=true

## List all installed packages:
apt-list -installed all | grep "$*" |

catwithprogress |

while read PKG CURRENT_VERSION CURRENT_DISTRO CURRENT_SOURCE
do

	## Does it have a security version at same stability, but not same version?
	NON_SELF_SECURITY_VERSIONS_OF_PKG="`
		# IKNOWIDONTHAVEATTY=1 memo apt-list from security.debian.org |
		IKNOWIDONTHAVEATTY=1 memo apt-list from security.debian.org |
		# grep "\<security.debian.org\>" |
		# IKNOWIDONTHAVEATTY=1 memo apt-list pkg "$PKG" |
		grep "^\<$PKG\> " |
		grep "\<$CURRENT_DISTRO\>" |
		grep -v "\<$CURRENT_VERSION\>" |
		grep . # > /dev/null
	`"

	if [ "$NON_SELF_SECURITY_VERSIONS_OF_PKG" ]
	then
		echo
		echo "$PKG ($CURRENT_VERSION/$CURRENT_DISTRO[$CURRENT_SOURCE]) `cursered;cursebold`needs updating.`cursenorm`"
		# pkgversions "$PKG"
		echo "$NON_SELF_SECURITY_VERSIONS_OF_PKG"
		# echo
	else
		# echo "$PKG `cursegreen`is up-to-date (or later version than security version)`cursenorm`"
		# echo
		:
	fi

done # |

## Strip those installed packages which are already at security version (the same package as the security site's)
# grep -v "security.debian.org" # |

# takecols 1

