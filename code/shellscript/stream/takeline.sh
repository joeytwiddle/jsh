LINENUM=`expr "$1" - 1`
shift

cat "$@" |

drop $LINENUM |

head -1

# cat > /dev/null
