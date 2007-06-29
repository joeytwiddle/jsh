## Simply returns the last argument in the list you provide
while [ "$2" ]
do shift
done
echo "$1"
