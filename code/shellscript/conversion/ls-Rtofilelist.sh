#!/bin/sh
if [ "$1" = --help ]
then
	echo "ls-Rtofilelist takes the output of ls -R (also ftp's ls -R) and converts it so that formatting and folders are hidden, and each line now holds a file with its full path."
	echo "The option -l will process ls -lR input."
	echo "I usually do grep "^-" on the output, to select files only and drop symlinks."
	exit 0
fi



[ "$1" = -l ] && INPUT_LONG=true && shift

# if [ "$INPUT_LONG" ]
# then . importshfn tocol fromcol
# fi

cat |

if [ "$INPUT_LONG" ]
then

	## Some lines we just need to ignore:
	grep -v "^total [0-9][0-9]*$" |

	## Unfortunately ls -l does not always give the same output:
	# -rwxr-xr-x 1 joey users 11272 Oct 25  2007 ucc.init
	# -rw-rw-r--   1 744568a  clanbot      8912 Jan 20 23:36 Unreal.ngLog.2009.01.20.23.36.09.7777.log
	# -rw-r--r-- 1 ngs00134 hlplayers  15180 Aug 19 00:03 [ChatLog].2008.08.19.00.01.05.CTF-Vaultcity-LE101.log
	# -rwxr-xr-x   1 k1210    k1210       11781 Jun 13 03:15 ucc.init
	# -rwxr-xr-x    1 utserver www         10687 Jul  7 07:53 ucc.init
	## But this is the only one which actually has a different number of fields
	# -rwxr-xr-x 1 joey joey 12588 2009-01-30 14:45 ucc.init
	sed 's+ \([0-9][0-9]*\)  *\([1-9][0-9][0-9][0-9]-[0-3][0-9]-[0-3][0-9]\)  *\([0-9][0-9]:[0-9][0-9]\) + \1 @ \2 \3 +'

else cat
fi |

while read DIR
do
	DIR=`echo "$DIR" | sed 's+:$++'`
	while true
	do
		read LINE
		if [ ! "$LINE" ]
		then break
		fi
		if [ "$INPUT_LONG" ]
		then
			## BUG: The sed squeezes spaces.  Any filenames with two spaces (and ls -l column formatting) will be broken.
			DATA=`echo "$LINE" | sed 's+  *+ +g' | cut -d ' ' -f -8`
			FILENAME=`echo "$LINE" | sed 's+  *+ +g' | cut -d ' ' -f 9-`
			echo "$DATA $DIR/$FILENAME"
		else
			FILE="$LINE"
			echo "$DIR/$FILE"
		fi
	done
done
