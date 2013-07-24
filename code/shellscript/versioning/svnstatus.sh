## Not quite.  ls knows how (at least where newliens are concerned.)
inUserMode() {
	[ "`tty`" ]
}

svn status "$@" |

# grep -v "^\?" |

if inUserMode
then

	highlight "^\?.*" magenta |
	highlight "^A.*" green |
	highlight "^C.*" red |
	highlight "^M.*" yellow |
	highlight "^\!.*" red |
	highlight "^D.*" blue

else

	cat

fi
