## TODO: disclaimer
LASTFILE=/tmp/$1.spy
if test ! -f "$LASTFILE"
then
        touch -r /home/$1/.bash_history "$LASTFILE"
else
        if find /home/$1/.bash_history -newer "$LASTFILE" | grep history > /dev/null
        then
                touch -d "1 hour" "$LASTFILE"
                ( date ; echo "$1 has started a shell on $HOSTNAME" ) | mail joey@hwi.ath.cx
        fi
fi
