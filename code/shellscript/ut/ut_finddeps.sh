# [ "$DEPDBDIR" ] || DEPDBDIR="$HOME/.ut_finddeps.db"
# [ "$DEPDBDIR" ] || DEPDBDIR="$HOME/ut_server/dependencydb"
[ "$DEPDBDIR" ] || DEPDBDIR="/stuff/software/games/unreal/dependencydb/"
mkdir -p "$DEPDBDIR"

# ALWAYS_SCAN=true

DEFAULT_UT_DIR="/stuff/ut/ut_win_pure/"
ALL_UT_FILES="/stuff/software/games/unreal/server/ /home/oddjob2/ut_server/ut-server/ $DEFAULT_UT_DIR /stuff/ut/ut_win/"

# REGEXP_OF_PACKAGE_NAMES_TO_IGNORE="\("`
	# (
		# find "$DEFAULT_UT_DIR" -name "*.u*" -not -name "*.unr" |
		# afterlast / | beforelast "\."
		# echo "Color"
		# echo "MyLevel"
	# ) |
	# toregexp |
	# sed 's+.$+\0\\\\|+' | tr -d '\n' | sed 's+\\|$++'
# `"\)"

# # jshinfo ">$REGEXP_OF_PACKAGE_NAMES_TO_IGNORE<"
# REGEXP_OF_PACKAGE_NAMES_TO_IGNORE="^$"

FILE="$1"

FILENAME=`filename "$FILE"`

if [ -f "$DEPDBDIR"/"$FILENAME".depends_on ] && [ ! "$ALWAYS_SCAN" ]
then

	cat "$DEPDBDIR"/"$FILENAME".depends_on

else

	jshinfo "Scanning $FILE ..."

	## TODO: memo this (maybe only for 5/10 minutes)
	SEARCH_REGEXP=`
	  echo -n '\<\('
	  find $ALL_UT_FILES -type f -name "*.u*" -not -name "*.unr" | afterlast / | beforelast "\." | toregexp |
	  grep -v "/Cache/" |
	  removeduplicatelines |
	  sed 's+$+\\\|+' |
	  tr -d '\n' |
	  sed 's+\\\|$++'
	  echo -n '\)\>'
	`
	jshinfo "SEARCH_REGEXP=$SEARCH_REGEXP"

	grep -a -o "$SEARCH_REGEXP" "$FILE" |
	removeduplicatelines | tee "$DEPDBDIR"/"$FILENAME".depends_on.working &&
	mv "$DEPDBDIR"/"$FILENAME".depends_on.working "$DEPDBDIR"/"$FILENAME".depends_on

fi

