#!/bin/sh
ap=\'
data='echo "#!/bin/sh"\necho "ap=\\\\$ap"\necho "data=$ap$data$ap"\necho -e "$data"'
echo "#!/bin/sh"
echo "ap=\\$ap"
echo "data=$ap$data$ap"
echo -e "$data"
