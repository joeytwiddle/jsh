# jsh - Joey's Shellscript Library

A diverse library of shellscripts.  This is my preferred working environment when using a Unix shell.  But I also use this project to collect useful bits and bobs as I discover them.  (For example, I recently added a script to boost volume above 100 when using pulseaudio.)

Many of these scripts will run standalone, but some of them depend on other jsh scripts, so they must be on the PATH.

Run `jsh/jsh` or `source jsh/startj` or `source jsh/startj-simple` to setup your PATH so they will all run fine.

There are more detailed installation instructions below.  But first, here are some examples of the available scripts:

### JSH-specific

    jdoc <jsh_command> | <text>   Show or search script documentation (like man+apropos for jsh scripts)

    et <jsh_command> | <new_com>  Edit a script ("Edit tool" - so old it used to be a .BAT!)
                                  This will open the given script in your favourite editor (see 'edit')
                                  It can also be used to create a new script
                                  So it is a very quick way to create new commands / scripts for future use

### Scripts to make my interactive shell look pretty (colourful and informative)

    . lscolsinit                  Loads a comprehensive color scheme for `ls`
    . hwipromptforbash / forzsh   A pretty and informative prompt
    . xttitleprompt               Show detailed information about your shell in the title of your terminal window

These are sourced automatically if you run `jsh/jsh` or source `startj`

Please note that all my rc files now live separately [here](https://github.com/joeytwiddle/rc_files).  For example you may obtain a nice set of `.dircolors` for `lscolsinit` from there.

### Scripts to make my interactive shell easier to use

    . dirhistorysetup.bash / .zsh       Provide `b` and `f` and `dirhistory` to go back/forward
    . bashkeys / zshkeys                Ctrl-D/F/R/T/X/V/Z/B/O to jump and delete small/large words

    cd <partial_path>   typo helper: autocompletes partial matches, or shows alternatives when multiple matches
    h [<pattern>]       provides fast searching of history
    .. / ... / ....     shortcuts for cd ../../.. etc.

    . autocomplete_from_man     Tries to provide tab-completion for any command, by peeking at the command's man page

Also handy when working from the cmdline:

    jman             Popup a man page in a separate terminal window
    japropos         Search a bunch of things, not just man pages
    gitls            Like `ls -lartFh --color` but with git status for each file
    git*             A bunch of git scripts which are often/occasionally handy.
                     But my most useful scripts (e.g. gcf) are in my rc_files repo under git_aliases.

### Scripts for composing shell commands

For use on the command-line or when writing actual scripts.  Most of the following read a list from standard in (assumes inputs are separated by newlines):

    | withalldo <cmd...>      A shortcut for xargs
    | foreachdo <cmd...>      A shortcut for | while read FILE; do ...; done
    | dog <target_file>       Atomic write, does not clobber until the end, safe to use after cat!
    | striptermchars          Remove ANSI color codes
    | trimempty               Remove empty/blank lines
    | removeduplicatelines    Use removeduplicatelinespo to preserve order
    | takecols <column_numbers...>       Like cut but no params to remember!  Assumes fields are separated by whitespace.
    | dropcols <column_numbers...>       Removes the specified columns, keeps the rest
    | beforefirst <regexp>    Take portion of each line before pattern
    | afterlast <regexp>      or after pattern
    | fromline [-x] <regexp>  Take all lines after or before given pattern
    | toline [-x] <regexp>    [-x] means exclude the matching line
    | prependeachline <txt_to_prepend>   Puts the given text before each line of input
    | numbereachline                     Puts a number before each line of input
    | dateeachline [-fine]               Puts the date and time before each line of input (useful after tail, or for logging)
    | dirsonly                Retains only those lines of input which are directories
    | filesonly               Retains only those lines of input which are files
    | sortfilesbydate
    | sortfilesbysize

    | list2regexp
    | chooserandomline
    chooserandom <args...>
    | countlines

    echolines <glob>          Print each of the arguments you provided on a separate line.  (Turns words into lines)
    waitforkeypress

    filesize <file>
    mp3duration <file>
    imagesize <file>

### Scripts for shellscripting

Rarely used on the commandline.

    . importshfn <shellscript>       Creates a function from the shellscript, so it will run quicker if you call it many times.  YMMV
    . require_exes <exe_names...>    exits if the gives exes are not on your PATH

### Utilities

    memo [ -t "N weeks" ] <slow_command...>   Remembers the first output and gives it back on subsequent calls
    jwatch <cmd>                      Show lines added to or removed from the cmd's output
    jwatchchanges [-fine] <cmd>       Show the cmd output, highlighting changes (more like watch(1))

### Forensics

Can be useful when cleaning up old duplicate folders/files

    diffdirs <dirA> <dirB>            Or for more details, use diff -r
    diffgraph <related_files...>      Shows which files are most closely related, by numerical distance (does not actually draw a graph yet!)
    git-which-commit-has-this-blob    Search this repo's history for a file matching the given file/hash

### Monitoring

    findjob <process_name>            An alternative to `ps aux | grep <...>`
    monitorps                         Report new/closed processes (useful if you notice a lot of forks but don't know why)
    listopenports [ <process_name> ]
    listopenfiles [ <process_name> ]
    whatisaccessing <file/folder>
    whatisonport <port>
    whatsblockingaudio
    whatsplaying
    traffic_shaping_monitor           Monitor how much is flowing through /sbin/tc classes

### Filesystem

    findbrokenlinks
    dusk                              show disk usage by folder (du -sk | sort)
    duskdiff
    del <files/folders...>            moves files to trash, reclaimable in case of accident
    rmlink <symlinks...>              safer than rm: only removes files which are symlinks
    lazymount <file_to_mount>

    | diffhighlight                   add colours to diffs/patches
    sedreplace <search> <replace> <files...>

    renamefiles <search_pattern> <replace_pattern> [<files...>] |sh
    editfilenames                     opens Vim to let you edit filenames

    worddiff / wordpatch              don't patch whole lines; be more fine grained!

### X-Windows

    xsnapshot
    getxwindimensions
    put_current_xwindow

### Wrappers

    convert_to_mp3 <any_audio_or_video_file>
    convert_to_ogg <any_audio_or_video_file>
    reencode_video_to_x264 <video_file>
    | txt2speech                      makes festival sound slightly less stupid
    wp <term>                         fast Wikipedia search (short summary) [CURRENTLY BROKEN]

### Utter madness

    fifovo        Watch a live video stream, storing the stream in a ringbuffer of files.  Listen for instructions to rewind and capture parts of the stream.  (The last time I tried this, it had stopped working.)

    export UNIX_TEXT_ADVENTURE=1
                  Makes you feel like you are playing a classic adventure game as you cd around your filesystem

- ... and 1000 more scripts that shouldn't be here

## Install and setup

First clone the repository:

    $ git clone https://github.com/joeytwiddle/jsh

Now create all the symlinks in `$HOME/tools`:

    $ jsh/jsh jsh/code/shellscript/init/refreshtoollinks

OK setup is now complete.

If you want jsh to always load when you start a shell, add the following lines to your `.bashrc` or `.zshrc`:

    export JPATH="$HOME/jsh"
    source "$JPATH/startj"

## Additional step for Mac OS X users

If you want to run jsh on Mac OS X then you probably want to:

    $ brew install coreutils gnu-sed findutils

Then add the following lines to your `.bashrc` or `.zshrc`, *before* the `JPATH` lines we inserted earlier:

    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"

This is because Jsh makes heavy use of GNU utils such as `grep` and `sed`.  Although many of these programs are distributed with Mac OS X, they are BSD versions and do not accept exactly the same arguments.

(This `PATH` will be provided to any non-Jsh commands you call from within a Jsh shell.  So far this has caused me no problems.  I have been able to run `brew`, `rvm` and `rails` from inside or outside Jsh.)

_Update: Actually I have started to support BSD sed and grep when I discover bugs, so many of the core scripts will work.  But more scripts will work correctly if you follow the steps above._

## Running

Start a fresh jsh shell with all the bells and whistles:

    jsh/jsh

Use `exit` or `Ctrl-D` to leave it.

Alternatively, you can load jsh directly into your current shell:

    . jsh/startj

But if you only want the scripts on your PATH, and crucial initialisation, but none of the visual shell tweaks:

    . jsh/startj-simple

All that script really does is this (so you could do it manually if you wanted):

    export JPATH="$HOME/jsh'
    export PATH="$PATH:$JPATH/tools"

Or if you only want to run one jsh script and then return to your current shell:

    jsh/jsh <jsh_command> [ <args...> ]

