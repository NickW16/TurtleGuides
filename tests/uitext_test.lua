local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/core/Util.lua", "src/compat/Text.lua", "src/ui/State.lua", "src/ui/Text.lua")
end

return {
  test_text_element_strips_colors = function()
    local TG = fresh()
    env.eq(TG.UI.Text.element({ t = "text", text = "|cffff0000Hello|r world" }), "Hello world")
  end,

  test_accept_and_collect_elements = function()
    local TG = fresh()
    env.eq(TG.UI.Text.element({ t = "cmd", tag = "accept", args = { "1" }, text = "Accept Foo" }), "Accept: Foo")
    TG.GetItemCount = function()
      return 2
    end
    TG.GetItemNameById = function()
      return "Bear Fur"
    end
    env.eq(
      TG.UI.Text.element({ t = "cmd", tag = "collect", args = { "42", "5" }, text = "Bear Fur" }),
      "Collect: Bear Fur 2/5"
    )
  end,

  test_plain_goto_is_hidden_when_step_has_tasks = function()
    local TG = fresh()
    local step = {
      elements = {
        { t = "cmd", tag = "goto", args = { "1", "2", "3" } },
        { t = "text", text = "Talk to the innkeeper" },
      },
    }
    local entries = TG.UI.Text.entries(step)
    env.eq(table.getn(entries), 1)
    env.eq(entries[1].text, "Talk to the innkeeper")
  end,

  test_wrap_counts_lines = function()
    local TG = fresh()
    local wrapped, lines = TG.UI.Text.wrap("one two three four five six seven eight", 30, 9)
    env.eq(string.find(wrapped, "\n") ~= nil, true)
    env.eq(lines > 1, true)
  end,
}
