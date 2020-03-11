# Efficient version, using inotify.
# Could also be called monitorfiles

# @requires-package inotify-tools

# For more cross-platform technologies: https://stackoverflow.com/questions/1515730/is-there-a-command-like-watch-or-inotifywait-on-the-mac
#
# watchdog might be worth a look.  Written in Python, cross-platform, appears to use inotify if it can.

# On macOS use fswatch
if which fswatch >/dev/null 2>&1
then
    fswatch "$1"
    exit
fi

# or watchman
if which watchman >/dev/null 2>&1
then
    watchman watch "$1"
    watchman -- trigger "$1" "watch-$$" '*' -- echo
    exit
fi

# --exclude <pattern_for_filename>
# Print just the watched file (usually shows the name of the folder where the change occurred): --format "%w"
# Print just the filename: --format "%f"
# Print the time, colon-separated list of events, and the filename: --format "%T %:e %f" --timefmt "%Y/%m/%d %H:%M:%S"
inotifywait -m -e modify -e move -e moved_to -e moved_from -e create -e delete -r "$@"

# | removeduplicatelines -adj

# All the events:
# - access
# - modify
# - attrib
# - close_write
# - close_nowrite
# - close
# - open
# - moved_to
# - moved_from
# - move
# - move_self
# - create
# - delete
# - delete_self
# - unmount

# Example output:
#
# When I saved a file in vim, I saw this:
#
#   ./src/app/ CREATE 4913
#   ./src/app/ DELETE 4913
#   ./src/app/ MOVED_FROM main.js
#   ./src/app/ MOVED_TO main.js~
#   ./src/app/ CREATE main.js
#   ./src/app/ MODIFY main.js
#   ./src/app/ DELETE main.js~
#   ./src/app/ MODIFY .main.js.swp

