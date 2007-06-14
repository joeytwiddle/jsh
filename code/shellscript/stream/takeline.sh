## See also: getline (better+faster with sed)

LINENUM=`expr "$1" - 1`
shift

cat "$@" |

drop $LINENUM |

head -n 1

# cat > /dev/null
