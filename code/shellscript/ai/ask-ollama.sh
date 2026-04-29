#!/bin/bash
set -e

# A shell script to interact with a local Ollama server, managing
# conversation history.
#
# Requires: jq, curl, and ollama (only needed if a model has to be auto-pulled)
#
# Env:
#   MODEL          Ollama model tag (default: gemma3:1b)
#   CONVERSATION   Conversation name (default: unnamed)
#   OLLAMA_API_URL Server URL (default: http://localhost:11434/api/chat)
#
# Usage:
#   ask-ollama.sh "prompt"        Start a new conversation
#   ask-ollama.sh -r "prompt"     Reply within the existing conversation
#
# On macOS, the ollama config/startup file is at:
#   /opt/homebrew/Cellar/ollama/<version>/homebrew.mxcl.ollama.plist
# Edit that file to add: <key>OLLAMA_KEEP_ALIVE</key> <string>48h</string>

if [ -z "$MODEL" ]; then
    #MODEL="qwen2.5-coder:7b" # Runs but a bit too big and slow (4.7GB)
    #MODEL="qwen2.5-coder:3b" # OK speed but stupid
    #MODEL="qwen3:8b" # Too big and slow (5GB)
    #MODEL="qwen3:4b" # OK, medium speed, but stupid
    #MODEL="qwen3:1.7b" # Incredibly stupid, but fast
    #MODEL="ollama.com/huihui_ai/qwen3-abliterated:1.7b" # OK not bad
    #MODEL="ollama.com/huihui_ai/qwen3-abliterated:4b" # Trying this one for speed (it's not fast but it's not too bad)
    # While Qwen3 is considered better at logic and math, Gemma3 is considered better at communication, and is multimodal.
    #MODEL="gemma3:4b"
    MODEL="gemma3:1b"
    #
    #MODEL="qwen2.5-coder:7b" # 4.7GB
    #MODEL="hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL" # 17GB
    #MODEL="jaahas/qwen3-abliterated:1.7b"
    #MODEL="jaahas/qwen3-abliterated:4b"
fi

OLLAMA_API_URL="${OLLAMA_API_URL:-http://localhost:11434/api/chat}"
CONVERSATION_NAME="${CONVERSATION:=unnamed}"
CONVERSATION_FILE="${HOME}/.cache/ai/ollama_conversation.${CONVERSATION_NAME}.json"
mkdir -p "$(dirname "$CONVERSATION_FILE")"

# Highlight <think>...</think> blocks in dark blue as the stream comes through
highlight_think() {
    sed -u -E "
        # Works for qwen2.5-coder
        s+<think>+$(curseblue)\0+ ; s+</think>+\0$(cursenorm)+
        # Works for qwen3-abliterated
        s+Thinking\.\.\.+$(curseblue)\0+ ; s+\.\.\.done thinking\.+\0$(cursenorm)+
    "
}

# Drop <think>...</think> blocks (used before saving to history)
strip_think() {
    awk '
        /^<think>$/ { in_think=1; next }
        /^<\/think>$/ { in_think=0; skip_empty=1; next }
        in_think { next }
        skip_empty && NF { skip_empty=0 }
        !skip_empty
    '
}

# Make sure the model is on the server; if not, try to pull it via the
# `ollama` CLI (which only helps if the server is local).
ensure_model() {
    local model="$1"
    local base_url="${OLLAMA_API_URL%/api/chat}"
    local models
    models=$(curl -sS "$base_url/api/tags" 2>/dev/null | jq -r '.models[].name' 2>/dev/null || true)
    if echo "$models" | grep -qE "^${model}(:latest)?$"; then
        return 0
    fi
    if ! command -v ollama &> /dev/null; then
        echo "Error: model '$model' is not on the server, and the 'ollama' CLI is not installed locally to pull it." >&2
        exit 1
    fi
    echo "Pulling Ollama model: $model" >&2
    if ! ollama pull "$model"; then
        echo "Failed to pull model: $model" >&2
        exit 1
    fi
}

# Build messages array (fresh or extended from history)
if [ "$1" = "-r" ]; then
    PROMPT="$2"
    if [ -z "$PROMPT" ]; then
        echo "Error: Missing prompt after -r option." >&2
        exit 1
    fi
    if [ ! -f "$CONVERSATION_FILE" ]; then
        echo "Error: No conversation history found. Start a new conversation first." >&2
        exit 1
    fi

    history_contents=$(cat "$CONVERSATION_FILE")
    new_user_msg=$(jq -n --arg text "$PROMPT" '{role: "user", content: $text}')
    messages=$(echo "$history_contents" | jq ". + [${new_user_msg}]")
else
    PROMPT="$1"
    if [ -z "$PROMPT" ]; then
        echo "Error: Missing prompt." >&2
        exit 1
    fi

    PROMPT="(Give brief answers to the following queries. Ideally just one or two paragraphs, or just one sentence if appropriate.) Here is the first query: ${PROMPT}"
    messages=$(jq -n --arg text "$PROMPT" '[{role: "user", content: $text}]')
fi

ensure_model "$MODEL"

payload=$(jq -n \
    --arg model "$MODEL" \
    --argjson messages "$messages" \
    '{model: $model, stream: true, messages: $messages}')

# Stream the response. Ollama emits newline-delimited JSON; we extract
# .message.content from each line, write the assembled text to a temp
# file (for history), and pipe stdout through highlight_think.
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

curl -sS -H "Content-Type: application/json" -d "$payload" "$OLLAMA_API_URL" |
while read -r line; do
    [ -z "$line" ] && continue
    err=$(jq -r '.error // empty' <<<"$line" 2>/dev/null || true)
    if [ -n "$err" ]; then
        echo "Ollama error: $err" >&2
        exit 1
    fi
    chunk=$(jq -r '.message.content // empty' <<<"$line" 2>/dev/null || true)
    if [ -n "$chunk" ]; then
        echo -n "$chunk"
        echo -n "$chunk" >> "$temp_file"
    fi
done | highlight_think
echo

# Persist conversation history (strip <think> blocks before saving so the
# model doesn't re-read its own scratch reasoning on the next turn)
response_text=$(strip_think < "$temp_file")
response_msg=$(jq -n --arg text "$response_text" '{role: "assistant", content: $text}')

if [ "$1" != "-r" ]; then
    if [ -f "$CONVERSATION_FILE" ] && command -v rotate >/dev/null 2>&1; then
        rotate -quiet -nozip -max 20 "$CONVERSATION_FILE"
    fi
    user_msg=$(jq -n --arg text "$PROMPT" '{role: "user", content: $text}')
    jq -n --argjson user_msg "$user_msg" --argjson assistant_msg "$response_msg" \
        '[$user_msg, $assistant_msg]' > "$CONVERSATION_FILE"
else
    # `messages` already includes the new user prompt; just append the response.
    new_history=$(echo "$messages" | jq --argjson assistant_msg "$response_msg" '. + [$assistant_msg]')
    echo "$new_history" > "$CONVERSATION_FILE"
fi
