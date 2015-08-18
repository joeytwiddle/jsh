#!/bin/sh

prettyApp=$HOME/npm/lib/node_modules/prettydiff/api/node-local.js

mode=beautify

if [ "$#" = 0 ]
then node "$prettyApp" source:"`cat`" readmethod:screen     mode:"$mode" report:false
elif [ "$#" = 1 ]
then node "$prettyApp" source:"$1"    readmethod:filescreen mode:"$mode" report:false
elif [ "$#" = 2 ]
then node "$prettyApp" source:"$1"    readmethod:file       mode:"$mode" report:false output:"$2"
fi

