#!/bin/sh
set -e

which renice >/dev/null 2>&1 && renice -n 10 -p $$
which ionice >/dev/null 2>&1 && ionice -c 3 -p $$

#find "$@" -iname "*.PNG" |
find "$@" -iname "*.PNG" -or -iname "*.BMP" -or -iname "*.JPG" -or -iname "*.JPEG" -or -iname "*.WEBP" |

grep -v -i -F ".smaller." |
grep -v -i -F ".reduced." |
grep -v -i -F ".shrunken." |
grep -v -i -F ".keep_high_res." |

sort |

while read filename
do shrinkimage "$filename"
done
