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
  test_wrap_preserves_icon_gap = function()
    local TG = fresh()
    env.eq(TG.UI.Text.wrap("[Hearthstone]    from your bag", 400, 10), "[Hearthstone]    from your bag")
  end,

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
      "Collect: |cffffd100Bear Fur|r  2/5"
    )
  end,

  test_complete_objective_shows_live_progress_and_pending_checkbox = function()
    local TG = fresh()
    TG.ResolveQuestTitle = function()
      return "A Favor for Evershine", 319
    end
    TG.GetQuestObjectives = function()
      return { [1] = { text = "Ice Claw Bear slain: 2/6", done = false } }
    end
    TG.IsElementTrackable = function()
      return true
    end
    TG.IsElementDone = function()
      return false
    end
    local step = {
      elements = { { t = "cmd", tag = "complete", args = { "319", "1" }, objectiveText = "Kill Ice Claw Bear (x6)" } },
    }
    local entries = TG.UI.Text.entries(step)
    env.eq(entries[1].text, "Kill Ice Claw Bear (2/6)")
    env.eq(entries[1].state, false)
    env.eq(entries[1].icon, nil)
    env.eq(entries[1].bulletIcon, false)
  end,

  test_complete_objective_falls_back_to_zero_progress = function()
    local TG = fresh()
    TG.ResolveQuestTitle = function()
      return nil, 319
    end
    TG.GetQuestObjectivesById = function()
      return nil
    end
    local el = { t = "cmd", tag = "complete", args = { "319", "2" }, objectiveText = "Kill Elder Crag Boar (x8)" }
    env.eq(TG.UI.Text.element(el), "Kill Elder Crag Boar (0/8)")
  end,

  test_complete_item_objective_shows_bag_progress = function()
    local TG = fresh()
    TG.GetObjectiveItemProgress = function()
      return 19, 6
    end
    local el = {
      t = "cmd",
      tag = "complete",
      args = { "384", "1" },
      objectiveText = "Collect Crag Boar Rib (x6)",
    }
    env.eq(TG.UI.Text.element(el), "Collect Crag Boar Rib (6/6)")
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

  test_completewith_step_shows_goto_label_with_other_text = function()
    local TG = fresh()
    local step = {
      completewith = true,
      elements = {
        {
          t = "cmd",
          tag = "goto",
          args = { "Dun Morogh", "34.577", "51.652" },
          text = "Travel toward Tundra MacGrann",
        },
        { t = "text", text = "Kill Boars, Bears and Wolves en-route" },
      },
    }
    local entries = TG.UI.Text.entries(step)
    env.eq(table.getn(entries), 2)
    env.eq(entries[1].text, "Travel toward Tundra MacGrann")
    env.eq(entries[2].text, "Kill Boars, Bears and Wolves en-route")
  end,

  test_completewith_step_dedupes_matching_goto_label = function()
    local TG = fresh()
    local step = {
      completewith = true,
      elements = {
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "34", "51" }, text = "Travel to Brewnall" },
        { t = "text", text = "Travel to Brewnall" },
      },
    }
    local entries = TG.UI.Text.entries(step)
    env.eq(table.getn(entries), 1)
    env.eq(entries[1].text, "Travel to Brewnall")
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

  test_wrap_does_not_split_color_codes = function()
    local TG = fresh()
    local wrapped, lines = TG.UI.Text.wrap("|cffffd100Supercalifragilisticexpialidocious|r", 30, 9)
    env.eq(lines > 1, true)
    env.eq(string.find(wrapped, "|cff", 1, true), nil)
    env.eq(string.find(wrapped, "|r", 1, true), nil)
  end,
}
