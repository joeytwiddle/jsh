## TODO: Introduce cursewarn etc. meta-colours
##       Could be useful eg. to support highlight reversing if no colours available, or even some text (since curses are always user output anyway)

## Should really be a call to cursecol 1
## where cursecol checks JM_DOES_COLOUR and checks whether IO is a terminal or not (pipes drop colour)
# echo -e "\033[00;31m"
printf "\033[00;31m"
