if test ! "$*" = ""
then jdoc "$@"
else

more << !

* About the jsh system *

jsh has two main components:

  1) Shell setup (for bash/zsh)
  2) Shell tools

1) Shell setup
    You have a number of new aliases, a pretty coloured prompt, environment
    variables to enhance common programs (eg. coloured ls listings), and handy
    keybindings for command line editing.  [ Check \$JPATH/startj for details. ]

2) Shell tools
    jsh adds \$JPATH/tools to your \$PATH, which contains symlinks to a number
    of useful shellscripts.
      jdoc <toolname>
    shows documentation for each script, and usage examples / dependent scripts.
    [ The scripts are actually linked from CVS dir \$JPATH/code/shellscript ]

To get started, try some of these scripts:
  updatejsh: update system from cvs | b: go to previous directory | higrep:
  highlighting grep =) | grep*: shortcuts | ilocate: case insensitive locate |
  cvsdiff: informative cvs summaries | tree: fold a structured file |
  extractMandrakeUrpmConfig: copy config from one box to another | monitorps |
  remotediff: interactive rsync | watchforfileaccess | comparedirs(cksum|...) |
  onchange "<files>" do <command> | wotgobble(mem|cpu) | (en|de)cryptdir |
  mykill -x: indescriminate violence | includepath: handy after --prefix |
  (remove|keep)duplicatelines | chooserandomline | fadevolume | irclog2html |
  del <files>: safer than rm

!

fi
