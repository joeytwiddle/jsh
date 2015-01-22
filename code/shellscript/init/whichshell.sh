# @sourceme

# whichshell 2>&- || SHTYPE=SH_OLD : do NOT eliminate this first comment line!  Eh?  Why not.  :P
# No shebang!
#*TAG:32236 5:Jun 28 1998:0755:whichshell:
# Author: Brian Hiles <bsh@iname.com>
# Copyright: (c) 1997-1998
# Description: determine which shell this script runs under
# Inspired-by: heiner@hsysnbg.nbg.sub.org (Heiner Steven)
# Inspired-by: heiner@darwin.noris.de (Heiner Steven)
# Name: whichshell
# Sccs: @(#)whichshell.sh 1.2 1998/05 bsh@iname.com (Brian Hiles)
# Usage: whichshell [script [script-parameter]... ]
# Version: 1.2

#XXX consider allowing "init.KSH" instead of "init.KSH_19??"
#XXX SH_OLD -> SH_1977, etc.

#01 COMMON CORE CODE
unset a || SHTYPE=SH_OLD  # ignore potential error message
set a = "$*"
test "$a" = "$*" && goto CSH

#02 BOURNE FAMILY
PATH= export PATH
case $3 in
'') shcmd='echo ' ;;
*) set -- $3
 shcmd=". ${1?}."  # bash bug: "var=value shift" not poss!
 shift ;;
esac
# From: werner.burri@ubs.com (Werner Burri)
# zsh 2.5.x/3.0.x error: "whichshell: read-only variable: LINENO [60]"
IFS=' ' LINENO= RANDOM= a=$[1] retval=0
a=2 a=$[3] wait 2>/dev/null
case $a:$LINENO:$RANDOM in
1*) # use BASH_VERSION?
 if (: ${!a}) 2>/dev/null
 then SHTYPE=BASH_2  # bash 2.00 (IRIX 5.x)
 else SHTYPE=BASH_1  # bash 1.14.7(2) (IRIX 5.x)
  # next two lines courtesy werner.burri@ubs.com (Werner Burri)
  [ "${ZSH_VERSION:-${VERSION#zsh }}" > 2.5 ] &&
  SHTYPE=ZSH_${ZSH_VERSION:-${VERSION#zsh }}
 fi ;;
'$[3]::'*)
 SHTYPE=KSH_1986 ;;  # ksh 6/3/86
$\[[13]]:1:[0-9]*)
 # some ksh88s are modified to apparently conform to POSIX 1003.2
 if (: ${.sh.version}) 2>/dev/null
 then SHTYPE=KSH_1993  # ksh M-12/28/93e (SunOS 4.x, IRIX 5.x)
 else SHTYPE=KSH_1988  # ksh 11/16/88f (AIX 4.x, OSF/1 3.x)
  #SHTYPE=KSH_1988POSIX # ksh 11/16/88f (AIX 4.x, OSF/1 3.x)
 fi ;;
'$[3]::')
 SHTYPE=SH_POSIX ;;  # sh SVR4 (UnixWare)
2::) case $SHTYPE in
 SH_OLD) ;;
 *) if (_(){ :;}) 2>/dev/null
  then SHTYPE=SH_ # sh SVR2/3
  else SHTYPE=SH_OLD
  fi ;;
 esac ;;
#3*) SHTYPE=ZSH_ ;;   # zsh 2.3.1 (IRIX 5.x)
*) retval=1 SHTYPE=`
  IFS=/
  set -- ${SHELL:-UNKNOWN}
  until test \$# -eq 1
  do shift
  done
  echo "\$1"
 ` ;;
esac
eval $shcmd$SHTYPE
exit $retval

#03 CSHELL FAMILY
CSH:
unset path
if ("X$a" == X) then
 set shcmd = 'echo '
else
 set argv = ($a) shcmd = "source $1."
 shift
endif
set a = /b/c.d.e retval = 0
switch ($a:t:r:e)
case c.d.e:r:e:    # csh (SunOS 4.x)
case c:d:e:r:e:    # csh (IRIX 5.x)
 set SHTYPE = CSH
 breaksw
case d:     # tcsh 1.2 1993/07/15 (IRIX 5.x)
 set SHTYPE = TCSH
 breaksw
default:
 if ! ($?shell) set shell = UNKNOWN retval = 1
 if ("X$shell" == X) set shell = UNKNOWN retval = 1
 set SHTYPE = $shell:t
 breaksw
endsw
eval $shcmd$SHTYPE
exit $retval
--

#04 EMBEDDED MANPAGE FOR "src2man"
#++
NAME
 whichshell - determine which shell this script runs under

SYNOPSIS
 whichshell [script [script-parameter(s)]]

DESCRIPTION
 With no arguments, the determined value of <shell> is printed
 to stdout. If this cannot be determined, $SHELL is assumed if
 set and non-null, otherwise string "UNKNOWN".

 With <script> argument and optional <parameter(s)>, the script
 <script>.<shell> is sourced with its positional parameters set
 to <parameter(s)>.

 Whichshell knows about bash 1.x/2.x, csh, ksh86/88/93, V7/SVR2 sh,
 SVR3 sh, POSIX sh, tcsh, #XXXand zsh.

EXAMPLE
 csh -f whichshell init p1 p2 p3
 sh whichshell init p1 p2 p3
 ksh whichshell init p1 p2 p3

 It is assumed that files "init.{CSH,KSH_1988,SH}" exist having
 valid csh, ksh[88], and sh code, respectively. Or another
 technique may be to create links "init.KSH_1988" and "init.KSH_1993"
 that point to "init.SH", and a link "init.TCSH" to "init.CSH".

RETURN VALUE
 For the case of no arguments:
  0 if the shell is able to be determined, else 1.
 else,
  if the sourced file does not exist: 1, else the same
  as above (barring an explicit "exit" command therein.)

BUGS
 This script cannot be sourced; it must be executed within a
 subshell.

 Positional parameter(s) cannot have embedded whitespace or
 special characters.

 Bash 1.x will attempt to source an $ENV script meant for ksh or
 other shells.

 To be truly robust for very ancient sh's: eliminate all comments
 but the first.

 Until weirdnik zsh can decide on how to act whether interactive
 or not, whichshell cannot be expected to either.

#--

-Brian

http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&safe=off&selm=7c1smk%246qg%242%40remarQ.com&rnum=5

 brian hiles (bsh@rainey.blueneptune.com)
Date: 1999/03/09 
