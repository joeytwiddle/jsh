## Makes a copy of jsh which is optimised for performance (as opposed to development):

NEWJPATH=/tmp/speedy-jsh-$$

mkdir $NEWJPATH/tools

'ls' $JPATH/tools |
while read SCRIPT
do
	(
		## TODO:
		# maybe make symlinks to one script which does this:

		find the name of the script we are just starting to run
		is it a function?
			if so why is it running?!
		ok, load it as a function please
		thanks, now run it

		oh, problem: how can a script load a function into the parent shell?!

		ok what about: each script, before it loads, loads all it's dependent functions
		see how that does!
		
		cat "$JPATH"/tools/"$SCRIPT"

## TODO: if speedyjsh ever actually works, we should next create auto-speedy-jsh, which can run of the dev version of jsh, auto-updating the speedy versions when neccessary.
