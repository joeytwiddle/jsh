# Will use wget, curl, lynx, links or whatever else is available, to request the given (http) URL from the web and stream its content (not its headers) to stdout.
# Errors *and* general fun info stuff may appear on stderr.

# (This script should really be called cat_from_http_url.  If you want ftp://
# support and more (e.g. sftp), consider making cat_from_url a forker.)

URL="$1"

if which curl >/dev/null
then curl -s "$URL"
elif which wget >/dev/null
then wget -nv "$URL" -O -   ## BUG: sends info to stderr even on success
fi

