./dotex | tr "<" "\n" | tr ">" "\n" | egrep "\.[eps|ps]" | grep -v "(" | sed "s+^images/++"
