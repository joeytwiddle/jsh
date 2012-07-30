printf '' > selected_packages.txt

## Select packages which are installed but not marked auto.

## First implementation can fail for long package names which get truncated.
# for pkg in $(aptitude search ~i | grep -v "i A" | cut -d " " -f 4)

for pkg in $(aptitude search "?installed ?not(?automatic)" --display-format "%p" | reverse)
do
	# If we mark it auto, will it cause other packages to be removed?
	if ! aptitude markauto --simulate --assume-yes $pkg 2>&1 | grep 'will be REMOVED' > /dev/null
	then
		# It won't!
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

