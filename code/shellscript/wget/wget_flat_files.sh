## Downloads a page with all its pre-requesites into the current folder.
## That's a bit scary - we might accidentally overwrite a separate index.html
## that happens to live where we are currently.
## (My other wget scripts usually write to a subfolder.)

echo "Creating tmp folder to avoid collisions."
mkdir tmp && cd tmp &&
wget -p -nd -k "$@"
# -p get pre-requisites (images,scripts)
# -nd do not create folders, drop all files in current folder
# -k rewrite links so they will hit the correct local file
# -N keep timestamps (I left this out, it appears to be on by default)

## Other wgets configurations I may want to offer:
##
##   wget -px to get a page without overlapping issues and with source document by path.
##
##   Something like wget --mirror but set to not rewrite links, e.g. to make
##   pure backups.
##   That was also desirable behaviour when re-running wgets on low-bandwidth
##   connections, because rewriting or some other option forced us to
##   re-download already cached files every time (ignored
##   modification-time/etag).
##

