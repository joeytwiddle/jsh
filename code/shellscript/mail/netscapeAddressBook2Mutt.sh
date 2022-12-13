#!/bin/sh
# Does not do groups:
# abook --convert ldif /tmp/netadd.ldif  mutt tmp.txt

cat /tmp/netadd.ldif |
grep -E "^((cn|mail|xmozillanickname|member):|$)" |
tr "\n" "\t" |
sed "s/		/\\
/g"
