if [ "$1" = --help ]
then
cat << !!!

Reports that we are using some deprecated code, and performs a workaround.

Usage:

  deprecated -by "$0" <workaround_command_line>...

or to avoid providing -by each time:

  . importshfn deprecated
  deprecated <workaround_command_line>...

This script is currently a bit of a failure.  It sometimes tells us the script
that called deprecated, but never the script that called the deprecated one!

A future version could attempt to resolve the PID of parent or grandparent's process.

Although this script is passed the workaround, ideally it would report the
position of the call which called the script or function which called
deprecated.  So far it only manages to report where the workaround exists, not
where the call to the deprecated script came from!

!!!
exit 0
fi

local callingScriptName
callingScriptName="$0"

if [ "$1" = "-by" ]
then
	callingScriptName="$2"
	shift ; shift
fi

echo "`curseyellow;cursebold`[`cursecyan;cursebold`DEPRECATED`curseyellow;cursebold`]`cursenorm` `cursecyan`Deprecated use in $callingScriptName, calling workaround: $*" >&2
verbosely "$@"

