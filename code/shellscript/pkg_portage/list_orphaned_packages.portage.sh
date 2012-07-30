sh ./list_installed_packages.sh |
beforefirst "-[0-9]" |

grep font |

while read PKG
do
	verbosely equery depends "$PKG" |
	grep -v "^\[ Searching for packages depending on " |
	grep . || echo "No Dependencies Found for: $PKG"
done

