#!/usr/bin/env bash
# Pick an xterm-256 colour (or #rrggbb) interactively and apply it to a
# tmux option, with live preview. Cancelling restores the original value.
#
# Usage:
#   tmux-select-color [-g|-s|-w] OPTION
#
# Scope flags (mutually exclusive; default -w):
#   -w    current window via 'set-window-option'   (default)
#   -g    global session via 'set-option -g'
#   -s    server option   via 'set-option -s'
#
# Examples:
#   tmux-select-color status-bg
#   tmux-select-color -g status-fg
#   tmux-select-color window-active-style   # (style strings work too, but
#                                           # tmux will replace the whole
#                                           # value with just the colour)

set -e

die() { echo "tmux-select-color: $*" >&2; exit 1; }

# --help is forwarded straight to the picker so users can discover all
# picker options. Our own -h still shows the wrapper's help.
case "${1:-}" in
	--help) exec select-term256-color --help ;;
esac

scope=window
while getopts "gswh" opt
do
	case $opt in
		w) scope=window;;
		g) scope=global;;
		s) scope=server;;
		h) sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
		*) die "unknown option";;
	esac
done
shift $((OPTIND - 1))

[ $# -ge 1 ] || die "missing OPTION (try -h)"
option=$1
shift  # remaining positionals are forwarded to select-term256-color

command -v tmux >/dev/null 2>&1 || die "tmux not found in PATH"
tmux info >/dev/null 2>&1 || die "no running tmux server"

# When running outside tmux, $TMUX_PANE is empty so we drop the -t flag and
# let tmux target the active pane on whichever client is attached.
if [ -n "$TMUX_PANE" ]
then target_flag="-t $TMUX_PANE"
else target_flag=""
fi

case $scope in
	window) set_cmd="tmux set-window-option $target_flag -- $option"
	        initial=$(tmux show-window-options $target_flag -v -- "$option" 2>/dev/null || true)
	        if [ -z "$initial" ]
	        then initial=$(tmux show-options -gv -- "$option" 2>/dev/null || true)
	        fi
	        ;;
	global) set_cmd="tmux set-option -g -- $option"
	        initial=$(tmux show-options -gv -- "$option" 2>/dev/null || true)
	        ;;
	server) set_cmd="tmux set-option -s -- $option"
	        initial=$(tmux show-options -sv -- "$option" 2>/dev/null || true)
	        ;;
esac

exec select-term256-color --initial "$initial" --preview-cmd "$set_cmd" "$@"
