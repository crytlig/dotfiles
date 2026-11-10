-- Split and focus (outside any mode, for speed)
rex.bind("alt+\\", "pane.split", { direction = "right" })
rex.bind("alt+shift+\\", "pane.split", { direction = "down" })

rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("alt+l", "pane.focus", { direction = "right" })

-- Pane mode: press alt+p, then use plain keys. Leave with enter or escape.
rex.mode("pane", { exclusive = true })
rex.bind("alt+p", "client.mode.enter", { name = "pane" })
rex.bind("pane/enter", "client.mode.exit")

-- Leave pane mode, then run a pane action. Used for one-shot actions,
-- so text fields (rename) and new layouts aren't stuck in the mode.
rex.action{
  name  = "pane_mode_then",
  title = "Leave Pane Mode and Run Action",
  args  = { action = "string" },
  run   = function(ctx, args)
    rex.client.queue("client.mode.exit")
    rex.client.queue(args.action)
  end,
}

-- Resize: hjkl nudges, shift+hjkl jumps
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
rex.bind("pane/r", "pane_mode_then", { action = "pane.rename" })
rex.bind("pane/f", "pane_mode_then", { action = "pane.float" })
rex.bind("pane/t", "pane_mode_then", { action = "pane.move_to_new_tab" })
rex.bind("pane/shift+t", "pane_mode_then", { action = "pane.move_to_tab" })
rex.bind("pane/x>x", "pane_mode_then", { action = "pane.close" })

-- Session shortcuts
rex.bind("shift+cmd+r", "session.rename")
