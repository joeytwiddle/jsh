#!/bin/sh
# jsh-depends: removeduplicatelines takecols withalldo jgettmp extractregex treesh jreflect debug sedreplace

## TODO: options:
## where to search (specify dir, or classpath, also grep/trim/filter to string)
## whether to look at .java files, .class + .jar, or all three (latter require $CLASSPATH/jlib/JReflect.class)
## oh and note: jreflect only work on the classpath, so it really needs an option to use its own classpath to reach any particular file... hmm tough!

CLASSES=`jgettmp $0-$$-classes`
ANCESTRY=`jgettmp $0-$$-ancestors`
ANCESTRY=/tmp/ancestry
printf "" > $ANCESTRY

export NWS="[^ 	]*"
export WS="[ 	]*"


if [ "$1" = -classpath ]
then

	SEARCH="$2"
	shift; shift

	jreflect -classes | grep "$SEARCH" |
	grep -v '\.CVS\.' |
	# pipeboth |
	withalldo java jlib.JReflect 2>/dev/null |
	## TODO try \<\>
	grep "\(class\|interface\).*\(extends\|implements\)" |
	# pipeboth |
	sedreplace " implements interface " " implements " ## should really fix in jreflect

else

	find . -name "*.java" |
	grep "$SEARCH" |

	withalldo grep "\(class\|interface\).*\(extends\|implements\)" # maybe not needed but faster with

fi |

grep -v '"' |
# grep -v "\<java.lang.Object\>" |
grep -v "\<null\>" |

extractregex "$NWS$WS(extends|implements)$WS$NWS" |

# pipeboth |

while read CLASS SOMEHOW_INHERITS_FROM PARENT
do

	echo "$CLASS $PARENT" >> "$ANCESTRY"
	echo "$CLASS"

done |

removeduplicatelines |

while read NAME
do

	debug "######## Doing $NAME"

	## Start with the class's name, and find each parent in turn:
	CURRENTCLASS="$NAME"
	while true
	do

		PARENT=`grep "^$CURRENTCLASS" $ANCESTRY | head -n 1 | takecols 2`
		# PARENT=`
			# java jlib.JReflect "$CURRENTCLASS" 2>/dev/null |
			# grep " extends " |
			# extractregex "$NWS$WS(extends|implements)$WS$NWS" |
			# takecols 3
		# `
		if [ ! "$PARENT" ]
		then
			debug "Breaking on $CURRENTCLASS with no parent"
			break
		fi

		if [ "$PARENT" = "java.lang.Object" ]
		then
			break
		fi

		debug "Adding $PARENT to $NAME"

		OLDNAME="$NAME"
		NAME="$PARENT -> $NAME"
		CURRENTCLASS="$PARENT"
		## To prevent infinite loops in case of impossible circular hierarchy!
		if echo "$OLDNAME" | grep "\<$CURRENTCLASS\>" > /dev/null
		then
			debug "Breaking on infloop since $CURRENTCLASS in $OLDNAME"
			break
		fi

	done

	echo "$NAME"

done |

if [ "$1" =  -tree ]
then sort | treesh -onlyat ">"
else sort
fi

