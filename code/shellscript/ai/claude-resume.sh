#!/usr/bin/env bash
# vim: filetype=sh ts=2 sw=2 expandtab
#
# claude-resume - fzf-based picker for Claude Code sessions
#
# Lists sessions from the current folder first, then the 10 most-recent sessions
# across all folders. Preview shows the tail of the conversation. CTRL-D deletes
# (with confirmation), Enter resumes via `claude --resume <id>`.
#
# Internal subcommands (used by the preview/exec contexts) are kept at the bottom
# of this file.

set -euo pipefail

CLAUDE_PROJECTS_DIR="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"
OTHER_FOLDERS_LIMIT="${CLAUDE_RESUME_OTHER_LIMIT:-50}"
PREVIEW_TAIL_MESSAGES="${CLAUDE_RESUME_PREVIEW_MESSAGES:-20}"

main() {
  if [ ! -d "$CLAUDE_PROJECTS_DIR" ]; then
    echo "No Claude projects directory at $CLAUDE_PROJECTS_DIR" >&2
    return 1
  fi

  local cwd
  cwd="$(pwd -P)"

  # The typed search is preserved across iterations (CTRL-D / CTRL-R re-open
  # fzf). Cursor row position is NOT restored — fzf's pos() interacts badly
  # with our streamed input.
  local last_query=""

  while :; do
    local out
    if ! out="$(
      stream_list "$cwd" |
      fzf --ansi \
          --with-nth=2.. \
          --delimiter=$'\t' \
          --no-sort \
          --multi \
          --print-query \
          --query="$last_query" \
          --header=$'TAB: mark   Enter: resume   CTRL-R: rename   DEL: delete   CTRL-/: toggle preview   ESC: cancel' \
          --bind 'ctrl-/:toggle-preview' \
          --bind 'focus:transform:[ -z {1} ] && echo "change-preview-window:hidden" || echo "change-preview-window:right,50%,wrap,border-left,follow"' \
          --preview 'claude-resume --preview {1}' \
          --preview-window 'hidden,right,50%,wrap,border-left,follow' \
          --expect=del,ctrl-r
    )"; then
      return 0
    fi

    # With --print-query + --multi the output is:
    #   <query>\n<key>\n<row1>\n<row2>\n...
    # If the user pressed Enter or CTRL-R without marking anything, fzf still
    # emits the cursor row as a single "selected" line.
    last_query="$(printf '%s\n' "$out" | sed -n '1p')"
    local key
    key="$(printf '%s\n' "$out" | sed -n '2p')"

    # Collect every selected session_id from row 3 onwards, skipping headers
    # (which have an empty column 1).
    local session_ids=()
    local line
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      local sid
      sid="$(printf '%s' "$line" | cut -f1)"
      [ -n "$sid" ] && session_ids+=("$sid")
    done < <(printf '%s\n' "$out" | tail -n +3)

    if [ "${#session_ids[@]}" -eq 0 ]; then
      continue
    fi

    if [ "$key" = "del" ]; then
      delete_sessions "${session_ids[@]}" || true
      continue
    fi

    # Rename and resume only operate on a single session — pick the last one
    # the user marked (same convention fzf uses for the "primary" selection).
    local target="${session_ids[${#session_ids[@]} - 1]}"

    if [ "$key" = "ctrl-r" ]; then
      rename_session "$target" || true
      continue
    fi

    resume_session "$target"
    return $?
  done
}

# Stream rows to fzf. Output (TAB-separated, fzf hides column 1):
#   <session_id>\t<formatted_row>
# Header rows have an empty session_id so they can't be selected.
#
# Strategy:
#   1. List all .jsonl files with mtime+size from one stat call (fast).
#   2. Sort by mtime desc.
#   3. For each file, extract cwd + first user prompt with a single awk pass
#      (awk is ~6× faster than jq + grep + head + cut for this).
#   4. Bucket into "this folder" vs "other recent" and emit with headers.
#
# Step 3 dominates when there are hundreds of large session files. We could
# parallelise with `xargs -P`, but `awk` already bails out at the first prompt
# so per-file cost is small. Parallelism is held in reserve in case the user
# accumulates thousands of sessions.
stream_list() {
  local cwd="$1"

  # Preformat rows for ALL sessions, then split into the two buckets.
  # We can't stream incrementally because we need to know each session's cwd
  # before we know which bucket it belongs to, and we want the "this folder"
  # bucket on top.
  local rows
  rows="$(index_and_format)"

  local cwd_rows other_rows
  cwd_rows="$(printf '%s\n' "$rows"  | awk -F'\t' -v cwd="$cwd" '$3 == cwd')"
  other_rows="$(printf '%s\n' "$rows" | awk -F'\t' -v cwd="$cwd" '$3 != cwd' | head -n "$OTHER_FOLDERS_LIMIT")"

  if [ -n "$cwd_rows" ]; then
    printf '\t\033[1;36m── This folder ──\033[0m\n'
    printf '%s\n' "$cwd_rows" | awk -F'\t' 'BEGIN {OFS="\t"} { print $1, $4 }'
  fi
  if [ -n "$other_rows" ]; then
    printf '\t\033[1;36m── Recent ──\033[0m\n'
    printf '%s\n' "$other_rows" | awk -F'\t' 'BEGIN {OFS="\t"} { print $1, $4 }'
  fi
}

# Emit one row per session file, sorted newest-first:
#   <sid>\t<mtime>\t<cwd>\t<formatted_display_columns>
# Display columns are pre-rendered with ANSI colours and tab-padded so we can
# strip the bookkeeping prefix with `cut`.
index_and_format() {
  local f sid mtime size_bytes
  # Stat all files in one loop. macOS/BSD `stat -f` and GNU `stat -c` differ;
  # we picked one form per system already in file_size_bytes/file_mtime_epoch.
  # We avoid spawning per-file `stat` by using bash's own glob + a single awk
  # that calls `stat` on the whole list at once.
  local files=()
  for f in "$CLAUDE_PROJECTS_DIR"/*/*.jsonl; do
    [ -f "$f" ] || continue
    files+=("$f")
  done
  [ "${#files[@]}" -eq 0 ] && return 0

  # Bulk-stat → sort newest-first → write a sidecar TSV file with one row
  # per session ("<file>\t<mtime>\t<size>\t<sid>"). awk reads the sidecar in
  # BEGIN, then processes every JSONL file in a single pass. One awk process
  # for the whole job is ~10× faster than spawning one per file.
  local sidecar_file
  sidecar_file="$(mktemp -t claude-resume.XXXXXX)"
  trap 'rm -f "$sidecar_file"' RETURN

  bulk_stat "${files[@]}" | sort -rn | awk -F'\t' '{
    sid = $3
    sub(/.*\//, "", sid); sub(/\.jsonl$/, "", sid)
    print $3 "\t" $1 "\t" $2 "\t" sid
  }' > "$sidecar_file"

  [ ! -s "$sidecar_file" ] && return 0

  # Build the file list for awk in the same order as the sidecar.
  local files_for_awk=()
  while IFS=$'\t' read -r f _ _ _; do
    files_for_awk+=("$f")
  done < "$sidecar_file"

  awk -v sidecar="$sidecar_file" -v home="$HOME" -v now="$(date +%s)" '
    BEGIN {
      while ((getline line < sidecar) > 0) {
        split(line, parts, "\t")
        f = parts[1]
        meta_mtime[f] = parts[2]
        meta_size[f]  = parts[3]
        meta_sid[f]   = parts[4]
      }
      close(sidecar)
    }

    # New file: reset state.
    FNR == 1 {
      flush()
      cur = FILENAME
      cwd = ""
      prompt = ""
      title = ""
    }

    !cwd && match($0, /"cwd":"[^"]*"/) {
      cwd = substr($0, RSTART + 7, RLENGTH - 8)
    }

    # Custom title: {"type":"custom-title","customTitle":"...","sessionId":...}
    # Take the LAST occurrence (titles can change), so always overwrite.
    /"type":"custom-title"/ && match($0, /"customTitle":"[^"]*"/) {
      title = substr($0, RSTART + 15, RLENGTH - 16)
    }

    !prompt && /"type":"user"/ {
      i = index($0, "\"content\":\"")
      if (i > 0) {
        s = substr($0, i + 11)
        out = ""
        len_s = length(s)
        for (j = 1; j <= len_s && length(out) < 200; j++) {
          c = substr(s, j, 1)
          if (c == "\\") {
            nc = substr(s, j + 1, 1)
            if      (nc == "n") out = out " "
            else if (nc == "t") out = out " "
            else if (nc == "\"") out = out "\""
            else if (nc == "\\") out = out "\\"
            else                 out = out nc
            j++
            continue
          }
          if (c == "\"") break
          out = out c
        }
        if (out != "" && out !~ /^<command-/ && out !~ /^<local-command-/) {
          prompt = out
        }
      }
    }

    # We cant nextfile early any more — custom-title can appear later in the
    # file. The full read is still cheap thanks to single-process awk.

    END { flush() }

    function flush(   short, max, mtime, size_kb, rel, diff, sid, label) {
      if (cur == "") return
      sid   = meta_sid[cur]
      mtime = meta_mtime[cur]
      size_kb = int((meta_size[cur] + 1023) / 1024) " KB"

      diff = now - mtime
      if      (diff < 60)      rel = diff "s ago"
      else if (diff < 3600)    rel = int(diff / 60) "m ago"
      else if (diff < 86400)   rel = int(diff / 3600) "h ago"
      else if (diff < 604800)  rel = int(diff / 86400) "d ago"
      else if (diff < 2592000) rel = int(diff / 604800) "w ago"
      else                     rel = int(diff / 2592000) "mo ago"

      if (cwd == "") cwd = "(unknown)"
      short = cwd
      if (home != "" && substr(short, 1, length(home) + 1) == home "/") {
        short = "~/" substr(short, length(home) + 2)
      } else if (short == home) {
        short = "~"
      }
      max = 23
      if (length(short) > max) short = "…" substr(short, length(short) - max + 2)
      short = short "/"

      # If a custom title was set (via /name or claude --name), prefix it in
      # bold yellow. Otherwise just show the first user prompt.
      if (title != "") {
        label = "\033[1;33m" title "\033[0m  " prompt
      } else {
        label = prompt
      }
      if (length(label) > 200) label = substr(label, 1, 200)

      printf "%s\t%s\t%s\t\033[36m%-8s\033[0m  \033[32m%-24s\033[0m  \033[36m%8s\033[0m  %s\n", \
        sid, mtime, cwd, rel, short, size_kb, label
    }
  ' "${files_for_awk[@]}"
}

# Bulk stat: prefer a single GNU `stat` call (one fork) over per-file forks.
bulk_stat() {
  if stat -c '%Y	%s	%n' "$@" 2>/dev/null; then return; fi
  stat -f '%m	%z	%N' "$@" 2>/dev/null
}

# Render the preview pane for a given session id.
preview() {
  local sid="$1"
  # Header rows have no SID — render nothing rather than a "not found" error.
  [ -z "$sid" ] && return 0
  local file
  file="$(find "$CLAUDE_PROJECTS_DIR" -maxdepth 2 -name "$sid.jsonl" -print -quit 2>/dev/null)"
  if [ -z "$file" ] || [ ! -f "$file" ]; then
    echo "Session file not found for $sid"
    return 0
  fi

  local cwd title mtime size msg_count
  # Each `|| true` defangs `set -o pipefail`: grep exits non-zero when there
  # are no matches, which would otherwise abort the whole preview.
  cwd="$({ grep -m1 -o '"cwd":"[^"]*"' "$file" || true; } | sed 's/"cwd":"//; s/"$//')"
  title="$({ grep '"type":"custom-title"' "$file" 2>/dev/null || true; } | tail -1 | { grep -o '"customTitle":"[^"]*"' || true; } | sed 's/"customTitle":"//; s/"$//')"
  mtime="$(file_mtime_human "$file")"
  size="$(file_size_bytes "$file")"
  msg_count="$(grep -cE '"type":"(user|assistant)"' "$file" 2>/dev/null || echo 0)"

  if [ -n "$title" ]; then
    printf '\033[1;33mTitle:\033[0m   %s\n' "$title"
  fi
  printf '\033[1mSession:\033[0m %s\n' "$sid"
  printf '\033[1mFolder:\033[0m  %s\n' "${cwd:-unknown}"
  printf '\033[1mLast:\033[0m    %s\n' "$mtime"
  printf '\033[1mSize:\033[0m    %s bytes  (%s msgs)\n\n' "$size" "$msg_count"
  local shown="$PREVIEW_TAIL_MESSAGES"
  [ "$msg_count" -lt "$shown" ] 2>/dev/null && shown="$msg_count"
  if [ "$shown" -lt "$msg_count" ] 2>/dev/null; then
    printf '\033[1m── Last %d of %d messages ──\033[0m\n\n' "$shown" "$msg_count"
  else
    printf '\033[1m── All %d messages ──\033[0m\n\n' "$shown"
  fi

  jq -r --argjson n "$PREVIEW_TAIL_MESSAGES" '
    select(.type == "user" or .type == "assistant")
    | . as $row
    | (.message.content) as $c
    | (
        if   ($c | type) == "string" then $c
        elif ($c | type) == "array"  then
          ($c | map(
            if .type == "text" then .text
            elif .type == "tool_use" then "[tool_use: " + (.name // "?") + "]"
            elif .type == "tool_result" then
              "[tool_result" + (if .is_error then " (error)" else "" end) + "]"
            else "[" + (.type // "?") + "]"
            end
          ) | join("\n"))
        else ""
        end
      ) as $text
    | select(($text | length) > 0)
    | {role: $row.type, text: $text}
  ' "$file" 2>/dev/null \
    | jq -s --argjson n "$PREVIEW_TAIL_MESSAGES" '.[-$n:][]' 2>/dev/null \
    | jq -r '
        # Strip <tag> and </tag> markers but KEEP the content inside.
        # Then collapse extra blank lines that the strip leaves behind, and
        # trim leading whitespace.
        (.text
          | gsub("</?[a-zA-Z][a-zA-Z0-9_-]*[^>]*>"; "")
          | gsub("[ \t]*\n[ \t]*\n[ \t]*\n+"; "\n\n")
          | sub("^\\s+"; "")
        ) as $clean
        | select(($clean | length) > 0)
        | ( if .role == "user" then "[1;32m▶ user[0m"
            else "[1;35m● assistant[0m"
            end ) as $hdr
        | $hdr + "  " + ($clean | .[0:1500]) + "\n"
      '
}

resume_session() {
  local sid="$1"
  local file cwd
  file="$(find "$CLAUDE_PROJECTS_DIR" -maxdepth 2 -name "$sid.jsonl" -print -quit 2>/dev/null)"
  cwd=""
  if [ -n "$file" ]; then
    cwd="$(grep -m1 -o '"cwd":"[^"]*"' "$file" | sed 's/"cwd":"//; s/"$//')"
  fi

  if [ -n "$cwd" ] && [ -d "$cwd" ] && [ "$cwd" != "$(pwd -P)" ]; then
    printf 'cd %s\n' "$cwd" >&2
    cd "$cwd" || return 1
  fi
  exec claude --resume "$sid"
}

rename_session() {
  local sid="$1"
  local file
  file="$(find "$CLAUDE_PROJECTS_DIR" -maxdepth 2 -name "$sid.jsonl" -print -quit 2>/dev/null)"
  if [ -z "$file" ] || [ ! -f "$file" ]; then
    echo "Session file not found for $sid" >&2
    return 1
  fi

  local current
  current="$(grep '"type":"custom-title"' "$file" 2>/dev/null | tail -1 | grep -o '"customTitle":"[^"]*"' | sed 's/"customTitle":"//; s/"$//')"

  printf '\nRename session %s\n' "$sid" >&2
  if [ -n "$current" ]; then
    printf '  current title: %s\n' "$current" >&2
  fi
  printf 'New title (empty = cancel): ' >&2
  local title
  IFS= read -r title </dev/tty || title=""
  if [ -z "$title" ]; then
    echo "Cancelled." >&2
    return 0
  fi

  # JSON-escape: backslash, double-quote, and control chars. We use jq if
  # available (handles every edge case); otherwise a small awk fallback.
  local escaped
  if command -v jq >/dev/null 2>&1; then
    escaped="$(printf '%s' "$title" | jq -Rrs '. | tojson')"
  else
    escaped="$(printf '%s' "$title" | awk '
      BEGIN { printf "\"" }
      {
        s = $0
        gsub(/\\/, "\\\\", s)
        gsub(/"/,  "\\\"", s)
        gsub(/\t/, "\\t",  s)
        printf "%s", s
      }
      END { printf "\"" }
    ')"
  fi

  # Snapshot the original mtime so we can restore it after appending — we
  # don't want a rename to bump the session's "last activity" date.
  local original_mtime
  original_mtime="$(file_mtime_epoch "$file")"

  # Append a custom-title event, the same shape Claude writes when you use
  # /name in-app. Next time the session is loaded, this becomes its title.
  printf '{"type":"custom-title","customTitle":%s,"sessionId":"%s"}\n' \
    "$escaped" "$sid" >> "$file"

  # Restore the original mtime. GNU touch (-d @epoch) and BSD touch (-t)
  # take different formats, so try GNU first then fall back.
  if [ -n "$original_mtime" ] && [ "$original_mtime" != 0 ]; then
    touch -d "@$original_mtime" "$file" 2>/dev/null || \
      touch -t "$(date -r "$original_mtime" +%Y%m%d%H%M.%S 2>/dev/null)" "$file" 2>/dev/null || true
  fi

  printf '\033[1;33mRenamed to: %s\033[0m\n' "$title" >&2
}

delete_sessions() {
  # Resolve every requested SID to an actual file. Anything missing gets
  # mentioned but doesn't block the delete of the others.
  local files=()
  local total_bytes=0
  local sid file size cwd

  # Reserve room for the SID, indent, separator, and a small margin.
  # Width hardcoded at 80 — tput/$COLUMNS/</dev/tty all proved unreliable
  # under our launch paths.
  local title_width=$(( 80 - 42 ))

  printf '\nDelete the following session(s)?\n' >&2
  for sid in "$@"; do
    file="$({ find "$CLAUDE_PROJECTS_DIR" -maxdepth 2 -name "$sid.jsonl" -print -quit 2>/dev/null; } || true)"
    if [ -z "$file" ] || [ ! -f "$file" ]; then
      printf '  \033[31m✗ %s (file not found, skipping)\033[0m\n' "$sid" >&2
      continue
    fi
    size="$(file_size_bytes "$file")"
    cwd="$({ grep -m1 -o '"cwd":"[^"]*"' "$file" || true; } | sed 's/"cwd":"//; s/"$//')"
    local title
    title="$(session_title "$file" "$title_width")"
    printf '  • %s  %s\n' "$sid" "$title" >&2
    files+=("$file")
    total_bytes=$(( total_bytes + size ))
  done

  if [ "${#files[@]}" -eq 0 ]; then
    echo "Nothing to delete." >&2
    return 0
  fi

  if [ "${#files[@]}" -gt 1 ]; then
    printf '  \033[1m(%d sessions, %s bytes total)\033[0m\n' "${#files[@]}" "$total_bytes" >&2
  fi
  printf 'Confirm delete? [Y/n]: ' >&2
  local reply
  IFS= read -r reply </dev/tty || reply=""
  case "$reply" in
    ""|y|Y|yes|YES)
      local f
      for f in "${files[@]}"; do
        trash_file "$f"
      done
      printf '\033[32mDeleted %d session(s).\033[0m\n' "${#files[@]}" >&2
      ;;
    *)
      echo "Cancelled." >&2
      ;;
  esac
}

# Extract a plain-text "title" for a session: custom title (if any) followed
# by the first user prompt. Truncated to $2 visible chars, no ANSI codes.
session_title() {
  local file="$1" max="$2"
  awk -v max="$max" '
    !title && /"type":"custom-title"/ && match($0, /"customTitle":"[^"]*"/) {
      title = substr($0, RSTART + 15, RLENGTH - 16)
    }
    !prompt && /"type":"user"/ {
      i = index($0, "\"content\":\"")
      if (i > 0) {
        s = substr($0, i + 11)
        out = ""
        len_s = length(s)
        for (j = 1; j <= len_s && length(out) < max + 20; j++) {
          c = substr(s, j, 1)
          if (c == "\\") {
            nc = substr(s, j + 1, 1)
            if      (nc == "n") out = out " "
            else if (nc == "t") out = out " "
            else if (nc == "\"") out = out "\""
            else if (nc == "\\") out = out "\\"
            else                 out = out nc
            j++
            continue
          }
          if (c == "\"") break
          out = out c
        }
        if (out != "" && out !~ /^<command-/ && out !~ /^<local-command-/) {
          prompt = out
        }
      }
    }
    title && prompt { exit }
    END {
      label = title
      if (prompt != "") {
        if (label != "") label = label "  " prompt
        else             label = prompt
      }
      if (length(label) > max) label = substr(label, 1, max - 1) "…"
      print label
    }
  ' "$file" 2>/dev/null
}

# Cross-platform stat helpers. Try GNU stat (-c) first; fall back to BSD (-f).
file_mtime_epoch() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

file_size_bytes() {
  stat -c %s "$1" 2>/dev/null || stat -f %z "$1" 2>/dev/null || echo 0
}

file_mtime_human() {
  # GNU first
  local out
  if out="$(stat -c '%y' "$1" 2>/dev/null)"; then
    printf '%s' "${out%%.*}"
    return
  fi
  stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$1" 2>/dev/null
}

# Move to Trash if possible; never use plain rm.
trash_file() {
  local f="$1"
  if   command -v trash >/dev/null 2>&1; then trash "$f"
  elif command -v del   >/dev/null 2>&1; then del   "$f"
  else
    echo "Neither 'trash' nor 'del' is available; refusing to delete." >&2
    return 1
  fi
}

# Dispatch
case "${1:-}" in
  --preview) shift; preview "$@" ;;
  --list)    stream_list "$(pwd -P)" ;;
  -h|--help)
    sed -n '2,12p' "$0"
    ;;
  *) main "$@" ;;
esac
