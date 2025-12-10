#!/bin/bash
set -e

# A shell script to interact with the Gemini API, managing conversation history.
# Written but Gemini-2.0-Flash
#
# Requires: jq

#GEMINI_API_KEY="YOUR_API_KEY"
# gemini-2.0-flash is no longer available
# gemini-2.5-flash-lite may be faster to respond than gemini-2.5-flash
MODEL="${MODEL:=gemini-2.5-flash-lite}"
#MODEL="${MODEL:=gemini-2.5-flash}"
CONVERSATION_NAME="${CONVERSATION:=unnamed}"
#CONVERSATION_FILE="/tmp/gemini_conversation.${CONVERSATION_NAME}.json"
CONVERSATION_FILE="${HOME}/.cache/ai/gemini_conversation.${CONVERSATION_NAME}.json"
mkdir -p "$(dirname "$CONVERSATION_FILE")"

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

curl -sS -H "Content-Type: application/json" -d "${payload}" "${API_URL}" |
#tee /dev/stderr |
tee >(
    # This handles the error case, when the API responds with something other than 'data:' lines (usually a big JSON)
    grep --line-buffered -v '\(^data:\|^\s*$\)' |
    dateeachline "[response] " >/dev/stderr
) |
grep --line-buffered '^data:' |
while read -r data json_data
do
        # Can this ever happen? `data:` with a `.error`?
        if jq -e '.error' > /dev/null <<< "$json_data"
        then
            echo "Error from API:"
            jq '.' <<< "$json_data"
            exit 1
        fi
        chunk=$(jq -r '.candidates[0].content.parts[0].text' 2>/dev/null <<< "$json_data")
        if [ -n "$chunk" ]
        then
            echo -n "$chunk"
            echo -n "$chunk" >> "$temp_file"
        fi
done
echo

response_text=$(cat "$temp_file")

# For history, we need to create the content object.
response_content_object=$(jq -n --arg text "$response_text" '{role: "model", parts: [{text: $text}]}')

# Save or update the conversation history file
if [ "$1" != "-r" ]
then
    if [ -f "$CONVERSATION_FILE" ] && command -v rotate >/dev/null 2>&1
    then rotate -nozip -max 20 "$CONVERSATION_FILE" 2>&1 | grep -v '^\[rotate\] ' || true
    fi
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
