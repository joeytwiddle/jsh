cvsdiff -all . | grep " add " | takecols 3 | grep -v "\.sw.$" | filesonly | sortfilesbydate |
sed 's+^+cvs add +'
