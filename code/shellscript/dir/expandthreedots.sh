## Converts: .../hello/../goodbye/..../end (win9x+)
##     into: ./../..//hello/..//goodbye/../../..//end (unix)
echo "$*" |
sed '
	s+\(\/\)\.+\1+g
	s+\.+\.\./+g
	s+^\.\.\/+\.\/+
'
