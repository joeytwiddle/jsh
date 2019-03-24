#!/bin/bash

# From: http://stackoverflow.com/questions/460331/git-finding-a-filename-from-a-sha1
total="$(git log --pretty=format:'%T %h %ai %s' | wc -l)"
#echo "Will scan $total commits..." >&2

# go over all trees
current=0
git log --pretty=format:'%T %h %ai %s' |
reverse |
while read tree commit date time timezone subject
do
  [ "$((current % 50))" = 0 ] && echo "$current / $total" >&2
  current=$((current + 1))

  git ls-tree -r $tree |
  while read a b hash filename
  do
    echo "hash=$hash commit=$commit date=$date@$time filename=$filename subject=$subject"
    [ "$b" != blob ] && echo "--- THAT WAS NOT A BLOB ---"
  done
  # tree=$tree @$timezone
  # a=$a b=$b
done |
# The above will produce the same hash many times, for every commit it exists in
# (When jsh was on 2,000 commits, it produced 1.6 million lines, ~250MB of data!)
# But we can pick out the first of each hash
# (With the above jsh example, we ended up with 6,000 unique hashes, ~900k of data!)
#sort | uniq -w 45 | sort -k 3
cat

# After generating this data, you look for files that belonged in it:
#
#     find . -type f | while read F; do obj_hash="$(git hash-object "$F")"; grep "^hash=$obj_hash " all_unique_hashes.out; done
