#!/usr/bin/env sh
# Pick a dark colour and set it as the tmux status-bg.
# Deterministic mode available via --hash <str> or --hash-cwd.
#
# Usage:
#   tmux-random-status-bg.sh [--hash <str>] [--hash-cwd] [session-target]
# Options:
#   --hash <str>     Use hash of <str> for deterministic colour
#   --hash-cwd       Use hash of $PWD (per-directory deterministic colour)
# Without a target: applies to the current session.
# With a target (e.g. "#{session_name}" from a hook): applies to that session.

HASH_INPUT=""
while [ $# -gt 0 ]; do
    case "$1" in
        --help) echo "Usage: tmux-random-status-bg.sh [--hash <str>] [--hash-cwd] [session-target]"; exit 0 ;;
        --hash) HASH_INPUT="$2"; shift 2 ;;
        --hash-cwd) HASH_INPUT="$PWD"; shift ;;
        --) shift; break ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) break ;;
    esac
done
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

hash_str() {
    printf '%s' "$1" | cksum | awk '{print $1}'
}

if [ -n "$TARGET" ]
then current=$(tmux show-options -qv -t "$TARGET" status-bg)
else current=$(tmux show-options -qv status-bg)
fi

pick_color() {
    n=0
    for c in $COLORS; do n=$((n + 1)); done

    if [ -n "$HASH_INPUT" ]; then
        r=$(hash_str "$HASH_INPUT")
    else
        r=$(od -An -N1 -tu1 /dev/urandom)
    fi
    idx=$((r % n + 1))
    i=0
    for c in $COLORS; do
        i=$((i + 1))
        [ "$i" -eq "$idx" ] && { printf '%s' "$c"; return 0; }
    done
}

color=$(pick_color)
if [ -n "$TARGET" ]
then verbosely tmux set-option -t "$TARGET" status-bg "$color"
else verbosely tmux set-option status-bg "$color"
fi
