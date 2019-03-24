#!/bin/sh
l0="for n in \$(seq 0 2)"
l1="do"
l2="  val=\"\$(eval \"printf \\\"%s\\\" \\\"\\\$l\${n}\\\"\")\""
# END DATA
echo '#!/bin/sh'
for n in $(seq 0 2)
do
  val="$(eval "printf \"%s\" \"\$l${n}\"" | sed 's+\\+\\\\\\\\+g')"
  printf "%s\n" "l${n}=\"$(printf "%s" "$val" | sed 's+\\+\\\\\\\\+g')\""
done
for n in $(seq 0 2)
do
  val="$(eval "printf \"%s\" \"\$l${n}\"")"
  printf "%s\n" "$val"
done
