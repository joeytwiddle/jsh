if test ! "$1" = ""; then
	DCFILE="$1"
else
	DCFILE="$HOME/.dircolors"
fi

NORM=`cursegrey`
STARTCURSE=`printf "\033["`
ENDCURSE=`printf "m"`

# FILL=''
FILL=' .*'

# Note [ function ] not compatible with /bin/ash
replace () {
	sed "s+$1+$2+g"
}

# Really want to say "without spaces" too
# MATCHSTART='^\\(.*\\)\1'
# MATCHMID='\\( .*\\)\1'
# MATCHSTART='\1'
# REPLACE="(\1{$STARTCURSE"'\2'"$ENDCURSE"'\\1\1'"$NORM}\1)"
# REPLACE="$STARTCURSE"'\2'"$ENDCURSE"'\\1\1'"$NORM"
# SEDSTR=
# Don't know why the spaces are causing this to fail
# anyway this is naff version which doesn't highlight whole fname, just relevant match.
# SEDSTR="$SEDSTR;s+$MATCHSTART +$REPLACE +g"
# SEDSTR="$SEDSTR;s+$MATCHSTART$+$REPLACE+"
# SEDMID="s+$MATCHMID+$REPLACE+"
# REPLACE='\1'
REPLACE="$STARTCURSE"'\2'"$ENDCURSE"'\\1\1'"$NORM"
SEDSTR='s+\\<\\(.*\\)\1\\>+'"$REPLACE"'+g'
# REPLACE="$STARTCURSE"'\2'"$ENDCURSE"'\1'"$NORM"
# SEDSTR='s+\1+'"$REPLACE"'+g'

cat "$DCFILE" |
grep -v "^TERM" |
sed "s/#.*//" |
tr -s " " |
grep -v "^$" |
grep -v "^ $" |
tr -d "*" |
replace "DIR" "/" |
replace "LINK" "@" |
replace "EXEC" "\\\*" |
# Failed attempt to avoid small matches whiting out larger ones
# sort -rk 1 |
replace "\." "\\\." |
sed "s/ \(.*\) \(.*\)$/ \1/" | # bring CAPS into line - really should remove!
sed "s/^\(.*\) \(.*\)$/$SEDSTR/" |
tr "\n" ";"
