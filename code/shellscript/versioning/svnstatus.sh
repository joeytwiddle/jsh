## Not quite.  ls knows how (at least where newliens are concerned.)
function inUserMode () {
	[ "`tty`" ]
}

svn status "$@" | grep -v "^\?" |

if inUserMode
then

	highlight "^A.*" green |
	highlight "^M.*" yellow |
	highlight "^\!.*" red |
	highlight "^D.*" blue

else

	cat

fi
