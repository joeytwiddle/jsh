sed 's/[ -~]*\(..\)/\1\
/g' | sed 's/[ -~]*$//' | trimempty
# sed 's/[^ -~]./<ch val="\0">/g'
