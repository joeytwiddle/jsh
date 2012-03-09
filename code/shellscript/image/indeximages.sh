#!/bin/sh
stripleading () {
	sed "s+^$1++"
}

sortCommand=sort
if [ "$1" = -bydate ]
then sortCommand=sortfilesbydate ; shift
fi

indeximagesindir () {

	echo "<HTML><HEAD><TITLE>Images in $1</TITLE></HEAD><BODY>"

	find . -type d -maxdepth 1 |
	sed 's+^.$+..+g' |
	stripleading "\./" |
	sort |
	while read DIR
	do echo "<A href="$DIR">$DIR/</A><BR>"
	done

	echo "<BR>"

	# for IMAGE in *.png *.jpg *.jpeg *.gif *.bmp *.xpm *.pgm *.ppm *.pcx
	find . -maxdepth 1 -name "*.png" -or -name "*.jpg" -or -name "*.jpeg" -or -name "*.gif" -or -name "*.bmp" -or -name "*.xpm" -or -name "*.pgm" -or -name "*.ppm" -or -name "*.pcx" |
	stripleading "\./" |
	$sortCommand |
	while read IMAGE
	do
		echo "<A HREF=\"$IMAGE\">"
		echo "$IMAGE<BR>"
		echo "<IMG src=\"$IMAGE\"><BR>"
		echo "</A>"
		echo "<BR>"
	done

}

find . -type d |
stripleading "\./" |
while read DIR
do

	( cd "$DIR" && indeximagesindir "$DIR" > index.html )

done
