#!/bin/sh
list_all_env_var_strings () {
	higrep "[A-Za-z0-9_]*"           "$@"
}
list_used_env_vars_in_quotes_incl_args () {
	"\"\$[A-Za-z0-9_]*\""     "$@"
}
list_used_env_vars_incl_args () {
	higrep "\$[A-Za-z0-9_]*"         "$@"
}
list_used_env_vars () {
	higrep "\$[A-Za-z][A-Za-z0-9_]*" "$@"
}
list_used_env_vars_caps () {
	higrep "\$[A-Z][A-Za-z0-9_]*" "$@"
}
list_tested_env_vars_caps () {
	higrep "\[ \"\$[A-Z][A-Za-z0-9_]*\" \]" "$@"
}
USE_LIST_FN=list_tested_env_vars_caps

for X
do
	if [ -f "$X" ]
	then
		list_tested_env_vars_caps "$X"
	else
		find "$JPATH/tools/" -name "$X" | filter_list_with test -f |
		. foreachdo list_tested_env_vars_caps
	fi
done
