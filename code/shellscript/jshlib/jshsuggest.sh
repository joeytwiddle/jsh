if [ "$DO" ]
then verbosely "$@"
else echo "`cursegreen;cursebold`[Suggestion]`cursebold` % `cursecyan`$*   `curseyellow;cursebold`(rerun with DO=1)`cursenorm`"
fi
