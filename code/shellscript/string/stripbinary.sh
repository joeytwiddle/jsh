## An alternative to striptermchars, but not as good!

## Or is it keepascii.sh?!

# TOKILL=""
# ## We prolly wanna keep the DOS extra newline - what is it?
# for X in `seq 0 9; seq 10 12; seq 14 31; seq 127 255`
# do TOKILL=
# 
# oh fuck it
# 
# sed 's+

## Good except for newlines:
hexdump -C |
sed 's+.*|\(.*\)|+\1+' |
tr -d '\n'

## Another possibility:
# sed 's+[^A-Za-z0-9_\-!"...]++g'
