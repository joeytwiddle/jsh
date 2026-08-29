#!/usr/bin/env sh
# Pick a random dark colour and set it as the tmux status-bg.
# The chosen colour always differs from the current one, so pressing the
# bound key repeatedly keeps cycling through new dark shades.
#
# Usage:
#   tmux-random-status-bg.sh [session-target]
# Without a target: applies to the current session.
# With a target (e.g. "#{session_name}" from a hook or key binding): applies to
# that session.

TARGET="${1:-}"

# Dark colours from the xterm-256 palette (greys + dark shades of each hue).
# colour233 colour234 colour235 colour236 colour237 colour238 colour239 \
COLORS="colour17 colour18 colour19 \
colour22 colour23 colour24 \
colour30 colour31 \
colour52 colour53 \
colour54 colour89 colour90 \
colour58 colour94 colour100 colour136 \
colour88 colour124 colour160 colour166 \
colour59 colour60 colour95 colour96 colour101 colour102 colour137"

if [ -n "$TARGET" ]
then current=$(tmux show-options -qv -t "$TARGET" status-bg)
else current=$(tmux show-options -qv status-bg)
fi

pick_color() {
	n=0
	for c in $COLORS
	do n=$((n + 1))
	done
	r=$(od -An -N1 -tu1 /dev/urandom)
	idx=$((r % n + 1))
	i=0
	for c in $COLORS
	do
		i=$((i + 1))
		if [ "$i" -eq "$idx" ]
		then printf '%s' "$c"; return 0
		fi
	done
}

# Bounded retries to avoid landing on the same colour we already have.
color=""
attempt=0
while [ "$attempt" -lt 20 ]
do
	color=$(pick_color)
	[ "$color" != "$current" ] && break
	attempt=$((attempt + 1))
done

if [ -n "$TARGET" ]
then verbosely tmux set-option -t "$TARGET" status-bg "$color"
else verbosely tmux set-option status-bg "$color"
fi
