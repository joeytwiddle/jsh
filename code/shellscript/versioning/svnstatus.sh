## Not quite.  ls knows how (at least where newliens are concerned.)
function inUserMode () {
	[ "`tty`" ]
}

svn status "$@" | grep -v "^\?" |

if inUserMode
then

	highlight "^M.*" yellow |
	highlight "^\!.*" blue |
	highlight "^A.*" green

else

	cat

fi
