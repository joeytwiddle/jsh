#!/bin/sh
# From: http://stackoverflow.com/questions/460331/git-finding-a-filename-from-a-sha1

# Find the SHA1 of the blob (file) you want to search for by hashing an existing copy:
#   git hash-object /tmp/i_found_this_is_it_old.cpp

# In the one test I did so far, the *last* line displayed was the commit that added the given blob.

obj_hash="$1"

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
while read tree commit subject
do
     git ls-tree -r $tree | grep "\<$obj_hash\>" |
     while read a b hash filename
     do
          if [ "$hash" = "$obj_hash" ]
          then
               f=$filename
               echo "Found $f in $a $b $hash $filename tree=$tree commit=$commit subject=$subject"
               break
          fi
          if [ -n "$f" ]; then break; fi
     done
     if [ -n "$f" ]; then break; fi
done

