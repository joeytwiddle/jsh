- `<`              Input Redirection: Reads standard input from a file instead of the keyboard.
- `<<`             Here Document: Reads input from the script itself, until a specified delimiter is encountered.
- `<<<`            Here String: Reads a single string as standard input.
- `<(___)`         Process Substitution (Input): Executes a command and treats its standard output as a temporary file that can be read from.
- `< $(___)`       Command Substitution (Input): Executes a command and uses its standard output as the input file for redirection.
- `<< $(___)`      RARELY DESIRED. Command Substitution with Here Document: Executes a command and then uses its output as the content for a Here Document, reading until the command's output is exhausted.
- `<<< "$(___)"`   Command Substitution with Here String: Executes a command and uses its standard output as a single string to be redirected as standard input.

So `foo | bar` is similar to `bar <<< $(foo)`
