# jsh-ext-depends-ignore: from
# jsh-depends: cursebold cursered cursenorm takecols apt-list-all pkgversions drop
## For Debian/apt-based-systems, lists those packages you have installed for which a newer version is available in the security repository.
## I.e. it suggests to you what security upgrades you should make.

## List all packages from Debian's security archive site:
apt-list-all from security.debian.org |
takecols 1 |

## For each of them, list installed version of package:
while read PKG
do

	# apt-list-all -installed pkg "$PKG"

	if \
		apt-list-all -installed pkg "$PKG" |
		grep "$PKG" > /dev/null
	then

			## Package is installed

		if \
			pkgversions "$PKG" | grep -v "^$" | # pipeboth |
			## Check if installed package is lower (or equal) version to security package.
			## By testing whether Installed ("Selected") pkg comes after security pkg in version list (given that the list prints later versions nearer the top.)
			grep -A99 "("security.debian.org_ |
			drop 1 | ## To strip security line, in case security is Selected.
			grep "\[Selected\]" > /dev/null
		then
			echo "`cursered;cursebold`$PKG needs updating.`cursenorm`"
			pkgversions "$PKG"
			# echo
		else
			# echo "`cursegreen`$PKG is up-to-date (or later version than security version)`cursenorm`"
			# echo
			:
		fi

	fi

done # |

## Strip those installed packages which are already at security version (the same package as the security site's)
# grep -v "security.debian.org" # |

# takecols 1

