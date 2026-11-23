-- TMUX-STYLE PREFIX --
-- Press ctrl+b, then a key. The mode leaves after one of its keys runs
-- (once = true), like tmux's prefix. Escape cancels.
rex.mode("tmux", { exclusive = true })
rex.bind("ctrl+b", "client.mode.enter", { name = "tmux", once = true })
rex.bind("tmux/escape", "client.mode.exit")

-- A tmux "window" is a Rex tab
rex.bind("tmux/c", "client.tab.new")

-- ctrl+b 1..9 selects tab 1..9, ctrl+b 0 selects the last tab
for i = 1, 9 do
  rex.bind("tmux/" .. i, "client.tab.goto", { index = i })
end
rex.bind("tmux/0", "client.tab.goto", { index = -1 })

