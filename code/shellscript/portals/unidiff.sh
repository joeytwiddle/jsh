# Strips lines labeled as being in both documents.
# Leaves only lines unique to one document.
unicorn $* | grep -v "^\.\. " | grep -v "^\^\^ "