AGEFILE=`jgettmp findaged`

AGE="$1"
shift

touch -d "$AGE ago" $AGEFILE

find . -not -newer $AGEFILE "$@"

jdeltmp $AGEFILE
