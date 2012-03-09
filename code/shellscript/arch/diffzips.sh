## No need to unpack them, we can check the file hashes in the index.
diffcoms -vimdiff "unzip -v \"$1\" | grep -v '\.svn'" "unzip -v \"$2\" | grep -v '\.svn'"
# diffcoms -color "unzip -v \"$1\" | grep -v '\.svn'" "unzip -v \"$2\" | grep -v '\.svn'"
