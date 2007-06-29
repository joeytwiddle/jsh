if [ "$1" = -s ] || [ "$1" = -scale ]
then
	SCALE="scale=$2 ; "
	shift; shift
fi
# SCALE="length=3 ; "
# SCALE="scale=3 ; "
# SCALE="length(3) ; "
# SCALE="scale=`echo "scale($*)" | bc` ; "
echo "$SCALE$*" | bc
