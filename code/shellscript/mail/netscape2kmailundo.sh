# Purges Kmail cache and links to ns folders
find $HOME/nsmail -type d -name ".*.directory" -follow | while read X; do
		( 
			cd "$X"
			del *.index *.index.sorted
		)
		del "$X"
done
del $HOME/Mail/.nsmail.directory
