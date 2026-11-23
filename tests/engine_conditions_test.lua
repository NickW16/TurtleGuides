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
}
