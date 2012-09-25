#!/bin/bash

## Marks as many packages as possible auto-installed, allowing any packages to be removed.
## The result is a minimal set of (i) install selections in dpkg/apt.
## Useful if you have accidentally marked a load of packages as "wanted" in Aptitude, but you really only want the top-level applications you used to be marked.
## This runs very slowly!  But it is also fairly safe (squeeze 2012).

printf '' > selected_packages.txt

## Select packages which are installed but not marked auto.

## This implementation can fail for long package names which get truncated.
# for pkg in $(aptitude search ~i | grep -v "i A" | cut -d " " -f 4)

for pkg in $(aptitude search "?installed ?not(?automatic)" --display-format "%p" | reverse)
do
	# If we mark it auto, will it cause any packages to be removed (itself or others)?
	if ! aptitude markauto --simulate --assume-yes $pkg 2>&1 | grep 'will be REMOVED' > /dev/null
	then
		# It won't!
		## Optional: show why
		aptitude why $pkg
		# Do not delay this action, or else it might appear we can remove the
		# requiring package too, because the presence of this one requires him!
		# (That's also why we do |reverse - so we will tend to mark child
		# packages required by the parent, rather than marking the parent
		# because we the child requires it.)
		verbosely sudo aptitude markauto $pkg
	else
		echo $pkg >> selected_packages.txt
	fi
done

# It was claimed aptitude markauto ~i should to the same trick, but of course that marks everything!

# Also:
# findpkg lib"*"-dev | takecols 2 | grep ^lib | beforelast ':' | withalldo aptitude markauto --simulate --assume-yes

