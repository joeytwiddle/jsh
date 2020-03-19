#!/bin/sh

# Useful alternative to rsync -a if one of the filesystems cannot store user/group/flag permissions
# Add -t if you care about timestamps (but note this will likely add folders to the output)

# -a is -rlptgoD

# Note that -t can be annoying when using git to backup files, because git will change timestamps.
# However if you disable with --no-times then you may like to use -c / --checksum to avoid sending whole files!

# To compare:
#
# rsync-noperms -i -n /dira/ /dirb

rsync -rlD "$@"
# Alternatively:
#rsync -a --no-owner --no-group --no-perms --no-times "$@"
