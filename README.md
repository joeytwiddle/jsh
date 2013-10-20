# jsh - Joey's Shellscript Library

A diverse library of shellscripts.  Run at your own risk.

## JSH-specific

    jdoc <jsh_command>            - Show / search documentation
    et <jsh_command>              - "Edit tool" (so old it used to be a .BAT!)

## Scripts to make my interactive shell look pretty (colourful and informative)

    . autocomplete_from_man
    . xttitleprompt
    . hwipromptforbash / forzsh
    . lscolsinit

Please note that all my rc files now live separately [https://github.com/joeytwiddle/rc_files](here).  For example you may obtain a nice set of `.dircolors` for `lscolsinit` from there.

## Scripts to make my interactive shell easier to use

    . dirhistorysetup.bash / .zsh       Provide `b` and `f` and `dirhistory`
    . bashkeys / zshkeys                Ctrl-D/F/R/T/X/V/Z/B/O to jump and delete small/large words

    cd <partial_path>   autocompletes partial matches (or displays when multiple matches)
    h [<pattern>]       provides fast searching of history
    .. / ... / ....     shortcuts for cd ../../.. etc.

Also handy when working from the cmdline:

    jman             - Popup a man page in a separate terminal window
    japropos         - Search a bunch of things, not just man pages

## Scripts for composing shell commands

For use on the command-line or when writing actual scripts.  Most of the following read from standard in:

    | withalldo <cmd...>
    | foreachdo <cmd...>
    | dog <target_file>       atomic write, does not clobber until the end, safe to use after cat!
    | striptermchars          remove ANSI color codes
    | trimempty
    | removeduplicatelines    and removeduplicatelinespo to preserve order
    | dirsonly                simple filters for lists of paths
    | filesonly
    | prependeachline <txt_to_prepend>
    | takecols <column_numbers...>       Like cut but no params to remember!
    | dropcols <column_numbers...>
    | beforefirst <regexp>
    | afterlast <regexp>
    | dateeachline
    | numbereachline
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

    memo [ -t "N weeks" ] <slow_command...>
    diffdirs <dirA> <dirB>
    diffgraph <related_files...>      shows which files are most closely related
    jwatch <cmd>                      show lines added to or removed from the cmd's output
    jwatchchanges [-fine] <cmd>       show the cmd output, highlighting changes (more like watch(1))

### Monitoring

    monitorps                         report new/closed processes
    listopenports [ <process_name> ]
    listopenfiles [ <process_name> ]
    whatisaccessing <file/folder>
    whatisonport <port>
    whatsblockingaudio
    whatsplaying
    traffic_shaping_monitor
    findjob <process_name>

### Filesystem

    findbrokenlinks
    dusk                              show disk usage by folder (du -sk | sort)
    duskdiff
    del <file/folder>                 sucks but not as much as `rm` does
    rmlink <symlink>
    lazymount <file_to_mount>

    | diffhighlight                   add colours to diffs/patches
    sedreplace <search> <replace> <files...>

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

- 1000 more scripts that shouldn't be here

## Install and setup

**jsh is not very Mac compatible at this moment.**  The main problem is that jsh uses `sed s` a lot, but BSD sed has significant differences from GNU sed.  There are other problems too (`grep --line-buffered`, ...)

First clone the repository:

    git clone https://github.com/joeytwiddle/jsh

Now create all the symlinks:

    jsh/jsh jsh/code/shellscript/init/refreshtoollinks

OK now you are done.

If you want jsh to always load when you start a shell, you can add the following to your `.bash_rc` or `.zshrc`:

    export JPATH="$HOME/jsh"
    source "$JPATH/startj"

## Running

Start a fresh jsh shell with:

    jsh/jsh

Use `exit` or `Ctrl-D` to leave it.

Alternatively, you can load jsh directly into your current shell:

    . jsh/startj

If you just want the scripts on your PATH, and crucial initialisation, but none of the visual shell tweaks:

    . jsh/startj-simple

(This actually does not do much more than setting `$JPATH` and adding `$JPATH/tools` to your `$PATH`.)

Run just one jsh command:

    jsh/jsh <jsh_command> <args...>

