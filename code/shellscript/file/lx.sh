file * | while read X; do Y=`echo "$X" | sed "s/:.*//"`; Z=`echo "$X" | afterfirst :`; ls -d "$Y" | tr -d "\n"; echo "$Z"; done
