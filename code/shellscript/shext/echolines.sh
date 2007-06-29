## Prints each argument provided on a separate line.
## Essentially converts an argument list to a stream (line-delimited rather than space-delimited).
## It might be considered the opposite withalldo, which converts a stream/list of arguments into arguments in a shell call.

for ARG
do echo "$ARG"
# do printf "%s" "$ARG"
done

