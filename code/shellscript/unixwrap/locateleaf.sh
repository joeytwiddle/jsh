#!/bin/sh
# Lists only those fs nodes which match the given string in their
# basename/filename.  (Normally locate lists everything underneath a matching
# folder.)
#
# So whereas `locate home` would show *every* fs node under the /home folder,
# `locateleaf home` will show only nodes whose *filename* contain "home".
#
# You may still see matching directories in the result list, despite being
# "branches" and not "leaves".  We named this script `locateleaf` because it is
# cuter than `locatenode`.
#
# To find files only, or folders only, you are recommended to pipe to jsh
# functions `| dirsonly` or `| filesonly` .

#locate "$1" | grep "^.*/[^/]*$1[^/]*$"

unj locate -b "$1"
