-- TMUX-STYLE PREFIX --
-- Press ctrl+b, then a key. The mode leaves after one of its keys runs
-- (once = true), like tmux's prefix. Escape cancels.
rex.mode("tmux", { exclusive = true })
rex.bind("ctrl+b", "client.mode.enter", { name = "tmux", once = true })
rex.bind("tmux/escape", "client.mode.exit")

-- A tmux "window" is a Rex tab
rex.bind("tmux/c", "client.tab.new")
