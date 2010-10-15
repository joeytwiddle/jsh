#!/bin/sh
CGI=`echo "$@" | tr ' ' '+'`
echo "http://www.freshmeat.net/search?section=projects&q=$CGI"
