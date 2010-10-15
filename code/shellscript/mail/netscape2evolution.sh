#!/bin/sh
makefolder () { # Takes absolute nsmail path to file, name, and path to subdir

	echo "# Doing $1"

	mkdir "$2"

	cd "$2"

	# Oh dear evolution requires hard links
	# ln -s "$1" mbox
	# ln "$1/../$2" mbox
	# touch mbox
	if test ! -f mbox && test -f "$1"; then
		mv "$1" mbox
		ln -s "$PWD/mbox" "$1"
	fi

	cat > folder-metadata.xml << !
<?xml version="1.0"?>
<efolder>
  <type>mail</type>
  <description></description>
</efolder>
!
	cat > local-metadata.xml << !
<?xml version="1.0"?>
<folderinfo>
  <folder type="mbox" name="mbox" index="1"/>
</folderinfo>
!

	mkdir subfolders
	if test -d "$3"; then
		cd subfolders
		find "$3/" -maxdepth 1 -type f |
		sed "s+^$3[/]++" |
		while read X; do
			# echo "Descending $X"
			makefolder "$3/$X" "$X" "$3/$X.sbd"
		done
		cd ..
	else
		echo "# $2 is a leaf."
	fi

	cd ..

}

cd $HOME/evolution/local/

makefolder $HOME/nsmail "Joey's Mail" $HOME/nsmail
