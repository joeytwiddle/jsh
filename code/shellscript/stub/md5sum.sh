# jsh-ext-depends-ignore: cksum
# jsh-depends: jwhich cksum
MD5SUM=`jwhich md5sum`
if test -x "$MD5SUM"
then
	"$MD5SUM" "$@"
else
	cksum "$@"
fi
