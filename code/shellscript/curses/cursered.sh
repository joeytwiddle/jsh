#!/bin/sh
## TODO: Introduce cursewarn etc. meta-colours
##       Could be useful eg. to support highlight reversing if no colours available, or even some text (since curses are always user output anyway)

## TODO: I very often combine cursered with cursebold, because it is so dark in my lucida xterms.
##       But this may not be the case for everyone else's terminals.
##       So I should remove all uses of cursebold for this reason, and instead introduce:
##       STRENGTHEN_DARK_COLOURS which if set will perform the boldening I require during cursered.
##       This will break the case if I ever want to print a dark colour.  But does that case really exist, given that dark colours are not really dark for other people.  Maybe it does, because they can at least see the difference.
##       Basically, in diffhighlight, I don't think removed stuff should be bold, unless I need it to be in order to read it!

## Should really be a call to cursecol 1
## where cursecol checks JM_DOES_COLOUR and checks whether IO is a terminal or not (pipes drop colour)
# echo -e "\033[00;31m"
printf "\033[00;31m"
