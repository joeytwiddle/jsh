# Purges Kmail cache and links to ns folders

echo "# Symlinks"

purgelinks "$HOME/nsmail/"

echo "# Netscape and Kmail caches"

find "$HOME/nsmail/" -name ".*.summary" -or -name ".*.sorted" -or -name ".*.index" | # kmail
	while read X; do
		echo "rm \"$X\""
	done

echo "recommend | sh" >> /dev/stderr

exit 0

find $HOME/nsmail -type d -name ".*.directory" -follow | while read X; do
	# if test -d "$X"; then
		( 
			cd "$X"
			# echo "In $X:"
			# ls -d .*.index* .*.summary*
			# find . -name "*.index" -or -name "*.index.sorted" -or -name "*.summary" | while read Y; do
				# if issymlink "$Y"; then
					# del "$Y"
				# else
					# echo "Not a symlink: skipping >$Y<"
				# fi
			# done
		)
		del "$X"
	# fi
done
if issymlink "$HOME/Mail/.nsmail.directory"; then
	del "$HOME/Mail/.nsmail.directory"
else
	echo "And skipping >$HOME/Mail/.nsmail.directory<"
fi
