# lsof -P -S 2 -n -V | grep ":" | grep -v "\<REG\>"
lsof -P -S 2 -V | grep ":" | grep -v "\<REG\>"
