#!/bin/sh
## Oh damn this won't work.
## We either have to return $$ as lockfile reference for when -release is called
## or we could accept what to execute, and do it in here, thus retaining $$
## Or we could request that $$ be passed in by caller, so we would have the PID of the actual process that wanted the lock.

#### This is not good: another process might grab the file during the last ";"
## while [ -f $file ]; do sleep 1; done ; touch $file

#### So we must use atomic filesystem operations:

if [ ! "$1" = -release ]
then

	LOCKFILE="$1"

	echo "$$" >> "$LOCKFILE"

	while [ ! "`head -n 1 "$LOCKFILE"`" == "$$" ]
	do sleep 1
	done

	exit 0

else

	shift
	LOCKFILE="$1"

	cat "$LOCKFILE" | grep -v "^$$\$"

fi
