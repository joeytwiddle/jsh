## Well, this actually lists files currently opened for reading by apache:

## No good:
# lsof -n -i :http -i :https |

## Good:
# lsof -n -u www-data |

## Nice: Reduced default timeout and report any failures:
# lsof -n -u www-data -S 2 -V |

## Needed for all above:
# grep "^apache" |
# grep "^[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*r " |
# grep -v "\<CHR\>"

## Watcher:
# jwatchchanges -fine -n 10 listopenfiles apache -u www-data

## TODO: I think often things are repeated 3 times, because of all our chroot bind-mounts.

listopenfiles apache 2>/dev/null |
grep -v "\<cwd\>" | ## new
grep -v "\<DIR\>" | ## new
grep -v "\.so\($\|\.\)" |
grep -v "\.log$" |
grep -v "\(/usr/sbin/apache\|/mnt/hdb3$\|/SYSV0*$\|/dev/null$\|TCP \*\|can't identify protocol\)" |
grep -v " /$" |
grep -v "\[heap\] (stat: No such file or directory)$" |
grep "\<REG\>" | grep -v "\<DEL\>" | grep -v "/usr/lib/apache2/"

