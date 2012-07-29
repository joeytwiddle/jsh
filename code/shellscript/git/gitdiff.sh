## Shows unstaged differences between filesystem and repository.
## To see the staged differences, pass: --cached
## To see both, ... ?
git diff "$@" | diffhighlight | more
## Alternatively, diffs may be colored by setting [color "diff"] section of .gitconfig
