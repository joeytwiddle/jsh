lynx -dump "http://www.filesearch.ru/cgi-bin/s?q=$*&t=f" |
  grep "q=" | afterfirstall "q="
