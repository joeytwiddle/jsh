#!/bin/bash
## Lists all+ executables and jsh shellscripts which could be called by the target perl/shell/any-script.

## TODO: docs!  I think if you give it an absolute path it analyses that script, otherwise it tries to find the given jsh script.

## Performs stripping of comments, etc., ATM specifically for shellscripts, to reduce false positives.
## Could drop words which are obviously directories, eg. "/wget/".

# ## To find what external (and internal) programs a jsh script depends on, run this.  Without arguments, finds dependencies for all jsh scripts.  You need to do this to find reverse-dependencies (scripts which depend on a particular script).
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

export IKNOWIDONTHAVEATTY=1

## The use of PWDBEFORE gets us around the fact that selfmemo might change dir (to /) and then call this script again.
[ "$PWDBEFORE" ] || export PWDBEFORE="$PWD"
## First experiment selfmemoing =)
# echo "before: >$0< >$1< >$2< >$3<" >&2
# . selfmemo -nodir -d $JPATH/code/shellscript - "$0" "$@"; shift
## BUG: Really want the test to be -f on script, but we don't know scriptfile path yet!
# echo "after:  >$0< >$1< >$2< >$3<" >&2
cd "$PWDBEFORE"

PATHS_TO_SYSTEM_BINARIES="/bin /usr/bin /sbin" # /usr/sbin dunno why really should be in!

## Ever-present programs to ignore - we don't want to manage these as dependencies:
## TODO: turn this into a line-delimited list.
## TODO: For the sake of curiousity, check which packages the progs belong to.
## CONSIDER: This will mask out any jsh script with the same name - do we ever want to consider them as deps.  (We sometimes use a bash script with the same name as a fallback if the binary is not present.  Probably not of interest for coreutil packages, only optional ones.)
EVER_PRESENT='^\('
## New: Generate the list automatically from coreutils system package:
EVER_PRESENT="$EVER_PRESENT""`memo eval "dpkg -L coreutils | grep /bin/ | filesonly -inclinks | filter_list_with test -x | afterlast /bin/ | toregexp | sed 's+$+\\\\\\|+' | tr -d '\n'"`"
## Old: Manually entered list.
EVER_PRESENT="$EVER_PRESENT"'sed\|file\|' # file not because it's always installed, but because it appears so often as a word in docs or as a varname etc.
EVER_PRESENT="$EVER_PRESENT"'printf\|echo\|test\|clear\|cp\|mv\|ln\|rm\|ls\|kill\|'
EVER_PRESENT="$EVER_PRESENT"'touch\|mkdir\|tr\|sh\|nice\|sleep\|date\|'
EVER_PRESENT="$EVER_PRESENT"'chmod\|chgroup\|chown\|cat\|more\|head\|tail\|grep\|egrep\|du\|'
EVER_PRESENT="$EVER_PRESENT"'true\|false\|which\|env\|'
# EVER_PRESENT="$EVER_PRESENT"'mount\|sed\|cksum\|'
## Dunno whether to document dependency on expr.  It's builtin to modern shells, and part of coreutils.  Only really needed if there is ever a system out there without it as binary or builtin to shell.  It may present dependency resolution problems, if the binary is absent, and jsh doesn't realise expr is provided by sh.
EVER_PRESENT="$EVER_PRESENT"'expr\|'
EVER_PRESENT="$EVER_PRESENT"'\)$'
# jshinfo "EVER_PRESENT=$EVER_PRESENT"

## Will show up jsh programs as well as /bin ones.  (Faster without; even faster if specialised out!)
## Note: sometimes you will get duplicates, eg. 'lynx' and 'lynx (jsh)' in which case we have to decide whether on not the jsh one is really a dependency.
BOTHER_JSH=true
DISCRIMINATE_JSH=true
[ ! $BOTHER_JSH ] && DISCRIMINATE_JSH=



trimsmall () {
  grep -v '^.$' |
  grep -v '^..$'
}



### Compile a list of programs which scripts could possibly depend on:

LIST=`jgettmp possdepslist`

(
## TODO: Haven't yet included $HOME/bin (could just use $PATH!)
 find $PATHS_TO_SYSTEM_BINARIES -maxdepth 1 -type f | notindir CVS | afterlast / | trimsmall
 if [ -n "$BOTHER_JSH" ]
 then
   find $JPATH/tools -maxdepth 1 -type l | afterlast / | trimsmall |
   if [ -n "$DISCRIMINATE_JSH" ]
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
  # do
		# set -x
		# if [ -f "$X" ]
		# then echo "$X"
		# else
			# WHICHX=`which "$X" 2>/dev/null`
			# if [ -f "$WHICHX" ]
			# then echo `realpath "$WHICHX"`
			# else echo "$PWD/$X"
			# fi
		# fi
		# set +x
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
    head -n 500 |
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
  echo "  may be needed for $SCRIPT" ||
  echo "$SCRIPT probably runs standalone (or its dependencies are not present)" >&2
  echo

done

## TODO: Show reverse dependencies.

jdeltmp "$LIST" "$TMPEXPR"
