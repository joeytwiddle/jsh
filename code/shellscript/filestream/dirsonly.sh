while read NODE
do [ -d "$NODE" ] && echo "$NODE"
done
