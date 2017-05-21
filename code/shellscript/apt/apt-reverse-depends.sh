#!/bin/sh

apt-cache rdepends "$1"

# Note: That shows both depends and suggests, so you may need to inspect the individual packages to see whether they depend on or only suggest the package of interest.

# Alternatives:
#   apt-get install apt-rdepends && apt-depends ...
# or
#   apt-get install ubuntu-dev-tools && reverse-depends ...
# or
#   apt-cache showpkg ...   (unlike show, has a section for reverse dependencies)
# or
#   apt-get install aptitude &&
#   aptitude why ...   (only works on installed packages and
#                       only gives this system's specific reason)
