LANG="$1"
shift

case "$LANG" in

	-sh)
		sed 's+#.*++' "$@"
	;;

	-c|-java)
		sed 's+//.*++' "$@"
	;;

	*)
		error "Do not know how to strip comments from language: $LANG"
		exit 1
	;;

esac
