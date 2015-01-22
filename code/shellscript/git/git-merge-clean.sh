find . -name '*.orig' -or -name '*.rej' -or -name '*.BASE.*' -or -name '*.REMOTE.*' -or -name '*.LOCAL.*' -or -name '*.BACKUP.*' | foreachdo del
