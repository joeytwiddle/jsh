## Alternatively, we could grep the output of justlinks run on all the links.

cd $HOME
find . -maxdepth 3 -type l |

sed 's+^./++' |

while read LINK
do

	TARGET=`justlinks "$LINK"`

	if [ -e "$TARGET" ]
	then

		TARGET=`realpath "$TARGET"`

		IFLINKED="$JPATH/code/home/$LINK"

		if [ -w "$IFLINKED" ]
		then

			IFLINKED=`realpath "$IFLINKED"`

			# ## if this ever fails try realpath!
			# if [ "$TARGET" = "$JPATH/code/home/$LINK" ]
			if [ "$TARGET" = "$IFLINKED" ]
			then

				echo -n "# $TARGET <- "
				ls -artFhd --color "$HOME/$LINK"
				# echo -n "## "
				# ls -artFhd --color "$HOME/$LINK" | tr -d '\n'
				# echo " links to $TARGET"
				echo "rm -f \"$HOME/$LINK\""
				echo

			fi

		fi

	fi
				
done # | columnise ## needs "#$TARGET <- " with no space and no --color

echo "### Run again with |sh to execute above commands."
