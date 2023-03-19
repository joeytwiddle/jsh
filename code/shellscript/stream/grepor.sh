#!/usr/bin/env bash
set -e

args=("$@")
for (( i = 0; i < ${#args[@]}; i++ ))
do args[$i]="-e${args[$i]}"
done

exec grep "${args[@]}"
