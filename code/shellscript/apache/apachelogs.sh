root=/mnt/hwibot
[ -d "$root" ] || root=/
tail -n 5 -f "$root"/var/log/apache2/*.log |

sed -u 's+\(.*\)"\(.*\)"+\1{\2}+' |

highlight '{[^}]*}' magenta |
highlight '\[[^]]*\]' grey |
highlight '" \(200\|304\)\>' green |
highlight '" 404\>' blue |
highlight '" 100\>' red |
# Unrecognised numbers are red:
highlight '" [0-9][0-9][0-9] ' red |

cat

