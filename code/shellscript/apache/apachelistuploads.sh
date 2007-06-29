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
jwatchchanges -fine -n 10 listopenfiles apache -u www-data
