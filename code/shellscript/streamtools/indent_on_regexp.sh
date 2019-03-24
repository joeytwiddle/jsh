indent_on_regexp="$1"
outdent_on_regexp="$2"

indent=""

while IFS="" read line
do
	if printf "%s\n" "$line" | grep "$indent_on_regexp" >/dev/null
	then indent="$indent""  "
	fi
	if printf "%s\n" "$line" | grep "$outdent_on_regexp" >/dev/null
	then indent=`echo "$indent" | sed 's+  $++'`
	fi
	printf "%s%s\n" "$indent" "$line"
done

