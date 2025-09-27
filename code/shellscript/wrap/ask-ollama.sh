#!/bin/bash

if [ -z "$MODEL" ]; then
    #MODEL="qwen2.5-coder:3b"
    #MODEL="qwen2.5-coder:7b"
    MODEL="qwen3:1.7b"
    #MODEL="qwen3:4b"
fi

# Function to highlight <think>...</think> responses in dark blue
highlight_think() {
	sed -u -E "s+<think>+$(curseblue)<think>+ ; s+</think>+</think>$(cursenorm)+"
}

# Check if a prompt is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 \"prompt\""
    exit 1
fi

# Get the prompt from the first command-line argument
PROMPT="$1"
    PROMPT="Before answering my question, please see our previous conversation:"

# Initialize or load the conversation file
CONVERSATION_FILE="/tmp/$USER-aishell-current.json"
if [ ! -f "$CONVERSATION_FILE" ]; then
    echo "{}" > "$CONVERSATION_FILE"
fi

# Get the current conversation
CURRENT_CONVERSATION=$(cat "$CONVERSATION_FILE")

# Append the new prompt to the conversation and store it back
#NEW_CONVERSATION=$(jq --arg prompt "$PROMPT" '$current + {prompt: $prompt}' <<< "$CURRENT_CONVERSATION")

# Send the prompt to ollama
ollama run "$MODEL" <<< "$PROMPT\n:exit" |
	tee -a "$CONVERSATION_FILE" |
	highlight_think |
	 #--pager="less -REX" 
	bat --theme="$BAT_THEME" --pager="cat" -f --style=plain --force-colorization --language=markdown

