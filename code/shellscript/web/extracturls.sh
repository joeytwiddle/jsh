## The final '+' (instead of '*') in each expression means we won't match the empty url "xyz://".

## From plain text:
extractregex -atom "([A-Za-z]+:\/\/[^'\"> \n]+)"

## From HTML (absolute links only):
# extractregex -atom "[Hh][Rr][Ee][Ff]=['\"]{0,1}([A-Za-z]+:\/\/[^'\"> \n]+)"

## From HTML (absolute and relative links):
# extractregex -atom "[Hh][Rr][Ee][Ff]=['\"]{0,1}([^'\"> \n]+)"
