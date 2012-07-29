APPS_TO_KILL="konqueror kdeinit dcopserver kicker gam_server kio_file kio_http"
APPS_TO_KILL="$APPS_TO_KILL amarokapp yauap"
APPS_TO_KILL="$APPS_TO_KILL dbus-daemon dbus-launch"
APPS_TO_KILL="$APPS_TO_KILL kdeinit4 kded klauncher"

# pgrep kicker >/dev/null && kickerWasRunning=true

echo
echo "Processes which will probably be killed:"
for PROCNAME in $APPS_TO_KILL
do ps -A | grep "\<$PROCNAME\>"
done
echo

echo "WARNING!  I will kill these KDE processes in 3 seconds!"
echo "Press Ctrl+C now to abort!"
echo

sleep 3

# Slay KDE!
killall $APPS_TO_KILL 2>&1 | grep -v "no process killed"
sleep 3
killall -KILL $APPS_TO_KILL 2>&1 | grep -v "no process killed"
echo "Killed all I could"

if [ "$kickerWasRunning" ]
then
	## Restart kicker automatically.
	echo "Starting up kicker"
	kicker&
fi

