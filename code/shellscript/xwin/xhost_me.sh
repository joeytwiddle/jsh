# After doing `sudo su` I sometimes want to open X applications.
# Previously the only way I knew to do this was to get the user to run `xhost +localhost` or even `xhost +` but this is rather insecure on a multi-user or networked machine.

# If you have sux installed, you can use that to enter an X-ready root session.

# However I have discovered that you can use the .Xauthority file to provide root with access to the user's X.
# And you don't have to think ahead.  You can run this retrospectively *as root*.
# Moreover, you only have to do it once per machine!  It remembers on future logins.

userWhoIsRunningX=$SUDO_USER

xauth_file="/home/$userWhoIsRunningX/.Xauthority"

xauth merge "$xauth_file" 2>&1
# On the first run, it might produce an error message:
#grep -v '^xauth:  file /root/.Xauthority does not exist$'

# I doubt this will happen but in the case that root takes ownership of that file, we may want to restore it:
#chown "$userWhoIsRunningX:$userWhoIsRunningX" "$xauth_file"
