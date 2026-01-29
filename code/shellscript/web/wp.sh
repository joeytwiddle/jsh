#!/bin/sh

query="$*"

if [ -z "$query" ]
then
    echo "Usage: wp <search_term>"
    exit 1
fi

## OLD: Wikipedia summary lookup over domain protocol (IP but not TCP or HTTP).
## From: https://dgl.cx/2008/10/wikipedia-summary-dns
#
#response="`
#	dig +short txt "$query".wp.dg.cx |
#	# host -t txt "$query".wp.dg.cx |
#	# grep " descriptive text " |
#	# afterfirst " descriptive text " |
#	sed 's+" "++g' |   ## Trim the ..." "... breaks
#	sed 's+^"++ ; s+"$++'   ## Trim the leading and trailing "
#`"
#
#if [ "$response" ]
#then
#	COLBROWN=`cursered`
#	COLNORM=`cursenorm`
#	COLROYAL=`curseblue;cursebold`
#	echo "$response" |
#	# sed 's+\\194\\160\([0-9A-Za-z.]*\)'+"$COLBROWN\1$COLNORM+g" |
#	sed 's+\\194\\160'+" +g" |
#	sed 's+\\194\\178'+"^2+g" |
#	sed "s+http://[^ ]*+$COLROYAL\0$COLNORM+g" |
#	cat
#else
#	echo "No Wikipedia results for \"$query\""
#fi

# NEW: Using Wikipedia's API

# 1. Ask OpenSearch for the best-matching title (Case-Insensitive/Fuzzy)
# We take the first result from the suggestions array
suggested_title=$(curl -s "https://en.wikipedia.org/w/api.php?action=opensearch&search=${query// /%20}&limit=1&format=json" | jq -r '.[1][0]')

if [ "$suggested_title" == "null" ] || [ -z "$suggested_title" ]; then
    echo "No results found for '$query'."
    exit 1
fi

# 2. Fetch the summary using the corrected title
# Using a custom User-Agent is recommended by Wikimedia API guidelines
response=$(curl -s -L -H "User-Agent: BashWikiScript/1.0 (contact: joeytwiddle@gmail.com, source: https://github.com/joeytwiddle/jsh/web/wp.sh)" "https://en.wikipedia.org/api/rest_v1/page/summary/${suggested_title// /%20}")

title=$(jq -r '.title // empty' <<< "$response")

if [ -z "$title" ] || [ "$title" == "Not found." ]
then echo "Page not found for \"${suggested_title}\""
else
    #echo -e "\033[1;34m$title\033[0m"
    jq -r '.extract' <<< "$response"
fi
