#!/bin/sh
## TODO: doc storing
##       does user need / want help: show it
##       make this a compiler (or memoer!) for efficiency

echo ">$0<"
echo "-$*-"

append () {
	# cursegreen
	# echo "$2=\"\$$2\"'$1'"
	# cursenorm
	eval "$2=\"\$$2\"'$1'"
}

readargspec () {

read DESCRIPTION

TESTS=""

while read TYPE VARNAME DOC DEFAULT
do

	OPTION=`echo "-$VARNAME" | tolowercase | tr '_' '-'`

	if test $TYPE = bool
	then

		append "
			if test \"\$1\" = $OPTION
			then $VARNAME=true; shift; continue
				  echo \"Parsed $VARNAME\"
			fi
		" TESTS

	elif test $TYPE = opt
	then

		append "
			if test \"\$1\" = $OPTION
			then $VARNAME=\"\$2\"; shift; shift; continue
			fi
		" TESTS

	fi

done

}

TESTSFILE=`jgettmp parseargs_tests`

cat | trimempty > $TESTSFILE

readargspec < $TESTSFILE

# TESTS=`cat $TESTSFILE`
# cat $TESTSFILE
# echo "$TESTS"

while test "$1"
do

	eval "$TESTS"
	break

done

jdeltmp $TESTSFILE
