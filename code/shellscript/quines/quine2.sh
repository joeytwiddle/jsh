#!/bin/sh
a="#!/bin/sh\na=<X>;echo \"\$q\"";
b=$(echo "$a" | sed "s+<X>+$a+")
echo -e "#!/bin/sh\na=\"$a\"\n$b"
