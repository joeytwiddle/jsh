# Nicked off Deja from Larry G. Starr  - starrl@globaldialog.com
# Should now work but should use a temp file and split columns
# to avoid re-running the find/ls business.

find . -type f -print |
while read X; do
  ls -i "$X"
done |
keepduplicatelines -gap 1

# INODENAME=`
  # find . -type f -print |
  # while read X; do
    # ls -i "$X"
  # done
# `
# 
# INODE=`
  # echo "$INODENAME" |
  # keepduplicatelines 1
# `
# 
# echo "$INODE" |
# while read X; do
  # echo "$INODENAME" |
  # grep "$X"
  # echo
# done

# case $* in
# 
  # check)
    # # Original can't handle spaces:
    # # find . -type f -print | xargs ls -i | awk '{print $1}' | sort -n | uniq -d
    # find . -type f -print | while read X; do ls -i "$X"; done | awk '{print $1}' | sort -n | uniq -d
  # ;;
# 
  # find)
    # # Original can't handle spaces:
    # # find . -type f -print | xargs ls -i | sort -n +0 -1
    # # find . -type f -print | xargs ls -i | sort -n +0 -1
    # # find . -type f -print | while read X; do xargs ls -i "$X"; done | sort -n +0 -1
    # # ls -i `find . -type f -print` | sort -n +0 -1
    # find . -type f -print | while read X; do ls -i "$X"; done | sort -n +0 -1
  # ;;
# 
  # both)
    # NUMS=`hardlinkfind check`
    # REGEXP=`echo "$NUMS" | sed "s+$+\\\\\|+" | tr -d "\n" | sed "s+\\\\\|$++"`
    # hardlinkfind find | grep "$REGEXP"
  # ;;
# 
  # *)
    # echo "hardlinkfind check"
    # echo "  for a quick check."
    # echo "hardlinkfind find"
    # echo "  to find filenames - you will have to look for duplicate lines next to each other."
    # echo "hardlinkfind both"
    # echo "  will run them through each other to reveal something meaningful."
  # ;;
# 
# esac
