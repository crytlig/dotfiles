#!/usr/bin/env bash

set -euo pipefail
#
# Firefox window titles use the format:
#   [page title] — [profile name] — Mozilla Firefox
# The em-dash (U+2014) is the separator between segments.
EM=$'\u2014'

WORKSPACES=(
    "1|herdr|herdr"
    "2|slack|flatpak|com.slack.Slack"
    "3|cvation|firefox|cvation.Profile|cvation|https://outlook.cloud.microsoft/mail/|https://teams.microsoft.com"
    "4|skaylink|firefox|skaylink.Profile|Skaylink|https://outlook.cloud.microsoft/mail/|https://teams.cloud.microsoft"
    "5|pundl|firefox|pfeiferundlangen.Profile|P&L ${EM} Mozilla Firefox|https://outlook.office.com/mail/|https://teams.microsoft.com"
)

PROFILE_DIR="$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"

NIRI="${NIRI:-$(command -v niri || echo /usr/bin/niri)}"
JQ="${JQ:-$(command -v jq || echo /usr/bin/jq)}"

FF="flatpak"

# herdr is installed via mise; resolve it explicitly since the niri session
# PATH may not include mise shims.
if command -v herdr >/dev/null 2>&1; then
    HERDR="$(command -v herdr)"
else
    HERDR="$HOME/.local/share/mise/installs/github-herdrdev-herdr/latest/herdr"
fi
#
# Returns 0 if a workspace with the given name exists, 1 otherwise.
workspace_exists() {
    local name="$1"
    "$NIRI" msg -j workspaces | "$JQ" -e --arg name "$name" '.[] | select(.name == $name)' > /dev/null 2>&1
}

# Ensure the given workspace index exists with the given name.
# If a workspace with that name already exists elsewhere, we skip creation.
ensure_workspace() {
    local index="$1"
    local name="$2"

    if workspace_exists "$name"; then
        echo "✓ workspace '$name' (index $index) already exists"
        return
    fi

    echo "→ creating workspace '$name' at index $index…"
    "$NIRI" msg action focus-workspace "$index"
    "$NIRI" msg action set-workspace-name --workspace "$index" "$name"
}

# ────────────────────────────────────────────────────────────────
#  APP LAUNCHING
# ────────────────────────────────────────────────────────────────

# Returns 0 if a window with the given app_id (and optional title regex)
# exists on the workspace, 1 otherwise.
window_exists() {
    local workspace_id="$1"
    local app_id="$2"
    local title_regex="${3:-}"

    local filter
    if [ -n "$title_regex" ]; then
        filter=".[] | select(.workspace_id==$workspace_id and .app_id==\"$app_id\" and (.title | test(\"$title_regex\")))"
    else
        filter=".[] | select(.workspace_id==$workspace_id and .app_id==\"$app_id\")"
    fi

    local win_id
    win_id=$("$NIRI" msg -j windows | "$JQ" -r "$filter | .id" | head -1)
    [ -n "$win_id" ]
}

# Wait (poll) until the expected window appears on the workspace.
# niri places a spawned window on the workspace that is focused when the
# window MAPS, not when spawn was requested — so we must not change focus
# until the window is confirmed on the target workspace.
# Returns 0 on success, 1 on timeout.
wait_for_window() {
    local workspace_id="$1" app_id="$2" title_regex="${3:-}" timeout="${4:-30}"
    local waited=0
    while [ "$waited" -lt "$timeout" ]; do
        if window_exists "$workspace_id" "$app_id" "$title_regex"; then
            return 0
        fi
        sleep 1
        waited=$((waited + 1))
    done
    return 1
}

# Spawn the app for one workspace; skip if it is already present there.
ensure_app() {
    local workspace_id="$1"
    local kind="$2"
    shift 2

    case "$kind" in
        herdr)
            if [ ! -x "$HERDR" ]; then
                echo "  ! herdr binary not found at '$HERDR' — skipping"
                return
            fi
            if window_exists "$workspace_id" com.mitchellh.ghostty; then
                echo "  → ghostty + herdr already present — skipping"
                return
            fi
            echo "  → opening ghostty + herdr…"
            "$NIRI" msg action spawn -- ghostty -e "$HERDR"
            if ! wait_for_window "$workspace_id" com.mitchellh.ghostty; then
                echo "  ! ghostty did not appear on this workspace — check manually"
            fi
            DID_SPAWN=1
            ;;
        flatpak)
            local app_id="${1:-}"
            if window_exists "$workspace_id" "$app_id"; then
                echo "  → $app_id already present — skipping"
                return
            fi
            echo "  → opening $app_id…"
            "$NIRI" msg action spawn -- "$FF" run "$app_id"
            if ! wait_for_window "$workspace_id" "$app_id"; then
                echo "  ! $app_id did not appear on this workspace — check manually"
            fi
            DID_SPAWN=1
            ;;
        firefox)
            local profile_symlink="${1:-}" title_regex="${2:-}" outlook_url="${3:-}" teams_url="${4:-}"
            if window_exists "$workspace_id" org.mozilla.firefox "$title_regex"; then
                echo "  → Firefox ($profile_symlink) already present — skipping"
                return
            fi
            echo "  → opening $profile_symlink Outlook + Teams…"
            # Single spawn: --new-window + --new-tab atomically, avoiding the
            # race of separate --new-tab calls.
            "$NIRI" msg action spawn -- \
                "$FF" run org.mozilla.firefox \
                "--profile" "$PROFILE_DIR/$profile_symlink" \
                "--new-window" "$outlook_url" \
                "--new-tab" "$teams_url"
            if ! wait_for_window "$workspace_id" org.mozilla.firefox "$title_regex"; then
                echo "  ! $profile_symlink did not appear on this workspace — it may have merged into an existing instance"
            fi
            DID_SPAWN=1
            ;;
        *)
            echo "  ! unknown kind '$kind' — skipping" >&2
            ;;
    esac
}

# ────────────────────────────────────────────────────────────────
#  MAIN
# ────────────────────────────────────────────────────────────────

DID_SPAWN=0
for entry in "${WORKSPACES[@]}"; do
    IFS='|' read -r -a fields <<< "$entry"
    index="${fields[0]}"
    name="${fields[1]}"
    kind="${fields[2]}"

    ensure_workspace "$index" "$name"

    # Focus by name so the app lands on the named workspace even if it
    # already existed at a different index.
    "$NIRI" msg action focus-workspace "$name"
    workspace_id=$("$NIRI" msg -j workspaces | "$JQ" -r --arg name "$name" '.[] | select(.name==$name) | .id' | head -1)

    echo "→ $name:"
    ensure_app "$workspace_id" "$kind" "${fields[@]:3}"
done

# Land on the primary workspace (herdr terminal).
"$NIRI" msg action focus-workspace herdr

if [ "$DID_SPAWN" -eq 1 ]; then
    echo "→ Done. Switch workspaces with Mod+1 … Mod+5."
else
    echo "→ Done. All workspaces already set up."
fi
