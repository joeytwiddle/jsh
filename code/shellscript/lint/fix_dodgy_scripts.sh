# A little bit of a lint-finder bug-detector for shellscripts.

# Test this with:
# ssDir="$JPATH/code/shellscript" ; cd /tmp ; del ./shellscript ; cp -a "$ssDir" . ; cd shellscript ; bash $ssDir/lint/fix_dodgy_scripts.sh

# verify="-verify"
verify=""

if grep --help | grep '\--color' >/dev/null
then export GREP_OPTIONS="--color=auto"
fi

check_replace() {
	pattern="$1"
	replacement="$2"
	echo
	echo "Looking for $pattern to replace it with $replacement..."
	echo
	grep "$pattern" */*
	echo
	echo "Replacing occurrences of $pattern with $replacement:"
	echo

	if [ -z "$verify" ]
	then
		## Faster but BUG: does not work with $verify - needs to read from user stdin!
		grep -l "$pattern" */* | withalldo sedreplace "$pattern" "$replacement"
	else
		## Original simple slow version.
		sedreplace $verify "$pattern" "$replacement" */*
	fi

}

# I used to write: [ "$var" ] to check if var is set, but that is bad non
# posix.  At the very least it can fail sometimes if var starts with "-".
#
# Such tests should instead be written: [ -n "$var" ]
#
#   -n  =>  non-zero
#
#   -z  =>  zero
#
# Since I have such trouble remembering -n, let's give it a name: "need"
#   if [ -n A ]  =>  "if we need to do A" or "if we need feature A"
#
# The following should replace bad occurrences with good ones.

check_replace '\[ \(\$[A-Za-z0-9]*\) \]' '[ -n "\1" ]'

check_replace '\[ ! \(\$[A-Za-z0-9]*\) \]' '[ -z "\1" ]'

check_replace '\[ "\(\$[A-Za-z0-9]*\)" \]' '[ -n "\1" ]'

check_replace '\[ ! "\(\$[A-Za-z0-9]*\)" \]' '[ -z "\1" ]'

check_replace '\<test \(\$[A-Za-z0-9]*\)\>' '[ -n "\1" ]'

check_replace '\<test ! \(\$[A-Za-z0-9]*\)\>' '[ -z "\1" ]'

check_replace '\<test "\(\$[A-Za-z0-9]*\)"\>' '[ -n "\1" ]'

check_replace '\<test ! "\(\$[A-Za-z0-9]*\)"\>' '[ -z "\1" ]'

