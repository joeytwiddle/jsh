# while true; do

  # cat "$@" | tr -d "\":\t'" | tr "?[:upper:]" ".[:lower:]" | tr -d "\n" | sed "s+\.+\.N+g" | tr "N" "\n" | festival --tts
          # cat "$@" | tr -d "\":\t'" | tr "?[:upper:]" ".[:lower:]" | tr "\n" " " | sed "s+\.+\.N+g" | tr "\t" " " | sed "s/^ //g" | sed "s/^ //g" | sed "s/^ //g" | tr "N" "\n" > tmp.txt
          # festival --tts tmp.txt
  
  # (
          # echo '("'
          # cat "$@" | sed "s/^ /\\
   # /"
          # echo ')'
  # ) | festival --tts
  
  cat "$@" > tmp.txt
  
  (
          echo '("'
          cat tmp.txt |
						sed "s/--/, /g" |
            tr "-" " " |
            # tr -s "\n" |
						sed "s/^$/\\
. new paragraph.\\
/" |
						tr "\n" " " |
            sed "s/\%/ percent /g" |
            sed "s/\?/./g" | tee hello.txt |
            sed "s/^ /\\
   /" |
            sed 's|\"\([^"]*\)\"| quote \1 unquote |g' |
            # sed 's|(\([^)]*\))| open-bracket \1 close-bracket |g' |
            sed 's|(| open-bracket |g' |
            sed 's|)| close-bracket |g' |
            sed 's|\"| unmatched-quote |g'
          echo '")'
  ) | tee tmp2.txt
  
  cat tmp2.txt | festival --tts
  
  # festival --tts "$@"
  
  # if test "x$1" = "x"; then
          # tr -d ":\".\t'" | festival --tts
          # # echo "txt2speech <file>"
          # # exit 1
  # # fi
  # else
          # cat "$@" | festival --tts
  # fi

# done
