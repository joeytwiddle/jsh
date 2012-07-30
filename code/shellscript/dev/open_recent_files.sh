[ -d src ] && cd src

# A blacklist of recognised files which we know are not source files
ignore_non_source_files() {

	# Vim swap
	grep -v '/\..*\.sw.$' |
	grep -v '\.recovered\.' |

	# Output files
	# Java
	grep -v '\.class$' |
	# C
	grep -v '\.o$' |
	grep -v '\.so$' |
	# Ocaml
	grep -v '\.cm[io]$' |

	# BBC disk
	grep -v '\.ssd\(\.\|$\)' |

	# Versioning
	grep -v '/\.git/' |
	grep -v '/CVS/' |

	# Files without any '.' (likely binaries; most source files have an extension)
	grep -v '.*/[^.]*$' |

	cat

}

skip_derived_files() {

	while read fname
	do
		# If it looks like this file is derived from another file, skip it!
		# jpp processes $f.jpp -> $f and sometimes "$f"pp -> $f
		if [ -f "$fname".jpp ] || [ -f "$fname"pp ]
		then continue
		fi
		# todo: $f.coffee -> $f.js
		printf "%s\n" "$fname"
	done

}

find . -name "*.*" -type f |
ignore_non_source_files |
skip_derived_files |
sortfilesbydate |
# reverse |
tail -n 16 |
reverse |
withalldo e
