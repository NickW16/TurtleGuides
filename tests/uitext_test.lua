local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/ui/State.lua",
    "src/ui/Icons.lua",
    "src/ui/Text.lua"
  )
end

return {
  test_text_element_preserves_colors = function()
    local TG = fresh()
    env.eq(TG.UI.Text.element({ t = "text", text = "|cffff0000Hello|r world" }), "|cffff0000Hello|r world")
  end,

  test_accept_and_collect_elements = function()
    local TG = fresh()
    env.eq(TG.UI.Text.element({ t = "cmd", tag = "accept", args = { "1" }, text = "Accept Foo" }), "Accept Foo")
    TG.GetItemCount = function()
      return 2
    end
    TG.GetItemNameById = function()
      return "Bear Fur"
    end
    env.eq(
      TG.UI.Text.element({ t = "cmd", tag = "collect", args = { "42", "5" }, text = "Bear Fur" }),
      "Collect: |cffffd100Bear Fur|r 2/5"
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

  test_child_item_lines_are_marked = function()
    local TG = fresh()
    local step = {
      elements = {
        {
          t = "cmd",
          tag = "bankwithdraw",
          args = { "10445", "10444" },
          text = "Withdraw the following items from your bank:",
        },
        { t = "text", text = "[Standard Issue Flare Gun]" },
        { t = "text", text = "[Drawing Kit]" },
      },
    }
    local entries = TG.UI.Text.entries(step)
    env.eq(entries[1].bulletIcon, true)
    env.eq(entries[2].child, true)
    env.eq(entries[3].child, true)
  end,

  test_automation_only_steps_get_a_label = function()
    local TG = fresh()
    local destroyed = TG.UI.Text.entries({ elements = { { t = "cmd", tag = "destroy", args = { "6948" } } } })
    env.eq(string.find(destroyed[1].text or "", "Destroy:", 1, true) ~= nil, true)
    local gotoStep =
      TG.UI.Text.entries({ elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "30", "70" } } } })
    env.eq(gotoStep[1].text, "Go to Dun Morogh")
  end,

  test_wrap_counts_lines = function()
    local TG = fresh()
    local wrapped, lines = TG.UI.Text.wrap("one two three four five six seven eight", 30, 9)
    env.eq(string.find(wrapped, "\n") ~= nil, true)
    env.eq(lines > 1, true)
  end,
}
