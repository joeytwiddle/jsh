# cat $* | tr -d "\":\t'" | tr "?[:upper:]" ".[:lower:]" | tr -d "\n" | sed "s+\.+\.N+g" | tr "N" "\n" | festival --tts
# while true; do
        # cat $* | tr -d "\":\t'" | tr "?[:upper:]" ".[:lower:]" | tr "\n" " " | sed "s+\.+\.N+g" | tr "\t" " " | sed "s/^ //g" | sed "s/^ //g" | sed "s/^ //g" | tr "N" "\n" > tmp.txt
        # festival --tts tmp.txt
# done

# (
        # echo '("'
        # cat "$*" | sed "s/^ /\\
 # /"
        # echo ')'
# ) | festival --tts

cat $* > tmp.txt

# Still completely fucked for no good reason

(
        echo '("'
        cat tmp.txt |
          tr "-" " " |
          tr -s "\n" |
          sed "s/\%/ percent /g" |
          sed "s/\?/./g" | tee hello.txt |
          sed 's|"\([^"]*\)\"| - quote - \1 - unquote - |g' |
          sed 's|\"| - unmatched quote - |g' |
          sed "s/^ /\\
 /"
        echo ')'
) | tee tmp2.txt

cat tmp2.txt | festival --tts

# festival --tts "$*"

# if test "x$*" = "x"; then
        # tr -d ":\".\t'" | festival --tts
        # # echo "txt2speech <file>"
        # # exit 1
# # fi
# else
        # cat "$*" | festival --tts
# fi
