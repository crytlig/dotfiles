
-- Split and focus (outside any mode, for speed)
rex.bind("alt+\\", "pane.split", { direction = "right" })
rex.bind("alt+shift+\\", "pane.split", { direction = "down" })

rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("alt+l", "pane.focus", { direction = "right" })


-- PANES CONFIG --
-- Pane mode: press alt+p, then use plain keys. Leave with enter or escape.
rex.mode("pane", { exclusive = true })
rex.bind("alt+p", "client.mode.enter", { name = "pane" })
rex.bind("pane/enter", "client.mode.exit")

-- Leave pane mode, then run a pane action. Used for one-shot actions,
-- so text fields (rename) and new layouts aren't stuck in the mode.
rex.action{
  name  = "pane_mode_then",
  title = " ",
  args  = { action = "string" },
  run   = function(ctx, args)
    rex.client.queue("client.mode.exit")
    rex.client.queue(args.action)
  end,
}

-- Resize
rex.bind("pane/h", "pane.resize", { amount = 3, direction = "left" })
rex.bind("pane/j", "pane.resize", { amount = 3, direction = "down" })
rex.bind("pane/k", "pane.resize", { amount = 3, direction = "up" })
rex.bind("pane/l", "pane.resize", { amount = 3, direction = "right" })

-- Move the pane within the layout
rex.bind("pane/ctrl+h", "pane.move.left")
rex.bind("pane/ctrl+j", "pane.move.down")
rex.bind("pane/ctrl+k", "pane.move.up")
rex.bind("pane/ctrl+l", "pane.move.right")

-- Layout tweaks (stay in the mode)
rex.bind("pane/=", "pane.balance")
rex.bind("pane/z", "pane.zoom")

-- One-shot actions (leave the mode first)
rex.bind("pane/r", "pane_mode_then", { action = "pane.rename"})
rex.bind("pane/f", "pane_mode_then", { action = "pane.float" })
rex.bind("pane/t", "pane_mode_then", { action = "pane.move_to_new_tab" })
rex.bind("pane/shift+t", "pane_mode_then", { action = "pane.move_to_tab" })
rex.bind("pane/x>x", "pane_mode_then", { action = "pane.close" })

-- Session shortcuts
rex.bind("shift+cmd+r", "session.rename")

-- New session, then open the rename prompt so it gets a real name
-- instead of a generated one.
rex.action{
  name  = "session_new_named",
  title = "New Named Session",
  run   = function(ctx)
    -- The client's session.rename prompt targets whichever session the app
    -- shows, and the switch to a new session lands too late for it. So
    -- instead the new session opens with a small floating prompt that
    -- renames the session itself by ID and then closes.
    local created = rex.call("session.create", {
      initial_windows = {
        { layout = { block = { flavor = "com.superlogical.terminal.shell" } } },
      },
    })
    local sid = created.session_id
    -- Required before adding blocks to a session we didn't start in.
    rex.call("session.attach", { session_id = sid })
    local prev = (ctx and ctx.session_id) or ""
    -- zsh line editor reading one key at a time, so escape can cancel:
    -- enter = keep name (empty keeps the generated one),
    -- escape / ctrl+c = go back to the previous session and delete this one.
    local script = [=[
sid=$1 prev=$2 name=
cancel() {
  [[ -n $prev ]] && rex do session.select session_id="$prev" >/dev/null 2>&1
  rex kill "$sid" >/dev/null 2>&1
  exit 0
}
trap cancel INT
printf 'Session name: '
while read -rsk1 c; do
  case $c in
    $'\n'|$'\r') break ;;
    $'\e')
      # A lone escape cancels; arrow keys etc. send more bytes right after.
      if read -rsk1 -t 0.05 c; then
        while read -rsk1 -t 0.01 c; do :; done
        continue
      fi
      cancel ;;
    $'\x03') cancel ;;
    $'\x7f'|$'\b') [[ -n $name ]] && { name=${name%?}; printf '\b \b'; } ;;
    [[:print:]]) name+=$c; printf '%s' "$c" ;;
  esac
done
[[ -n $name ]] && rex session rename "$sid" "$name" >/dev/null
]=]
    rex.call("session.new_layer", {
      session_id = sid,
      bounds     = { 0.25, 0.4, 0.5, 0.12 },
      focus      = true,
      layout     = { block = {
        flavor  = "com.superlogical.terminal.shell",
        label   = "name session",
        options = { command = { "zsh", "-fc", script, "zsh", sid, prev } },
      } },
    })
    rex.client.queue("session.select", { session_id = sid })
  end,
}
rex.bind("shift+cmd+n", "session_new_named")
