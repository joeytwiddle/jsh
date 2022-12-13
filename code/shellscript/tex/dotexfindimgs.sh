#!/bin/sh
# ./dotex | tr "<" "\n" | tr ">" "\n" | grep -E "\.[eps|ps]" | grep -v "(" | sed "s+^images/++"

while true; do echo; done |

./dotex 2>&1 |

grep "Could not find figure file" |

sed 's+.*Could not find figure file ++;s+; continuing++' |

afterlast / |

while read LOSTIMG
do

	echo "### Seeking copy of $LOSTIMG"
	find ~/joey/phd/ -name "$LOSTIMG" -printf "%s %p\n"

done
