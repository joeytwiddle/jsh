#!/bin/bash
target="$1"

hash_folder() {
  echo "Hashing $1" >/dev/stderr
  pushd "$1" >/dev/null

  # Hash all the files
  find . -type f | sort | xargs md5sum |

  # Hash that list of hashes, discard the newline character,
  # and append the folder name
  md5sum - | tr -d '\n'
  printf "  %s\n" "$1"

  popd >/dev/null
}

find "$target" -type d |
while read dir
do hash_folder "$dir"
done |
sort |
# Display only the lines with duplicate hashes (first 32 chars are duplicates)
uniq -D -w 32
