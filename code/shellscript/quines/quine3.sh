#!/bin/sh
ap="'"
data='echo "#!/bin/sh"\necho "ap=\"'$ap'\""\necho "data='$ap'$data'$ap'" | sed "s+'$ap'+'$ap'\$ap'$ap'+g ; s+'$ap'\$'$ap'+'$ap'+ ; s+'$ap'\$ap'$ap'$+'$ap'+"\necho -e "$data"'
echo "#!/bin/sh"
echo "ap=\"'\""
echo "data='$data'" | sed "s+'+'\$ap'+g ; s+'\$ap'+'+ ; s+'\$ap'$+'+"
echo -e "$data"
