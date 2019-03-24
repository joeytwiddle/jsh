#!/bin/bash
# the following line would be "MB=$1", if you wanted to pass the mailbox
# to process as an argument to the script

# MB=~/debian.mbox
# formail -s bash -c "IFS=''; b=\`cat\`; test \$(date -d \"\$( echo \$b|formail -x Date )\" +%s) -ge \$(date -d \"7 days ago\" +%s) && echo -e \"\$b\n\n\"" <$MB >$MB.new && mv $MB.new $MB

## WARNING UNTESTED!
