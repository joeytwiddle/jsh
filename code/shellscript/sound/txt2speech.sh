(

	echo "("

	cat |

	col -bx |
	# tr -s "\n" |

	# For IRC logs:
	# sed 's+\[\(..\):\(..\)\] <\([^>]*\)>+At \1 \2 user \3 said +' |
	sed "s+\[\(..\):\(..\)\] <\([^>]*\)>+ . \\
\3 says +" |

 tee /tmp/tmp-tts.txt |	

	sed "s/--/, /g" |
	sed "s/-/ dash /g" |
	# sed "s/\./ dot /g" |
	# sed "s/^$/\\
# . new paragraph.\\
# /" |
	# tr "\n" " " |
	# sed "s|\(\. new paragraph\.\)|\1\\
# |g" |
	sed "s/^$/NEW_PARAGRAPH/" |
	tr "\n" " " |
	sed "s/NEW_PARAGRAPH/\\
/g" |
	sed "s/\%/ percent /g" |
	sed "s/\?/./g" |
	sed "s/^ /\\
/" |
	sed 's|\"\([^"]*\)\"| quote \1 unquote |g' |
	# sed 's|(\([^)]*\))| open-bracket \1 close-bracket |g' |
	sed 's|(| open-bracket |g' |
	sed 's|)| close-bracket |g' |
	sed 's|\"| unmatched-quote |g'

	echo ")"

) |

festival --tts

