# jsh-ext-depends: sed
SRCH="$@"
sed ";s+\(.*\)$SRCH.*+\1+;"
