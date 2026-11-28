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
    "src/engine/QuestDiff.lua",
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

  test_item_stat_skips_step_when_equipped_gear_is_better = function()
    local TG = fresh()
    _G.GetInventoryItemLink = function(_, slot)
      if slot == 18 then
        return "|Hitem:3027::::::::::::|h[Bow]|h"
      end
      return nil
    end
    _G.GetItemStats = function()
      return { ITEM_MOD_DAMAGE_PER_SECOND_SHORT = 12.0 }
    end
    local step = {
      elements = {
        { t = "cmd", tag = "itemStat", args = { "18", "ITEM_MOD_DAMAGE_PER_SECOND_SHORT", "<9.20" } },
      },
    }
    env.eq(TG:EvaluateConditions(step), false)
    env.eq(TG:StepSkipState(step), true)
  end,

  test_item_stat_holds_step_when_equipped_gear_is_worse = function()
    local TG = fresh()
    _G.GetInventoryItemLink = function(_, slot)
      if slot == 18 then
        return "|Hitem:3027::::::::::::|h[Bow]|h"
      end
      return nil
    end
    _G.GetItemStats = function()
      return { ITEM_MOD_DAMAGE_PER_SECOND_SHORT = 5.0 }
    end
    local step = {
      elements = {
        { t = "cmd", tag = "itemStat", args = { "18", "ITEM_MOD_DAMAGE_PER_SECOND_SHORT", "<9.20" } },
      },
    }
    env.eq(TG:EvaluateConditions(step), true)
  end,

  test_item_stat_level_uses_item_level = function()
    local TG = fresh()
    _G.GetInventoryItemLink = function(_, slot)
      if slot == 10 then
        return "|Hitem:1234::::::::::::|h[Gloves]|h"
      end
      return nil
    end
    _G.GetItemInfo = function()
      return "Gloves", "|Hitem:1234::::::::::::|h[Gloves]|h", 2, 15
    end
    local step = { elements = { { t = "cmd", tag = "itemStat", args = { "10", "LEVEL", "<20" } } } }
    env.eq(TG:EvaluateConditions(step), true)
    step.elements[1].args[3] = "<10"
    env.eq(TG:EvaluateConditions(step), false)
  end,

  test_item_stat_unknown_holds_step = function()
    local TG = fresh()
    _G.GetInventoryItemLink = function()
      return "|Hitem:3027::::::::::::|h[Bow]|h"
    end
    local step = {
      elements = {
        { t = "cmd", tag = "itemStat", args = { "18", "ITEM_MOD_DAMAGE_PER_SECOND_SHORT", "<9.20" } },
      },
    }
    env.eq(TG:EvaluateConditions(step), nil)
    env.eq(TG:StepConditionsMet(step), true)
  end,

  test_equip_condition_tracks_equipped_item = function()
    local TG = fresh()
    _G.GetInventoryItemID = function(_, slot)
      if slot == 18 then
        return 3027
      end
      return nil
    end
    local step = { elements = { { t = "cmd", tag = "equip", args = { "18", "3027" } } } }
    env.eq(TG:EvaluateConditions(step), false)
    step.elements[1].args[2] = "9999"
    env.eq(TG:EvaluateConditions(step), true)
    step.elements[1].args = { "18" }
    env.eq(TG:EvaluateConditions(step), false)
    _G.GetInventoryItemID = function()
      return nil
    end
    env.eq(TG:EvaluateConditions(step), true)
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

  test_hearthstone_cooldown_skips_step = function()
    local TG = fresh()
    _G.GetTime = function()
      return 200
    end
    _G.GetItemCooldown = function()
      return 100, 3600
    end
    local step = {
      elements = { { t = "cmd", tag = "cooldown", args = { "item", "6948", ">0", "1" } } },
    }
    env.eq(TG:EvaluateConditions(step), false)
    env.eq(TG:StepSkipState(step), true)
  end,

  test_ready_hearthstone_keeps_step = function()
    local TG = fresh()
    _G.GetTime = function()
      return 3701
    end
    _G.GetItemCooldown = function()
      return 100, 3600
    end
    local step = {
      elements = { { t = "cmd", tag = "cooldown", args = { "item", "6948", ">0", "1" } } },
    }
    env.eq(TG:EvaluateConditions(step), true)
    env.eq(TG:StepSkipState(step), false)
  end,

  test_item_cooldown_falls_back_to_bag_scan = function()
    local TG = fresh()
    _G.GetTime = function()
      return 200
    end
    _G.GetContainerNumSlots = function(bag)
      return bag == 0 and 1 or 0
    end
    _G.GetContainerItemLink = function()
      return "|Hitem:6948::::::::::::|h[Hearthstone]|h"
    end
    _G.GetContainerItemCooldown = function()
      return 100, 3600
    end
    local step = {
      elements = { { t = "cmd", tag = "cooldown", args = { "item", "6948", ">0", "1" } } },
    }
    env.eq(TG:EvaluateConditions(step), false)
    env.eq(TG:StepSkipState(step), true)
  end,

  test_hardcore_mode_skips_softcore_step = function()
    local TG = fresh()
    TG.db = { hardcoreMode = true }
    local step = { elements = {}, tags = { softcore = true } }
    env.eq(TG:StepSkipState(step), true)
    env.eq(TG:ShouldAutoSkipStep(step), true)
  end,

  test_softcore_step_is_kept_without_hardcore_mode = function()
    local TG = fresh()
    TG.db = {}
    local step = { elements = {}, tags = { softcore = true } }
    env.eq(TG:StepSkipState(step), false)
    env.eq(TG:ShouldAutoSkipStep(step), false)
  end,

  test_multi_id_on_quest_uses_any_id = function()
    local TG = fresh()
    _G.GetTime = function()
      return 10
    end
    TG._recentAccept[3364] = 10
    local step = {
      elements = { { t = "cmd", tag = "isOnQuest", args = { "218", "3364" }, questIds = { 218, 3364 } } },
    }
    env.eq(TG:EvaluateConditions(step), true)
    env.eq(TG:StepSkipState(step), false)
  end,

  test_is_not_on_quest_inverts_multi_id_result = function()
    local TG = fresh()
    _G.GetTime = function()
      return 10
    end
    _G.GetNumQuestLogEntries = function()
      return 1
    end
    _G.GetQuestLogTitle = function()
      return "Other Quest", 1, nil, false, false, nil, nil, 999
    end
    local step = {
      elements = { { t = "cmd", tag = "isNotOnQuest", args = { "218", "3364" }, questIds = { 218, 3364 } } },
    }
    env.eq(TG:EvaluateConditions(step), true)
    TG._recentAccept[218] = 10
    env.eq(TG:EvaluateConditions(step), false)
  end,

  test_reverse_flag_inverts_quest_condition = function()
    local TG = fresh()
    TG.cdb = {}
    TG:MarkQuestTurnedIn(414)
    local step = {
      elements = { { t = "cmd", tag = "isQuestTurnedIn", args = { "414" }, questIds = { 414 }, reverse = true } },
    }
    env.eq(TG:EvaluateConditions(step), false)
    env.eq(TG:StepSkipState(step), true)
  end,

  test_unknown_quest_gate_times_out_into_skip = function()
    local TG = fresh()
    local now = 0
    _G.GetTime = function()
      return now
    end
    _G.GetNumQuestLogEntries = function()
      error("unavailable")
    end
    local step = {
      index = 7,
      elements = { { t = "cmd", tag = "isOnQuest", args = { "99" }, questIds = { 99 } } },
    }
    TG.currentGuide = { key = "Test||Guide", steps = { step } }
    env.eq(TG:StepSkipState(step), nil)
    now = TG.Engine.Shared.UNKNOWN_STATE_TIMEOUT + 1
    env.eq(TG:StepSkipState(step), true)
    env.eq(step.stepSkip, true)
    env.eq(string.find(tostring(step.stepSkipReason), "timed out", 1, true) ~= nil, true)
  end,

  test_unknown_zone_gate_times_out_without_skipping = function()
    local TG = fresh()
    local now = 0
    _G.GetTime = function()
      return now
    end
    local step = {
      index = 8,
      elements = { { t = "cmd", tag = "zoneskip", args = { "Dun Morogh" } } },
    }
    TG.currentGuide = { key = "Test||Guide", steps = { step } }
    env.eq(TG:StepSkipState(step), nil)
    now = TG.Engine.Shared.UNKNOWN_STATE_TIMEOUT + 1
    env.eq(TG:StepSkipState(step), false)
    env.eq(step.stepSkip, false)
  end,
}
