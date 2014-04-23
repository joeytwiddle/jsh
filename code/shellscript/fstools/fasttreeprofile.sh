# jsh-ext-depends: find
# For each file under given path, shows last-modified, last-accessed,
# last-status-change, ownership, permission, size, path, and link target.
if [ "$1" = -old ]
then
	shift
	# find "$@" -printf "a=%A@ s=%C@ m=%T@ %u:%g %M %s \"%p\" [%l]\n"
	find "$@" -xdev -printf "a=%A@ s=%C@ m=%T@ %u:%g %M %s \"%p\" [%l]\n"
else
	find "$@" -printf "m=%TY%Tm%Td-%TH%TM%TS a=%AY%Am%Ad-%AH%AM%AS s=%CY%Cm%Cd-%CH%CM%CS %u:%g %M %s \"%p\" [%l]\n"
fi
