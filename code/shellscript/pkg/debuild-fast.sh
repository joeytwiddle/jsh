# Just like normal debuild, but use ccache for greater speed
debuild --prepend-path=/usr/lib/ccache "$@"
