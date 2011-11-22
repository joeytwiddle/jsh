#!/bin/dash

if [ -z "$1" ]
then exit 1
fi

## Multiple switch requests have a tendency to undo each other if performed too
## rapidly.  We use a lockfile to slow down the processing of requests.
## BUG: the process order is likely to be non-deterministic for 3 or more requests.
lockfile=/tmp/wmctrl_emulate_fluxbox_command.$USER.lock

# lockfile -1 -r 99 -l 15 "$lockfile"

## Might respond slightly faster.  Might also be buggy.
touch "$lockfile.$$"
n=0
while true
do
	if [ ! -f "$lockfile" ] && ln -s "$lockfile.$$" "$lockfile"
	then break
	fi
	sleep 0.1 ; n=$((n+1))   ## TODO: works in dash but NOT POSIX!  Likewise for all the other $(...) evals!
	if [ "$n" -eq 100 ]
	then
		echo "[WARNING] Timed out trying to lock $lockfile so forcing (process $$ with args \"$*\")" >&2
		touch "$lockfile"
		break
	fi
done

case "$1" in
	":Workspace")
		target_workspace=$(($2-1))
		;;
	":RightWorkspace")
		target_workspace=$(wmctrl -d | grep -A1 '[[:digit:]]\+ \+\*' | tail -n 1 | cut -f1 -d ' ')
		;;
	":LeftWorkspace")
		target_workspace=$(wmctrl -d | grep -B1 '[[:digit:]]\+ \+\*' | head -n 1 | cut -f1 -d ' ')
		;;
	":NextWorkspace")
		howFar="$2"
		[ -z $howFar ] && howFar=1
		wsps=$(wmctrl -d | grep -A"$howFar" '[[:digit:]]\+ \+\*')
		count=$(echo "$wsps" | wc -l)
		expected=$((howFar+1))
		if [ "$count" -lt "$expected" ]
		then
			## We are probably near the end of the list, so we need to look from the top
			missing=$((expected-count))
			target_workspace=$(wmctrl -d | head -n $missing | tail -n 1 | cut -f1 -d ' ')
		elif [ "$count" = "$expected" ]
		then
			target_workspace=$(echo "$wsps" | tail -n 1 | cut -f1 -d ' ')
		else
			echo "Weird wc output" > /dev/stderr
			exit 1
		fi
		;;
	":PrevWorkspace")
		howFar="$2"
		[ -z $howFar ] && howFar=1
		wsps=$(wmctrl -d | grep -B"$howFar" '[[:digit:]]\+ \+\*')
		count=$(echo "$wsps" | wc -l)
		expected=$((howFar+1))
		if [ "$count" -lt "$expected" ]
		then
			## We are probably near the beginning of the list, so we need to look from the bottom
			missing=$((expected-count))
			target_workspace=$(wmctrl -d | tail -n $missing | head -n 1 | cut -f1 -d ' ')
		elif [ "$count" = "$expected" ]
		then
			target_workspace=$(echo "$wsps" | head -n 1 | cut -f1 -d ' ')
		else
			echo "Weird wc output" > /dev/stderr
			exit 1
		fi
		;;
	*)
		echo "Command $1 not yet implemented" > /dev/stderr
		exit 1
		;;
esac

[ ! -z "$target_workspace" ] && wmctrl -s "$target_workspace"

## Pause a bit before unlocking, to allow fluxbox to update.
## If the next switch runs too soon, it still sees the previous desktop as the origin, not the new one.
# sleep 0.1   ## fine for light load, but not always long enough!
# sleep 0.3   ## occasionally fails under heavy load
sleep 0.5   ## yet to fail

rm -f "$lockfile" "$lockfile".$$

