#!/bin/sh
# Usage: multi_line_grep <start_pattern> <end_pattern> <files>...
# See also: pcregrep

# Unrelated!  Faster searching tools:
# http://unix.stackexchange.com/questions/69299/grep-of-many-keywords-over-many-files-speeding-it-up
# http://unix.stackexchange.com/questions/3086/command-line-friendly-full-text-indexing

# Solutions below come from: http://unix.stackexchange.com/questions/112132/how-can-i-grep-patterns-across-multiple-lines

start="$1"
end="$2"
shift; shift
whole="$start.*$end"
# whole could be more complex, if you want to match things in the middle.

sed -n "/$start/{:start /$end/\!{N;b start};/$whole/p}" "$@"

# Perl alternatives:
#perl -e '$f=join("",<>); print $& if $f=~/foo\nbar.*\n/m' file
#perl -n000e 'print $& while /^foo.*\nbar.*\n/mg' file
#perl -n0777E 'say $& while /^foo.*\nbar.*\n/mg' foo

