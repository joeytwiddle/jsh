## pretty user shell function:

## TODO:
## if we can't properly syntax highlight the file, do an estimate:
## find the top 10 most popular words in the stream, and highlight these in separate colours.
## the rare words/symbols will stand out as white

## Sometimes we don't want highlighting, we want pretty formatting (e.g. JSON).

## See also: beautify_json (jsh)

# Read from stdin:
if [ "x$*" = x ]
then
	prettycat -
	exit
fi

for file
do
	ext="`echo "$file" | sed 's+^.*\.\([^.]*\)$+\1+'`"
	cat "$file" |
	case "$ext" in
		json)
			sed '
				s/,{/,\n{/g
				s/{"/{\n  "/g
				s/,"/, "/g
			'
		;;
	esac
done

