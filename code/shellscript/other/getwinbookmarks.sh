echo "<html>"
echo "<body>"

find /mnt/filfirin/windows/Favorites -name "*.url" > $JPATH/tmp/getwinbms.tmp

exec < $JPATH/tmp/getwinbms.tmp
while read FILE; do
  NAME=`echo "$FILE" | after "Favorites/" | before ".url$"`
  URL=`cat "$FILE" | grep "^URL=" | after "=" | stringtrim`
  # echo "NAME=$NAME"
  # echo "URL=$URL"
  echo '<a href="'"$URL"'">'"$NAME"'</a>'
  echo '<br>'
done

echo "</body>"
echo "</html>"
