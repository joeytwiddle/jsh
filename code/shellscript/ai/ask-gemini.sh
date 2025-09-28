#!/bin/bash
set -e

# A shell script to interact with the Gemini API, managing conversation history.
# Written but Gemini-2.0-Flash
#
# Requires: jq

#GEMINI_API_KEY="YOUR_API_KEY"
# With no subscription (free version) I found 2.0 much faster to respond than 2.5 (noticeable when streaming)
# Although both are quite chunky, compared to other AIs
MODEL="${MODEL:=gemini-2.0-flash}"
#MODEL="${MODEL:=gemini-2.5-flash}"
CONVERSATION_NAME="${CONVERSATION:=unnamed}"
CONVERSATION_FILE="/tmp/gemini_conversation.${CONVERSATION_NAME}.json"

API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:streamGenerateContent?alt=sse&key=${GEMINI_API_KEY}"

if [ -z "$GEMINI_API_KEY" ]
then
    echo "You need to export the variable GEMINI_API_KEY. You can get one from https://aistudio.google.com/app/api-keys"
    exit 1
fi

if [ "$1" == "-r" ]
then
    PROMPT="$2"
    if [ -z "$PROMPT" ]
    then
        echo "Error: Missing prompt after -r option."
        exit 1
    fi

    # Ensure history file exists
    if [ ! -f "$CONVERSATION_FILE" ]
    then
        echo "Error: No conversation history found. Start a new conversation first."
        exit 1
    fi

    # Read existing history and add the new user prompt
    history_contents=$(cat "$CONVERSATION_FILE")
    new_user_part=$(jq -n --arg text "$PROMPT" '{role: "user", parts: [{text: $text}]}')
    updated_contents=$(echo "$history_contents" | jq ". + [${new_user_part}]")

    # Construct the final payload
    payload=$(jq -n --argjson contents "${updated_contents}" '{contents: $contents}')
else
    # Start a new conversation
    PROMPT="$1"
    if [ -z "$PROMPT" ]
    then
        echo "Error: Missing prompt."
        exit 1
    fi

    # Create the initial contents array with the user's prompt
    initial_contents=$(jq -n --arg text "$PROMPT" '[{role: "user", parts: [{text: $text}]}]')

    # Construct the final payload
    payload=$(jq -n --argjson contents "${initial_contents}" '{contents: $contents}')
fi

# Make the API call and stream the response
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

curl -s -H "Content-Type: application/json" -d "${payload}" "${API_URL}" |
#tee /dev/stderr |
#tee >(
#    dateeachline "[response] " >/dev/stderr
#) |
while read -r line
do
    if [[ $line == "data:"* ]]
    then
        json_data=$(echo "$line" | sed 's/^data: //')
        if echo "$json_data" | jq -e '.error' > /dev/null
    then
            echo "Error from API:"
            echo "$json_data" | jq '.'
            exit 1
        fi
        chunk=$(echo "$json_data" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
        if [ -n "$chunk" ]
        then
            echo -n "$chunk"
            echo -n "$chunk" >> "$temp_file"
        fi
    fi
done |
bat --pager="less -REX" -f --style=plain --force-colorization --language=markdown

response_text=$(cat "$temp_file")

# For history, we need to create the content object.
response_content_object=$(jq -n --arg text "$response_text" '{role: "model", parts: [{text: $text}]}')

# Save or update the conversation history file
if [ "$1" != "-r" ]
then
    # The initial user part was already constructed
    user_part=$(jq -n --arg text "$PROMPT" '{role: "user", parts: [{text: $text}]}')
    # Create a new history array
    jq -n --argjson user_part "$user_part" --argjson model_part "$response_content_object" '[$user_part, $model_part]' > "$CONVERSATION_FILE"
else
    # Append the model's response to the existing history
    current_history=$(cat "$CONVERSATION_FILE")
    new_history=$(echo "$current_history" | jq --argjson model_part "$response_content_object" '. + [$model_part]')
    echo "$new_history" > "$CONVERSATION_FILE"
fi
