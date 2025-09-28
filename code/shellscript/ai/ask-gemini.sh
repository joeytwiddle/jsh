#!/bin/bash

# A shell script to interact with the Gemini API, managing conversation history.
# Written but Gemini-2.0-Flash

#GEMINI_API_KEY="YOUR_API_KEY"
MODEL="gemini-2.0-flash"
#MODEL="gemini-2.5-flash"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}"
HISTORY_FILE="/tmp/gemini_conversation.json"

# --- Helper Functions ---

# Function to send a request to the Gemini API
# Expects the JSON payload as the first argument
call_gemini_api() {
    local payload="$1"
    curl -s -H "Content-Type: application/json" -d "${payload}" "${API_URL}"
}

# Function to extract the text content from the API response
extract_text() {
    local response="$1"
    echo "$response" | jq -r '.candidates[0].content.parts[0].text'
}

# Function to extract the full content object from the API response
extract_content_object() {
    local response="$1"
    echo "$response" | jq -r '.candidates[0].content'
}


# --- Main Logic ---

# Check for -r flag to continue a conversation
if [ "$1" == "-r" ]; then
    # Ensure a prompt is provided
    if [ -z "$2" ]; then
        echo "Error: Missing prompt after -r option."
        exit 1
    fi
    PROMPT="$2"

    # Ensure history file exists
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "Error: No conversation history found. Start a new conversation first."
        exit 1
    fi

    # Read existing history and add the new user prompt
    history_contents=$(cat "$HISTORY_FILE")
    new_user_part=$(jq -n --arg text "$PROMPT" '{role: "user", parts: [{text: $text}]}')
    updated_contents=$(echo "$history_contents" | jq ". + [${new_user_part}]")

    # Construct the final payload
    payload=$(jq -n --argjson contents "${updated_contents}" '{contents: $contents}')

else
    # Start a new conversation
    PROMPT="$1"
    if [ -z "$PROMPT" ]; then
        echo "Error: Missing prompt."
        exit 1
    fi

    # Create the initial contents array with the user's prompt
    initial_contents=$(jq -n --arg text "$PROMPT" '[{role: "user", parts: [{text: $text}]}]')

    # Construct the final payload
    payload=$(jq -n --argjson contents "${initial_contents}" '{contents: $contents}')
fi

# Make the API call
api_response=$(call_gemini_api "${payload}")

# Check for API errors
if echo "$api_response" | jq -e '.error' > /dev/null; then
    echo "Error from API:"
    echo "$api_response" | jq '.'
    exit 1
fi

# Extract the response text and the full response content object
response_text=$(extract_text "$api_response")
response_content_object=$(extract_content_object "$api_response")

# Display the response to the user
echo "$response_text" |
    bat --pager="less -REX" -f --style=plain --force-colorization --language=markdown

# --- History Management ---

# For a new conversation, create the history file
if [ "$1" != "-r" ]; then
    # The initial user part was already constructed
    user_part=$(jq -n --arg text "$PROMPT" '{role: "user", parts: [{text: $text}]}')
    # Create a new history array
    jq -n --argjson user_part "$user_part" --argjson model_part "$response_content_object" '[$user_part, $model_part]' > "$HISTORY_FILE"
else
    # Append the model's response to the existing history
    current_history=$(cat "$HISTORY_FILE")
    new_history=$(echo "$current_history" | jq ". + [${response_content_object}]")
    echo "$new_history" > "$HISTORY_FILE"
fi