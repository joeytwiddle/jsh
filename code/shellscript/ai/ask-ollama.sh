#!/usr/bin/env bash
set -e

if [ -z "$MODEL" ]; then
    #MODEL="qwen2.5-coder:3b"
    #MODEL="qwen2.5-coder:7b"
    #MODEL="qwen3:1.7b"
    #MODEL="qwen3:4b"
    #MODEL="qwen3:8b"
    MODEL="ollama.com/huihui_ai/qwen3-abliterated:1.7b"
    #MODEL="jaahas/qwen3-abliterated:1.7b"
    #MODEL="jaahas/qwen3-abliterated:4b"
fi

# Function to highlight <think>...</think> responses in dark blue
highlight_think() {
	sed -u -E "s+<think>+$(curseblue)<think>+ ; s+</think>+</think>$(cursenorm)+"
}

strip_think() {
    awk '
        /^<think>$/ { in_think=1; next }
        /^<\/think>$/ { in_think=0; skip_empty=1; next }
        in_think { next }
        skip_empty && NF { skip_empty=0 }
        !skip_empty
    '
}

# Check if a prompt is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 \"prompt\""
    exit 1
fi

if [ "$1" = "-r" ]
then RESUME_CONVERSATION=true ; shift
fi

# Get the prompt from the first command-line argument
PROMPT="$*"

# Initialize or load the conversation file
if [ -z "$CONVERSATION_FILE" ]
then CONVERSATION_FILE="/tmp/${USER}-aishell-current-${MODEL//[:\/]/#}.json"
fi

CURRENT_CONVERSATION=""

if [ -n "$RESUME_CONVERSATION" ] && [ -f "$CONVERSATION_FILE" ]; then
    CURRENT_CONVERSATION="$(cat "$CONVERSATION_FILE")"

    FULL_PROMPT="Before answering my question, please see our previous conversation:

$(cat "$CONVERSATION_FILE" | prepend_each_line '> ')

OK that's the end of our conversation up to now. Here is the new query:

$PROMPT"
else
    # Add "think" at the start of your prompt, if you DO want thinking.
    # That only sometimes works.
    FULL_PROMPT="$PROMPT"
fi

# Send the prompt to ollama
ollama run "$MODEL" <<< "$FULL_PROMPT" |
    tee >(
        REPLY="$(cat | strip_think)"
        echo "${CURRENT_CONVERSATION}

        User: ${PROMPT}

        You: ${REPLY}

        " > "$CONVERSATION_FILE"
    ) |
    highlight_think |
    #--pager="less -REX" 
    #--theme="$BAT_THEME" 
    bat --pager="less -REX" -f --style=plain --force-colorization --language=markdown

