case "$1" in

	-builddb)
		. importshfn rememo
		. importshfn memo
		export IKNOWIDONTHAVEATTY=true
		export MEMO_IGNORE_DIR=true
		jshinfo "Building jsh apropos DB ..."
		'ls' "$JPATH/tools/" |
		while read SCRIPT
		do
			# echo -e -n "$SCRIPT\t- "
			printf "%s\t- " "$SCRIPT"
			memo onelinedescription "$SCRIPT"
		done
	;;

	*)
		memo aproposjsh -builddb | grep "$@"
	;;

esac

