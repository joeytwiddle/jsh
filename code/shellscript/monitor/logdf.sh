(
printf "TIME="
date "+%s"
df
) >> $JPATH/logs/df.log
