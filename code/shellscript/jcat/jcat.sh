
### UNTESTED!

## Concept:
## a file/directory or something in a namespace not starting / or file://
## may have associated with it any number of categories

## Let's find the global namespace and map everything with jcat!

CATFILE="$HOME/.jcat"

case "$1" in

	add)

		CAT2ADD="$2"
		FILE="$3"

		(
			jcat getcats "$FILE"
			echo "$CAT2ADD"
		) |
		removeduplicatelines |
		jcat putcats "$FILE"
 
	;;

	getcats)

		FILE="$2"
		
		cat "$CATFILE" |
		grep "^$FILE|/" |
		afterfirst "|/" |
		tr '/' '\n'

	;;

	putcats)

		FILE="$2"

		CATS="/"
		while read CAT
		do CATS="$CATS$CAT/"
		done

		(
			cat "$CATFILE" |
			grep -v "^$FILE|/"
			echo "$CATS"
		) |
		pipebackto "$CATFILE"

	;;

	*)

		echo "jcat: do not recognise \"$1\" - try add, getcats or putcats."
		exit 1

	;;

esac

