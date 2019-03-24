#!/usr/bin/env bash

# Just like normal debuild, but use ccache for greater speed
# And use multiple cores to build in parallel.  (I don't know why, but #cores + 1 is the recommendation.)
# -nc tells dpkg-buildpkg that it should not clean the folder first, so make will probably skip already built files
# -uc tells it not to sign the changes file, which is just unneccessary when testing
# -us do not sign the source package

num_cores=$(nproc --all 2>/dev/null || sysctl -n hw.ncpu)

debuild --prepend-path=/usr/lib/ccache -j$((num_cores+1)) -nc -uc -us "$@"
