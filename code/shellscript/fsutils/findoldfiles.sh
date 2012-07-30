find "$@" -type f -printf "%AY%Am%Ad-%AH%AM%AS %p\n" | sort -n -k 1
