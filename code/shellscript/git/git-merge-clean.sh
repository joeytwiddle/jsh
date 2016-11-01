find . -name '*.orig' -or -name '*.rej' \
	-or -name '*.BASE.*' -or -name '*.REMOTE.*' -or -name '*.LOCAL.*' -or -name '*.BACKUP.*' \
	-or -name '*_BASE_*' -or -name '*_REMOTE_*' -or -name '*_LOCAL_*' -or -name '*_BACKUP_*' \
	| foreachdo del
