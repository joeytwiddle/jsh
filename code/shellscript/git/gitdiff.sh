## Shows differences between filesystem and staged commit.
## To see the difference between filesystem and repository, pass: --cached
git diff "$@" | diffhighlight | more
