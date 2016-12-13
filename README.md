# jsh - Joey's Shellscript Library

A diverse library of shellscripts.  Run at your own risk.

## JSH-specific

    jdoc <jsh_command> | <text>   Show or search documentation
    et <jsh_command>              Edit a script ("Edit tool" - so old it used to be a .BAT!)

## Scripts to make my interactive shell look pretty (colourful and informative)

    . xttitleprompt
    . hwipromptforbash / forzsh
    . lscolsinit

These are sourced automatically if you run `jsh/jsh` or source `startj`

Please note that all my rc files now live separately [https://github.com/joeytwiddle/rc_files](here).  For example you may obtain a nice set of `.dircolors` for `lscolsinit` from there.

## Scripts to make my interactive shell easier to use

    . dirhistorysetup.bash / .zsh       Provide `b` and `f` and `dirhistory`
    . bashkeys / zshkeys                Ctrl-D/F/R/T/X/V/Z/B/O to jump and delete small/large words

    cd <partial_path>   typo helper: autocompletes partial matches, or shows alternatives when multiple matches
    h [<pattern>]       provides fast searching of history
    .. / ... / ....     shortcuts for cd ../../.. etc.

    . autocomplete_from_man     Tries to provide tab-completion for any command, by peeking at the command's man page

Also handy when working from the cmdline:

    jman             - Popup a man page in a separate terminal window
    japropos         - Search a bunch of things, not just man pages

## Scripts for composing shell commands

For use on the command-line or when writing actual scripts.  Most of the following read a list from standard in (assumes inputs are separated by newlines):

    | withalldo <cmd...>
    | foreachdo <cmd...>
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

    echolines <glob>
    waitforkeypress

    filesize <file>
    mp3duration <file>
    imagesize <file>

## Scripts for shellscripting

Rarely used on the commandline.

    . importshfn <shellscript>       Load a shellscript as a function, so it runs faster when you call it many times
    . require_exes <exe_names...>    exits if the gives exes are not on your PATH

## Utilities

    memo [ -t "N weeks" ] <slow_command...>   Remembers the first output and gives it back on subsequent calls
    diffdirs <dirA> <dirB>
    diffgraph <related_files...>      Shows which files are most closely related, by numerical distance (does not actually draw a graph yet!)
    jwatch <cmd>                      Show lines added to or removed from the cmd's output
    jwatchchanges [-fine] <cmd>       Show the cmd output, highlighting changes (more like watch(1))

### Monitoring

    monitorps                         Report new/closed processes (useful if you notice a lot of forks but don't know why)
    listopenports [ <process_name> ]
    listopenfiles [ <process_name> ]
    whatisaccessing <file/folder>
    whatisonport <port>
    whatsblockingaudio
    whatsplaying
    traffic_shaping_monitor           Monitor what /sbin/tc classes are doing
    findjob <process_name>

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

    worddiff / wordpatch

    xsnapshot
    getxwindimensions
    put_current_xwindow

## Wrappers

    convert_to_mp3 <any_audio_or_video_file>
    convert_to_ogg <any_audio_or_video_file>
    reencode_video_to_x264 <video_file>
    | txt2speech                      makes festival sound slightly less stupid
    wp <term>                         fast Wikipedia search (short summary)

- ... and 1000 more scripts that shouldn't be here

## Install and setup

First clone the repository:

    $ git clone https://github.com/joeytwiddle/jsh

Now create all the symlinks:

    $ jsh/jsh jsh/code/shellscript/init/refreshtoollinks

OK setup is now complete.

If you want jsh to always load when you start a shell, add the following lines to your `.bashrc` or `.zshrc`:

    export JPATH="$HOME/jsh"
    source "$JPATH/startj"

## Additional step for Mac OS X users

If you want to run jsh on Mac OS X then you should:

    $ brew install coreutils gnu-sed findutils

Then add the following lines to your `.bashrc` or `.zshrc`, *before* the `JPATH` lines we inserted earlier:

    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"

This is because Jsh makes heavy use of GNU utils such as `grep` and `sed`.  Although many of these programs are distributed with Mac OS X, they are BSD versions and do not accept exactly the same arguments.

(This `PATH` will be provided to any non-Jsh commands you call from within a Jsh shell.  So far this has caused me no problems.  I have been able to run `brew`, `rvm` and `rails` from inside or outside Jsh.)

## Running

Start a fresh jsh shell with:

    jsh/jsh

Use `exit` or `Ctrl-D` to leave it.

Alternatively, you can load jsh directly into your current shell:

    . jsh/startj

If you just want the scripts on your PATH, and crucial initialisation, but none of the visual shell tweaks:

    . jsh/startj-simple

(This actually does not do much more than setting `$JPATH` and adding `$JPATH/tools` to your `$PATH`.)

If you want to run just one jsh command and then return to your current shell:

    jsh/jsh <jsh_command> [ <args...> ]

