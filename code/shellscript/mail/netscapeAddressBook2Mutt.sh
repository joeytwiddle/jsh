# Does not do groups:
# abook --convert ldif /tmp/netadd.ldif  mutt tmp.txt

cat /tmp/netadd.ldif |
egrep "^((cn|mail|xmozillanickname|member):|$)" |
tr "\n" "\t" |
sed "s/		/\\
/g"
