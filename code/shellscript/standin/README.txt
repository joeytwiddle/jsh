TODO: What is the standardised way to write a standin wrapper?  (a sort jwhich test then jwhich for real if there?  something better...?)

Holds all scripts which will stand in for another program in its absence.

A lot of scripts from wrap, unixwrap and elsewhere belong here.

In theory each one of these scripts need only be in the PATH if there is no other program with that name in the PATH.

To say that better: each script needn't be in the PATH if there is already a program with that name in the PATH.

This also means that: standin scripts do not modify the behaviour of the program the override; they just do what the program would do (although maybe as a stub/prototype/slowly cos in sh).
