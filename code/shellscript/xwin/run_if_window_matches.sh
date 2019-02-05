#!/usr/bin/env bash

#winid="$(xdo id)"
winid="$(xdotool getwindowfocus)"

#wininfo="$(xwininfo -id "$winid" | grep "^xwininfo: ")"
#echo "[run_if_window_matches] wininfo: $wininfo"
#wintitle="$(echo "$wininfo" | sed 's+^[^"]*"++ ; s+"$++')"

getprop() {
  xprop -id "$winid" "$1" | cut -d '"' -f 2
}

#winclass="$(getprop WM_CLASS)"

negate_match=''

check_if_prop_matches() {
  if getprop "$1" | egrep "^$2$" >/dev/null
  then [ -n "$negate_match" ] && exit 1   # Matched
  else [ -z "$negate_match" ] && exit 1   # Did not match
  fi
}

while true
do
  case "$1" in
    --not)
      negate_match=1
      shift
      ;;
    --class)
      check_if_prop_matches WM_CLASS "$2"
      shift; shift
      ;;
    --name)
      check_if_prop_matches WM_NAME "$2"
      shift; shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

# Conditions passed; run command!
"$@"
