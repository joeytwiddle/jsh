UNAME=`uname`

case "$UNAME" in
	"Linux")
		JM_DOES_COLOUR=true
		JM_COLOUR_LS=true
		;;
	"HP-UX")
		JM_DOES_COLOUR=true
		;;
esac

export JM_DOES_COLOR
