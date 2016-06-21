# @sourceme
# ## What shell are we running?
# ## This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_
# ## $0 does OK for bash (at least when in .bash_profile!)
# # changed for cygwin, hope solaris and linux r still happy!
# SHELLPS="$$"
# SHORTSHELL=`
# # findjob "$SHELLPS" | # (not on cygwin!)
# ps | grep "$SHELLPS" |
# grep 'sh$' |
# tail -n 1 |
# sed "s/.* \([^ ]*sh\)$/\1/" |
# sed "s/^-//"
# `
# # echo "shell = $SHORTSHELL"
# ## tcsh makes itself known by ${shell} envvar.
# ## This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_
# # dunno how we got away without this (needed for cygwin anyway):
# SHORTSHELL=`echo "$SHORTSHELL" | afterlast "/"`

## METHOD 2:

## Which flavour shell are we running?
if test $ZSH_NAME; then
	SHORTSHELL="zsh"
elif test "$BASH"; then
	SHORTSHELL="bash"
fi

# On Linux these days, $SHELL=/bin/bash or /bin/zsh.

