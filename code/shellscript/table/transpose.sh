#/bin/bash
# Transpose shell output (delimited by spaces)
# source: http://stackoverflow.com/a/1729980/46871
#
# Example:
#     $ cat file.txt
#     foo   bar   baz
#     31    12    AOK
#     33    15    BOH
#     29    14    BOH
#     $ transpose file.txt
#     foo 31 33 29
#     bar 12 15 14
#     baz AOK BOH BOH
#

filename=$1

if [[ $filename == "" ]]; then
  echo "Usage: "
  echo "  $ cat file.txt"
  echo "  foo   bar   baz"
  echo "  31    12    AOK"
  echo "  33    15    BOH"
  echo "  29    14    BOH"
  echo "  $ transpose file.txt"
  echo "  foo 31 33 29"
  echo "  bar 12 15 14"
  echo "  baz AOK BOH BOH"
  exit 1
fi

awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}' $filename

