#!/bin/sh
# From: http://stackoverflow.com/questions/460331/git-finding-a-filename-from-a-sha1

# Find the SHA1 of the blob (file) you want to search for by hashing an existing copy:
#   git hash-object /tmp/i_found_this_is_it_old.cpp

# In its current form, the last line displayed is the commit that added the given blob.
# We could reverse the output of git rev-list in order to search history chronologically.

if [ "$1" = -f ]
then
     file="$2"
     obj_hash=`git hash-object "$file"`
else
     obj_hash="$1"
fi

if false
then
# Alternative implementation:
#git rev-list <commit-list> |
git rev-list --all |
#xargs -n1 -iX sh -c "git ls-tree -r X | grep '\<$obj_hash\>' && echo X"
while read rev
do
     git ls-tree -r "$rev" |
     grep "\<$obj_hash\>" >/dev/null && echo "$rev"
done
exit
fi

# go over all trees
git log --pretty=format:'%T %h %s' |
#reverse |
while read tree commit subject
do
     git ls-tree -r $tree | grep "\<$obj_hash\>" |
     while read a b hash filename
     do
          if [ "$hash" = "$obj_hash" ]
          then
               echo "Found a=$a b=$b filename=$filename tree=$tree commit=$commit subject=$subject" >&2
               echo "$commit -- $filename"
               # We cannot break out of the outer loop, but we can exit :)
               #exit
               # But we might not want to; we probably want to keep looking backwards for the *first* commit that added that blob.
          fi
     done
done

