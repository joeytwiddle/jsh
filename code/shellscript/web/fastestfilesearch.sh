lynx -dump "http://www.filesearch.ru/cgi-bin/s?q=$@&t=f" |
  grep "$@" | grep "^ " | afterfirstall " "
  # grep "q=" | afterfirstall "q="
