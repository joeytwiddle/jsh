## Source me from a bash-shebanged script (will not work from an sh-shebanged script)

failed=''
for EXE
do

	if ! which "$EXE" > /dev/null # && [ ! "$OVERRIDE_REQUIRE_EXES" ]   ## <-- CONSIDERING
	then

		echo "`curseyellow;cursebold`WARNING: `cursenorm`Required executable `cursered;cursebold`$EXE`cursenorm` is missing!" >&2
		failed=1

	fi

done

if [ "$failed" ]
then exit 1
fi
