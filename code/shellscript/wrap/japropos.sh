## Adds colour highlight to apropos; also runs aproposjsh
## Script intended to be aliased to apropos in user's shell.
(
	# `jwhich apropos` "$@"
	aproposjsh "$@" | highlight "\<jsh\>"
) | highlight "`caseinsensitiveregex "$@"`"
