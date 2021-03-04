# @sourceme

# Hmmm.  At very least this should call startj -simple, or startj should call this.

# Try to guess the top directory of j install
# If all below fails, then you should set it youself with export JPATH=...; source $JPATH/startj
if [ -z "$JPATH" ]
then
	if [ -d "$HOME/j" ]
	then export JPATH="$HOME/j"
	# This doesn't work: bash cannot see it unless we call startj direct (no source)
	elif [ -d "$(dirname "$0")" ]
	then
		export JPATH="$(dirname "$0")"
		echo "startj: guessed JPATH=$JPATH"
	else
		echo "startj: Could not find JPATH. Not starting."
		#env > /tmp/env.out
		exit 0
	fi
fi
#export PATH="$JPATH/tools:$PATH"
export PATH="$PATH:$JPATH/tools"

# Although we don't need things like aliases, we do need things like nvm setup.
[ -f "$JPATH/global.conf" ] && . "$JPATH/global.conf"
[ -f "$JPATH/local.conf" ] && . "$JPATH/local.conf"

#. javainit
#. hugsinit
