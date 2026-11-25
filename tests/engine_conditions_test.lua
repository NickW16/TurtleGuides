local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/compat/ZoneData.lua",
    "src/compat/Zone.lua",
    "src/compat/QuestLog.lua",
    "src/compat/Item.lua",
    "src/core/Output.lua",
    "src/core/State.lua",
    "src/engine/State.lua",
    "src/engine/Quests.lua",
    "src/engine/Conditions.lua"
  )
end

return {
  test_item_count_condition_met = function()
    local TG = fresh()
    _G.GetContainerNumSlots = function()
      return 1
    end
    _G.GetContainerItemLink = function()
      return "|Hitem:42::::::::::::|h[x]|h"
    end
    _G.GetContainerItemInfo = function()
      return nil, 2
    end
    local step = { elements = { { t = "cmd", tag = "itemcount", args = { "42", "2" } } } }
    env.eq(TG:EvaluateConditions(step), true)
    env.eq(TG:StepConditionsMet(step), true)
  end,

  test_unreadable_condition_holds_step = function()
    local TG = fresh()
    _G.GetNumQuestLogEntries = function()
      error("unavailable")
    end
    local step = { elements = { { t = "cmd", tag = "isOnQuest", args = { "99" } } } }
    env.eq(TG:EvaluateConditions(step), nil)
    env.eq(TG:StepConditionsMet(step), true)
  end,

  test_zone_skip_uses_current_zone = function()
    local TG = fresh()
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    local step = { elements = { { t = "cmd", tag = "zoneskip", args = { "Dun Morogh" } } } }
    env.eq(TG:ShouldSkipStepByZone(step), true)
    env.eq(TG:StepSkipState(step), true)
  end,

  test_unknown_zone_holds_step = function()
    local TG = fresh()
    local step = { elements = { { t = "cmd", tag = "zoneskip", args = { "Dun Morogh" } } } }
    env.eq(TG:ShouldSkipStepByZone(step), nil)
    env.eq(TG:StepSkipState(step), nil)
  end,

  test_stock_client_quest_condition_holds = function()
    local TG = fresh()
    _G.GetNumQuestLogEntries = function()
      return 1
    end
    _G.GetQuestLogTitle = function()
      return "Foo", 1, nil, false, false, nil
    end
    local step = { elements = { { t = "cmd", tag = "isOnQuest", args = { "99" } } } }
    env.eq(TG:EvaluateConditions(step), nil)
  end,

  test_numeric_zone_skip_resolves_pfdb_id = function()
    local TG = fresh()
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.pfDB = { zones = { loc = { [228] = "Dun Morogh" } } }
    local step = { elements = { { t = "cmd", tag = "zoneskip", args = { "228" } } } }
    env.eq(TG:ShouldSkipStepByZone(step), true)
    env.eq(TG:StepSkipState(step), true)
  end,

  test_unknown_numeric_zone_holds_step = function()
    local TG = fresh()
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    local step = { elements = { { t = "cmd", tag = "zoneskip", args = { "999999" } } } }
    env.eq(TG:ShouldSkipStepByZone(step), nil)
    env.eq(TG:StepSkipState(step), nil)
  end,

  test_expired_xp_cap_step_is_skipped = function()
    local TG = fresh()
    _G.UnitLevel = function()
      return 8
    end
    local step = { elements = { { t = "cmd", tag = "xp", args = { "<8", "1" } } } }
    env.eq(TG:EvaluateConditions(step), false)
    env.eq(TG:StepSkipState(step), true)
    env.eq(TG:ShouldAutoSkipStep(step), true)
  end,

  test_active_xp_cap_step_is_not_skipped = function()
    local TG = fresh()
    _G.UnitLevel = function()
      return 7
    end
    local step = { elements = { { t = "cmd", tag = "xp", args = { "<8", "1" } } } }
    env.eq(TG:EvaluateConditions(step), true)
    env.eq(TG:StepSkipState(step), false)
    env.eq(TG:ShouldAutoSkipStep(step), false)
  end,

  test_xp_grind_goal_is_not_a_skip_gate = function()
    local TG = fresh()
    _G.UnitLevel = function()
      return 7
    end
    local step = { elements = { { t = "cmd", tag = "xp", args = { ">8" } } } }
    env.eq(TG:EvaluateConditions(step), true)
    env.eq(TG:StepSkipState(step), false)
  end,
}
