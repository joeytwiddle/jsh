ps a -U `whoami` | awk '$5 ~ /Xrealvnc/ {print $6}'
