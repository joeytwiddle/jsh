(
	echo '<html><body>'
	fc-list |
	sed 's/\(.*\):.*/<font face="\1">\1<\/font><br>/' |
	sort | uniq
	echo '</body></html>'
) > fonts.html
