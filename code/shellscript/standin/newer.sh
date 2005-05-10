# jsh-depends: unj mynewer
## Returns true (0) if they are the same age:
unj -quiet newer "$@" ||
## Used to return false (1) if they were the same age, but now it behaves the same as the other :)
mynewer "$@"
