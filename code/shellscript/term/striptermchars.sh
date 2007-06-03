## Removes all special terminal characters from stream
## See also: strings, mimencode
## (Problem with 'strings', is that it also strips adjacent newlines.)

# jsh-ext-depends: sed

## Remove curses colour codes:
sed -u 's+[^m]*m++g' |

## Remove other non-printing characters:
sed -u 's+[^[:print:][:space:]]++g'

