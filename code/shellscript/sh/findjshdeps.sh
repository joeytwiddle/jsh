## To find what external (and internal) programs a jsh script depends on, run this.  Without arguments, finds dependencies for all jsh scripts.  You need to do this to find reverse-dependencies (scripts which depend on a particular script).
## Note: you need to have all the programs on your system (!), otherwise add them to $LIST below.
## Hence, this script will eventually export the dependency info, so it can be useful on machines without those programs.
## (Eg. installj and updatejsh will remove scripts from $JPATH/tools if their dependencies are not met.)
## (Or: a . checkdependencies call will be added at the to of each script.)
## But it is often worth knowing the reverse dependencies too (what depends on me?) eg. to check if functionality change is ok.

## Note: We only examine .sh scripts for good reason.  TODO: I need to rename those .sh's which do not yet have an extension!

## TODO: Once dependencies for a script are found, allow insertion of dependency meta-info block in script.
##       Will it be a code block or will it actually be a call that checks?!
## TODO: Somehow we want efficient lookup of which package binaries come from.

## BUGS: Try it on remotediff or another script containing "...".  The "..." is treated as regexp.  :-(

## First experiment selfmemoing =)
# echo "before: >$0< >$1< >$2< >$3<" >&2
. selfmemo -nodir -d $JPATH/code/shellscript - "$0" "$@"; shift
# echo "after:  >$0< >$1< >$2< >$3<" >&2

PATHS_TO_SYSTEM_BINARIES="/bin /usr/bin /sbin"

## Ever-present programs which we don't want to observe dependencies on:
## TODO: turn this into a line-delimited list, and check which packages the progs belong to.
EVER_PRESENT='^\('
EVER_PRESENT="$EVER_PRESENT"'printf\|echo\|test\|clear\|cp\|mv\|ln\|rm\|ls\|kill\|'
EVER_PRESENT="$EVER_PRESENT"'touch\|mkdir\|tr\|sh\|nice\|sleep\|date\|'
EVER_PRESENT="$EVER_PRESENT"'chmod\|chgroup\|chown\|cat\|more\|head\|tail\|grep\|egrep\|du\|'
EVER_PRESENT="$EVER_PRESENT"'true\|false\|which\|'
# EVER_PRESENT="$EVER_PRESENT"'mount\|sed\|cksum\|'
EVER_PRESENT="$EVER_PRESENT"'\)$'

## Will show up jsh programs as well as /bin ones.  (Faster without; even faster if specialised out!)
## Note: sometimes you will get duplicates, eg. 'lynx' and 'lynx (jsh)' in which case we have to decide whether on not the jsh one is really a dependency.
BOTHER_JSH=true
DISCRIMINATE_JSH=true
if test ! $BOTHER_JSH; then DISCRIMINATE_JSH=; fi



function trimsmall () {
  grep -v '^.$' |
  grep -v '^..$'
}



### Compile a list of programs which scripts could possibly depend on:

LIST=`jgettmp possdepslist`

(
## TODO: Haven't yet included $HOME/bin (could just use $PATH!)
 find $PATHS_TO_SYSTEM_BINARIES -maxdepth 1 -type f | afterlast / | trimsmall
 if [ $BOTHER_JSH ]
 then
   find $JPATH/tools -maxdepth 1 -type l | afterlast / | trimsmall |
   if [ $DISCRIMINATE_JSH ]
   then sed 's+$+ (jsh)+'
   else cat
   fi
 fi
) |
grep -v "$EVER_PRESENT" |
cat > $LIST

# echo "There are `countlines $LIST` possible dependencies!" >&2



### For each script, extract its words, and grep the proglist for the words:

TMPEXPR=`jgettmp findjshdeps_expr_partway`

if $DISCRIMINATE_JSH
then 
	endregexp () {
		printf '\\)\( \|$\)'
	}
else
	endregexp () {
		printf '\\)$'
	}
fi

if [ "$*" ]
then

  for X
  do [ -f "$X" ] && echo "$X" || echo `realpath \`which "$X"\``
  done

else

  ## Problem is, this cd doesn't get passed through the pipe!
  # cd $JPATH/code/shellscript
  # find . -type f -name "*.sh" -not -path "*/CVS/*"
  find $JPATH/code/shellscript -type f -name "*.sh" -not -path "*/CVS/*"

fi |

while read SCRIPT
do
	
	## Extract all words in the script, and create a regexp from them:

	REGEXP=`
		printf '^\\('
		cat "$SCRIPT" |
		sed 's+#.*++' | ## Removes all comments from file (does get false-positives though)
		extractregex '[A-Za-z0-9_\-.]+' | ## couldn\'t get \<...\> to work
		removeduplicatelines |
    ## Hack because grep doesn\'t handle long lists well, and we occasionally (accidentally) hit binaries!
    head -500 |
    ## Escape special chars for regexp (first '.', then "\[]")
    sed 's#\.#\\\.#g;s#\(\\\|\[\|\]\)#\\\1#g' |
		## Note: no need to remove shell builtin words because any which were in the proglist have been removed by EVER_PRESENT.
		sed 's+$+\\\|+' |
		tr -d '\n' |
		sed 's+\\\|$++'
		endregexp
	`

	## Use the RE to extract any progs from the proglist which this scripts refers to:

	## TODO: why not just head -250 before the tee above?

  # echo "$REGEXP" >&2

  grep "$REGEXP" "$LIST" &&
  echo "  is/are needed for $SCRIPT" ||
  echo "$SCRIPT is pure sh (or its dependencies are not present)" >&2
  echo

done

## TODO: Show reverse dependencies.
