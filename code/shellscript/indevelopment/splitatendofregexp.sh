## Consider: avoid problems with \(s inside REGEXP by changing $RIGHT so that the last .* is only there when the right should be lost.

if [ "$1" = -left ]
then LEFT="\\1"; RIGHT=
elif [ "$1" = -right ]
then LEFT=; RIGHT="\\2"
else
	error "Expects -left or -right"
	exit 1
fi
shift

REGEXP="$1"
shift

cat "$@" |

sed "s+\($REGEXP\|.*\)\(.*\)+$LEFT$RIGHT+"
