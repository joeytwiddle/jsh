root=/mnt/hwibot
[ -d "$root" ] || root=/

tail -n 15 -f "$root"/var/log/apache2/*.log |

# Hide bots, may hide wanted stuff too.
# grep -v "HTTP/.*[Bb][Oo][Tt]" |
# grep -v "HTTP/.*compatible.*[Bb][Oo][Tt]/" |
## Alternatively, highlight them:
highlight "(compatible; .*[Bb][Oo][Tt]/[^)]*)" red |
## We might also want to drop "spider/"

sed -u 's+\(.*\)"\(.*\)"+\1{\2}+' |

## Reduce the length of the lines a little bit
## Hide date fields
sed -u 's+\[[^]]*[0-9][0-9]:[0-9][0-9]:[0-9][0-9][^]]*\] ++' |
## Hide referrer
sed -u 's+"http://[^"]*" ++' |

highlight '{[^}]*}' magenta |
highlight '\[[^]]*\]' grey |
highlight '" \(200\|304\)\>' green |
highlight '" 404\>' blue |
highlight '" 100\>' red |
# Unrecognised numbers are red:
highlight '" [0-9][0-9][0-9] ' red |

cat

