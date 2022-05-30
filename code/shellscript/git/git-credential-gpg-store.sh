#!/usr/bin/env bash
set -e

# Like git-credential-store, this helper reads and writes credentials to the given file, but it encrypts that file using gpg.
#
# To use this helper, save it somewhere on your PATH as git-credential-gpg-store, make sure it is executable, and then run:
#
#     git config --global credential.helper gpg-store
#
# or:
#
#     git config --global credential.helper "gpg-store --file ~/.git-credentials-encrypted"
#
# or, if you haven't put it on your PATH, and haven't removed the extension:
#
#     git config --global credential.helper /path/to/git-credential-gpg-store.sh

# Caveats:
# - It stores the records delimited by tab characters.  If your username or password contains a tab character then this script will break!
# - It uses grep regexps to extract the desired record.  If your username or password contains special regexp strings then this script may break!
# - If you use the git-credential-cache helper, it may try to `store` the credentials when you make a connection.  But because our store operation does a decrypt, it will prompt for your gpg password, somewhat invalidating the point of the cache.
#   TODO: We could avoid this by storing an unencrpyed list of sha1sums and salts for the stored credentials.  If the hash for the requested credential is present, then we know we don't need to store it.  However, if an attacker obtained such a hash, it could be used to speed up a brute-force attack.  Salting could help.
#   TODO: Alternatively, we could store each credential in a separate file, so we can write one credential without decrypting the others.  That sounds better, but how to name the files?  It could be a hash or not-a-hash of the credentials-minus-the-password.
#   Or perhaps easiest, let the user increase the timeout on gpg's passphrase prompt.  My system uses `pinentry-gtk-2` which does offer to store the passphrase in the user's password manager.

# Alternatives: libsecret, pass+netrc, ... https://my-take-on.tech/2019/08/23/safely-storing-git-credentials/
# https://stackoverflow.com/questions/53305965/whats-the-best-encrypted-git-credential-helper-for-linux
# Personally, I have switched to: /usr/lib/git-core/git-credential-libsecret

#DEBUG=1

[ -n "$DEBUG" ] && echo "### [git-credential-gpg-store] Arguments: $*" >&2

credentials_file="$HOME/.git-credentials-encrypted"
if [ "$1" = "--file" ]
then credentials_file="$2"; shift; shift
fi

[ -z "$GPG_EXECUTABLE" ] && which gpg >/dev/null 2>&1 && GPG_EXECUTABLE="gpg"
[ -z "$GPG_EXECUTABLE" ] && which gpg2 >/dev/null 2>&1 && GPG_EXECUTABLE="gpg2"
[ -z "$GPG_EXECUTABLE" ] && echo "No gpg found.  Please install one, or set GPG_EXECUTABLE" >&2 && exit 5

[ -z "$GPG_KEY" ] && GPG_KEY="$("$GPG_EXECUTABLE" --list-keys --with-colons | grep "^pub:" | head -n 1 | tr : ' ' | cut -d ' ' -f 5)"

command="$1"

record="$(cat | tr '\n' '\t')"

[ -n "$DEBUG" ] && echo "### [git-credential-gpg-store] command: $command" >&2
[ -n "$DEBUG" ] && echo "### [git-credential-gpg-store] record: $record" >&2

read_credentials_file() {
	"$GPG_EXECUTABLE" -q --decrypt "$credentials_file"
}

write_credentials_file() {
	# Before writing to the file, we make sure it's not readable by others
	touch "${credentials_file}.new"
	chmod 0600 "${credentials_file}.new"
	# Now we can write stdin to the file, but encrypted
	"$GPG_EXECUTABLE" -q -r "$GPG_KEY" --encrypt > "${credentials_file}.new"
	mv -f "${credentials_file}.new" "$credentials_file"
}

case "$command" in

	get)
		if [ ! -f "$credentials_file" ]
		then exit 1
		fi

		line="$(read_credentials_file | grep "^${record}\s*password=")" || true
		[ -n "$DEBUG" ] && echo "### [git-credential-gpg-store] line: $line" >&2
		if [ -z "$line" ]
		then exit 1
		fi

		result="$(printf "%s\n" "$line" | tr '\t' '\n')"
		[ -n "$DEBUG" ] && echo "### [git-credential-gpg-store] result: $result" >&2
		printf "%s\n" "$result"
		;;

	store)
		if [ -f "$credentials_file" ] && read_credentials_file | grep "^${record}$" >/dev/null 2>/dev/null
		then
			[ -n "$DEBUG" ] && echo "### [git-credential-gpg-store] Already stored" >&2
			exit 0
		fi

		(
			[ -f "$credentials_file" ] && read_credentials_file
			printf "%s\n" "$record"
		) |
		write_credentials_file
		;;
	
	erase)
		if [ ! -f "$credentials_file" ]
		then exit 0
		fi

		read_credentials_file |
		grep -v "^$record" |
		write_credentials_file
		;;

esac
