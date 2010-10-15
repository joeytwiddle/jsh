#!/bin/sh
. mailtools.shlib "$@"

NUM=`mailcount`

# echo "num = $NUM"

listmail "1-$NUM" |

grep "^.[NU]" |

sed 's+^..++' |

pipeboth |

while read MAILNUM FROM DAYW MON DAYM TIME LINESANDBYTESIGUESS SUBJECT
do

  echo "You have new mail from $FROM, with subject $SUBJECT" |
  pipeboth |
  txt2speech

  getmail -dont-mark-read "$MAILNUM" |
  stripheaders |
  pipeboth |
  txt2speech

done

