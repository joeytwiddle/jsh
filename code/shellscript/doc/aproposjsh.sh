# jsh-depends: memo rememo importshfn jgettmpdir jshinfo
# jsh-depends-ignore: jsh
## jsh-help: Uses onelinedescription to build an apropos-like database for jsh

case "$1" in

	-builddb)

		## TODO: factor this out as "prepare_fast_memoing":
		. jgettmpdir -top
		. importshfn rememo
		. importshfn memo
		export IKNOWIDONTHAVEATTY=true
		export MEMO_IGNORE_DIR=true

		jshinfo "Updating jsh apropos DB ..."
		'ls' "$JPATH/tools/" |
		catwithprogress |
		while read SCRIPT
		do
			# echo -e -n "$SCRIPT(jsh)\t- "
			printf "%s(jsh)\t- " "$SCRIPT"
			memo onelinedescription "$SCRIPT"
			# memo -f "$JPATH/tools/$SCRIPT" onelinedescription "$SCRIPT"
			# memo -f `realpath "$JPATH/tools/$SCRIPT" onelinedescription "$SCRIPT"
		done
		jshinfo "jsh apropos DB is up-to-date :)"

	;;

	*)
		memo aproposjsh -builddb | grep "$@"
	;;

esac

