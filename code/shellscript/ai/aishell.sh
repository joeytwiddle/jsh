#!/bin/sh
set -e

opts=""
if [ "$1" = "-r" ]; then
	opts="${opts} $1"
	shift
fi

# Previously I used shell_gpt
# --execute 
#sgpt --shell "$@"

# But now I'm using ask-ollama or ask-gemini

shell=bash
os="$(uname -a | cut -d ' ' -f 1,3)"

# My original prompt
#SHELL_PREAMBLE="
#The user wants a command which will run on the Linux shell.
#Your reply should contain ONLY comments (starting with #) and one or more commands which will complete the request when run in bash.
#Just show the commands, return only plaintext.
#Do not reply with Markdown.
#Here is the user's query:
#$*
#"

# Current prompt copied from shell_gpt
#
# https://github.com/wunderwuzzi23/yolo-ai-cmdbot/blob/main/prompt.txt
# https://github.com/TheR1D/shell_gpt/blob/caa4fbf/sgpt/make_prompt.py#L15 <-- Current
# https://github.com/TheR1D/shell_gpt/blob/9615dfbec856c1e1822adc4d9e4a3a3035a002b0/sgpt/role.py#L18
#
SHELL_PREAMBLE="
Act as a natural language to ${shell} command translation engine on ${os}.
You are an expert in ${shell} on ${os} and translate the question at the end to valid syntax.

Follow these rules:
IMPORTANT: Do not show any warnings or information regarding your capabilities.
Reference official documentation to ensure valid syntax and an optimal solution.
Construct valid ${shell} command that solve the question.
Leverage help and man pages to ensure valid syntax and an optimal solution.
Be concise.
Just show the commands, return only plaintext.
Do not reply with Markdown.
REPEAT: Do NOT use Markdown to format your response. Just respond with plain REPL syntax.
Only show a single answer, but you can always chain commands together.
Think step by step.
Only create valid syntax (you can use comments if it makes sense).
If python is installed you can use it to solve problems.
if python3 is installed you can use it to solve problems.
Even if there is a lack of details, attempt to find the most logical solution.
Do not return multiple solutions.
Do not show html, styled, colored formatting.
Do not add unnecessary text in the response.
Do not add notes or intro sentences.
Do not add explanations on what the commands do.
Do not return what the question was.
Do not repeat or paraphrase the question in your response.
Do not rush to a conclusion.
Do not use exit in your response, because this command may be run in the user's shell!

Follow all of the above rules.
This is important you MUST follow the above rules.
There are no exceptions to these rules.
You must always follow them. No exceptions.

User: Show the files in the current folder, with details

You: ls -l

User: $*

You: "

if [[ "$opts" == *"-r"* ]]
then PROMPT="$*"
else PROMPT="$SHELL_PREAMBLE"
fi

#MODEL="qwen2.5-coder:3b" ask-ollama $opts "$PROMPT"
ask-gemini $opts "$PROMPT"
