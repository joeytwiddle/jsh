# This work of genius attempts to prevent error messages
# if user greps eg. * and has not specified how to deal with directories.

# Alternative implementation could redirect stderr, grep (!) it, then pipe it out.

# Note: I had to take both grep calls out of jwhich because it is used here.

# Test if -r (recursive) option is present
# (not checking for -d ATM)
# Proper:
# RES=`echo "$*" | sed "s/.*\(^\| \)-\(r\|[^-][^ ]*r\).*/GOT/"`
# Proper hack:
RES=`echo " $*" | sed "s/.* -\(r\|[^-][^ ]*r\).*/GOT/"`
# echo ">$RES<"
if test "$RES" = "GOT"; then
	`jwhich grep` "$@"
else
	# If not, specify skip directories
	`jwhich grep` -d skip "$@"
fi
