if `jwhich wget -quietly`
then wget -nv -O - "$@"
elif `jwhich lynx -quietly`
then lynx -source "$@"
else
	error "downloadurl: neither wget nor lynx present, no telnet implemented."
	exit 1
fi
