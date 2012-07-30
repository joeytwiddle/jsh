## Shows unstaged differences between filesystem and repository.
## To see the staged differences, pass: --cached
## To see both, ... ?
git diff "$@" | diffhighlight | more
## Alternatively, diffs may be colored by setting [color "diff"] section of .gitconfig

## Interestingly, git itself calls 'pager' which points to /bin/less on my
## system, and shows colours just fine.  But if we call pager instead of more
## above, the colour escape codes do not come out nicely!  It can be achieved
## with pager -R or less -R.
