#!/usr/bin/env bash
set -e

args=()
for arg in "$@"
do
	if [[ "$arg" == -* ]]
	then
		args+=("$arg")
	else
		args+=("-e")
		args+=("$arg")
	fi
done

exec grep "${args[@]}"
