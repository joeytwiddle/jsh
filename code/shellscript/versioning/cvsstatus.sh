## Only tested on up-to-date checkout :P

cvs status "$@" 2>&1 |

## Positive match for the info we want:
# grep "^File:" |

## Match for the data we don't want (allows unrecognised errors through)
grep -v "^cvs status: Examining " |
grep -v "^[ =]" |
grep -v "^$" |

# takecols 4 2
# dropcols 1 3
sed ' s+^File: ++ ; s+\<Status: ++ '

