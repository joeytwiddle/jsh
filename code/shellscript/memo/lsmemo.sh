COM="$*";
# NICECOM=`echo "$PWD: $COM" | tr " /" "_-"`
NICECOM=`echo "$PWD: " | tr " /" "_-"`
FILES="$JPATH/data/memo/$NICECOM*.memo"
ls $FILES | afterfirstall "$NICECOM" | beforeall ".memo"
