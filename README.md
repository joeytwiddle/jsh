# jsh - Joey's Shellscript Library

A diverse library of shellscripts.  Run at your own risk.

## JSH-specific

    jdoc <jsh_command>            - Show / search documentation
    et <jsh_command>              - "Edit tool" (so old it used to be a .BAT!)

## Scripts to make my interactive shell look pretty (colourful and informative)

    . autocomplete_from_man
    . xtitleprompt
    . hwipromptforbash / forzsh
    . lscolsinit

## Scripts to make my interactive shell easier to use

    . dirhistorysetup.bash / .zsh       Provide `b` and `f` and `dirhistory`
    . bashkeys / zshkeys                Ctrl-D/F/R/T/X/V/Z/B to jump and delete small/large words

    cd <partial_path>   autocompletes partial matches (or displays when multiple matches)
    h [<pattern>]       provides fast searching of history

## Scripts for composing shell commands, on the command-line or when writing other scripts.  Most of the following read from standard in:

    | withalldo <cmd...>
    | foreachdo <cmd...>
    | dog <target_file>       atomic write, does not clobber until the end, safe to use after cat!
    | striptermchars          get rid of ANSI color codes
    | trimempty
    | removeduplicatelines
    | dirsonly                simple list filters
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

## Utilities

    memo [ -t "N weeks" ] <slow_command...>
    diffdirs <dirA> <dirB>
    diffgraph <related_files...>      shows which files are most closely related
    jwatch <cmd>                      show lines added to or removed from the cmd's output
    jwatchchanges [-fine] <cmd>       show the cmd output, highlighting changes

### Monitoring

    monitorps                         report new/closed processes
    listopenports [ <process_name> ]
    listopenfiles [ <process_name> ]
    whatisaccessing <file/folder>
    whatisonport <port>
    whatsblockingaudio
    whatsplaying
    traffic_shaping_monitor

### More

    findbrokenlinks
    dusk                              show disk usage by folder (like du -sk)
    duskdiff
    del <file/folder>                 sucks but not as much as `rm` does
    rmlink <symlink>
    | diffhighlight                   add colours to diffs/patches
    sedreplace <search> <replace> <files...>
    lazymount <file_to_mount>

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

## Setup

First clone the repository:

    git clone https://github.com/joeytwiddle/jsh

Now create all the symlinks:

    jsh/jsh jsh/code/shellscript/init/refreshtoollinks.sh

OK now you are done.

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

