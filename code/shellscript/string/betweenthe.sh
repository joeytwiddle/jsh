# Strangely, betweenthe implies their are >2 "$@"s
# and the output should be multiple answers, on consecutive lines
sed "s/\n/\\\n/g" | tr "$@" "\n"
# sed "ss$*s\nsg" | tr "\n" "\n"
# sed "s/\n/\\n/g"
