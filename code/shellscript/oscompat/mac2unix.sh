#!/usr/bin/env sh

if [ "$*" ]
then
        for FILE
        do cat "$FILE" | dos2unix | pipebackto "$FILE"
        done
else
        tr '\r' '\n'
fi
