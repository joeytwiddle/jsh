find $HOME/nsmail -type d -name "*.sbd" -follow | while read X; do
	Y=`echo "$X" | sed "s/\(.*\)\/\(.*\)\.sbd/\1\/\.\2\.directory/"`;
	ln -s "$X" "$Y"
done
ln -s $HOME/nsmail $HOME/Mail/.nsmail.directory
