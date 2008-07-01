VIDEO=".wmv:.avi:.mpeg:.mp4:.divx:.xvid:.mkv"
MUSIC=".mp3:.ogg" # :wav"
# EXTENSIONS="$VIDEO:$MUSIC"
EXTENSIONS="$MUSIC"

REGEXP="\\(` echo "$EXTENSIONS" | sed 's+\.+\\\\.+g ; s+:+\\\\|+g' `\\)"

# verbosely cat /latitude_files.list.20071110 | verbosely grep "$REGEXP$"

for SRCDATA in /c/fasttreeprofile*
do :
done

# verbosely jzcat "$SRCDATA" | verbosely grep "$REGEXP\" \["
verbosely jzcat "$SRCDATA" |
# verbosely grep "$REGEXP\" \["
afterfirst '"' | beforelast '" \[' |
grep "$REGEXP$"

