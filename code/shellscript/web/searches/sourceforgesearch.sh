CGI=`echo "$@" | tr ' ' '+'`
echo "http://www.sourceforge.net/search?type_of_search=soft&exact=1&words=$CGI"
