# Does a simple one-way jfc diff
A=`jgettmp jfcsh1`
B=`jgettmp jfcsh1`
cat "$1" | sort > "$A"
cat "$2" | sort > "$B"
diff "$A" "$B" | grep "^< " | sed "s/^< //"
