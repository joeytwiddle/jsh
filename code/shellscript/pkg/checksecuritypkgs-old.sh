## List all packages from Debian's security archive site:
apt-list from security.debian.org |
takecols 1 |

## For each of them, list installed version of package:
while read PKG
do verbosely apt-list -installed pkg "\<$PKG\>"
done |

## Strip those installed packages which are already at security version (the same package as the security site's)
grep -v "security.debian.org" # |

# takecols 1

