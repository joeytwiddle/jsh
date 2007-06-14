# jsh-ext-depends-ignore: apm
# date +"%d/%m/%Y %H:%M%p" "$@"
date +"%H:%M%p %d/%m/%Y" "$@" | tr "APM" "apm"
