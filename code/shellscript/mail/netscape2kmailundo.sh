# Purges Kmail cache and links to ns folders
find $HOME/nsmail -type d -name ".*.directory" -follow | while read X; do
		( 
			cd "$X"
			find . -name "*.index" -or -name "*.index.sorted" -or -name "*.summary" | while read Y; do
				if issymlink "$Y"; then
					del "$Y"
				else
					echo "Skipping >$Y<"
				fi
			done
		)
		del "$X"
done
if issymlink "$HOME/Mail/.nsmail.directory"; then
	del "$HOME/Mail/.nsmail.directory"
else
	echo "And skipping >$HOME/Mail/.nsmail.directory<"
fi
