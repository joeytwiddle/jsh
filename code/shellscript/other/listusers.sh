#! /bin/sh
count=0
exec 3<&0 </etc/passwd
while IFS=: read username rest
do
         echo user $count is $username 
         count=`expr $count + 1`
done 
exec <&3
echo count=$count
