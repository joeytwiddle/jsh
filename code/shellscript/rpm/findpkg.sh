COM="env COLUMNS=184 dpkg -l"
if test "$1" = "-all"; then
  $COM "*$2*"
else
  $COM "*$1*" | grep -v "no description available"
fi
# dpkg -l "*$**" | egrep -v "^?n"
# dpkg -l "*$**" | grep "^[hi]"

