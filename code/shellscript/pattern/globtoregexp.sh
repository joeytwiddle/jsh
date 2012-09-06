# Newline to newline-match-char?
sed '

  # \ -> \\   (new)
  s+\\+\\\\+g

  # . -> \.
  s+\.+\\.+g

  # * -> .*
  s+\*+.*+g

  # ? -> .
  s+\?+.+g

'
