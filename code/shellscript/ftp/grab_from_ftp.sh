#!/bin/bash

. require_exes lftp

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "Usage: grab_from_ftp <user>:pass@<host>/<dir> <dir>"
	exit 0
fi

user_host_pass=$(echo "$1" | beforefirst /)
ftp_folder=$(echo "$1" | afterfirst /)
ftp_url="ftp://$user_host_pass"
local_folder="$2"

mkdir -p "$local_folder"
if [ ! -d "$local_folder" ] || [ ! -e "$local_folder" ]
then
	echo "local_folder=$local_folder does not exist or is not a folder I can enter!"
	echo "Aborting, to avoid the risk of deleting local files"
	exit 3
fi

# To upload instead of download:
#REVERSE="--reverse"
# To delete files on the destination which were removed from the source.
# WARNING: This could delete trees of files unexpectedly, if the 'cd' or 'lcd' commands fail!
DELETE="--delete"

# -aR does not work.  It does fetch all the filenames recursively in one round trip, but it treats them all as files in the top-level folder, so fails to find the files when it tries to transfer them.
lftp -c "set ftp:list-options -a;
set ssl:check-hostname no
set ssl:verify-certificate no
# TODO: escape any apostrophes in the ftp_url
open '$ftp_url';
lcd $local_folder;
cd $ftp_folder;
mirror $REVERSE \
       $DELETE \
       --verbose \
       --exclude-glob a-dir-to-exclude/ \
       --exclude-glob a-file-to-exclude \
       --exclude-glob a-file-group-to-exclude* \
       --exclude-glob other-files-to-exclude"

