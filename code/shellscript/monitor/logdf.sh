#!/bin/sh
(
printf "TIME="
date "+%s"
df 2>/dev/null
) >> $JPATH/logs/df.log
