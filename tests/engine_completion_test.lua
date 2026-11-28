local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_manual_override_wins = function()
    local TG = loadEngine()
    local el = { t = "cmd", tag = "accept", _tgManualDone = true }
    env.eq(TG:IsElementDone(el), true)
    env.eq(TG._tgDoneSource, "manual checkbox")
  end,

  test_only_step_requirements_are_trackable = function()
    local TG = loadEngine()
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "collect", args = { "1", "1" } }), true)
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "accept", args = { "1" } }), true)
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "turnin", args = { "1" } }), true)
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "complete", args = { "1", "1" } }), true)
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "xp", args = { "10" } }), true)
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "use", args = { "1" } }), true)
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "vendor" }), true)
    env.eq(TG:IsElementTrackable({ t = "cmd", tag = "goto", args = { "Dun Morogh", "1", "2" } }), false)
    env.eq(TG:IsElementTrackable({ t = "text", text = "Buy some meat" }), false)
    env.eq(TG:IsElementTrackable({ t = "text", text = "Talk to |cRXP_FRIENDLY_Bob|r" }), false)
    env.eq(TG:IsElementTrackable({ t = "text", text = "Kill |cRXP_ENEMY_Bob|r" }), false)
    env.eq(TG:IsElementTrackable({ t = "text", text = "Loot |T134172:0|t[Snout]" }), false)
    local el = { t = "cmd", tag = "collect", args = { "1", "1" }, _tgNoCheckbox = true }
    env.eq(TG:IsElementTrackable(el), false)
  end,

  test_all_manually_checked_elements_complete_step = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "text", text = "Kill |cRXP_ENEMY_the crawlers|r." },
        { t = "cmd", tag = "collect", args = { "769", "6" } },
      },
    }
    env.eq(TG:IsStepComplete(step), false)
    env.eq(TG:IsElementTrackable(step.elements[1]), false)
    step.elements[1]._tgManualDone = true
    env.eq(TG:IsStepComplete(step), false)
    step.elements[2]._tgManualDone = true
    env.eq(TG:IsStepComplete(step), true)
  end,

  test_collect_uses_bag_count = function()
    local TG = loadEngine()
    _G.GetContainerNumSlots = function()
      return 1
    end
    _G.GetContainerItemLink = function()
      return "|Hitem:42::::::::::::|h[x]|h"
    end
    _G.GetContainerItemInfo = function()
      return nil, 2
    end
    env.eq(TG:IsElementDone({ t = "cmd", tag = "collect", args = { "42", "2" } }), true)
  end,

  test_quest_starter_collect_and_use_complete_when_accepted = function()
    local TG = loadEngine()
    local use = { t = "cmd", tag = "use", args = { "1972" } }
    local collect = { t = "cmd", tag = "collect", args = { "1972", "1", "184" }, questIds = { 184 } }
    local accept = { t = "cmd", tag = "accept", args = { "184" }, questIds = { 184 } }
    local step = { elements = { use, collect, accept } }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.GetQuestEvidence = function(_, id)
      if tonumber(id) == 184 then
        return { id = 184, inLog = true, complete = false, turnedIn = false }
      end
      return nil
    end
    env.eq(TG:IsElementDone(accept), true)
    env.eq(TG:IsElementDone(collect), true)
    env.eq(TG:IsStepComplete(step), true)
  end,

  test_quest_starter_text_use_in_next_step_satisfies_collect = function()
    local TG = loadEngine()
    local collect = { t = "cmd", tag = "collect", args = { "1972", "1", "184" }, questIds = { 184 } }
    local useText = { t = "text", text = "Use the |T134939:0|t[Westfall Deed] to start the quest" }
    local accept = { t = "cmd", tag = "accept", args = { "184" }, questIds = { 184 } }
    TG.currentGuide = { key = "k", steps = { { elements = { collect } }, { elements = { useText, accept } } } }
    TG.currentStepIndex = 1
    TG.GetItemNameById = function(_, id)
      if tonumber(id) == 1972 then
        return "Westfall Deed"
      end
      return nil
    end
    TG.GetQuestEvidence = function(_, id)
      if tonumber(id) == 184 then
        return { id = 184, inLog = true, complete = false, turnedIn = false }
      end
      return nil
    end
    TG.GetItemCount = function()
      return 0
    end
    env.eq(TG:IsElementDone(collect), true)
  end,

  test_collect_without_use_stays_open_after_accept = function()
    local TG = loadEngine()
    local collect = { t = "cmd", tag = "collect", args = { "769", "50", "2178" }, questIds = { 2178 } }
    local accept = { t = "cmd", tag = "accept", args = { "2178" }, questIds = { 2178 } }
    local step = { elements = { collect, accept } }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.GetQuestEvidence = function(_, id)
      if tonumber(id) == 2178 then
        return { id = 2178, inLog = true, complete = false, turnedIn = false }
      end
      return nil
    end
    TG.GetItemCount = function()
      return 0
    end
    env.eq(TG:IsElementDone(collect), false)
    env.eq(TG:IsStepComplete(step), false)
  end,

  test_quest_accept_invalidates_cached_step_completion = function()
    local TG = loadEngine()
    local accept = { t = "cmd", tag = "accept", args = { "9" }, text = "Accept The Killing Fields" }
    local step = { elements = { accept } }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.CheckAdvance = function() end
    local inLog = false
    TG.GetQuestEvidence = function()
      return { id = 9, inLog = inLog, complete = false, turnedIn = false }
    end
    env.eq(TG:CachedStepComplete(step), false)
    inLog = true
    _G.GetTime = function()
      return 10
    end
    _G.GetQuestLogTitle = function()
      return "The Killing Fields", 1, nil, false, false, nil, nil, 9
    end
    TG:OnQuestAccepted(1)
    env.eq(TG:CachedStepComplete(step), true)
  end,

  test_xp_uses_live_counters = function()
    local TG = loadEngine()
    _G.UnitLevel = function()
      return 10
    end
    env.eq(TG:IsElementDone({ t = "cmd", tag = "xp", args = { "10" } }), true)
  end,

  test_complete_objective_uses_quest_turnin_evidence = function()
    local TG = loadEngine()
    _G.pfQuest_history = { [319] = true }
    TG.GetQuestTitleById = function()
      return "A Favor for Evershine"
    end
    TG.GetQuestLogIndexByTitle = function()
      return nil
    end
    TG.GetQuestLogIndexById = function()
      return nil
    end
    local el = { t = "cmd", tag = "complete", args = { "319", "1" }, text = "" }
    env.eq(TG:IsElementDone(el), true)
    env.eq(TG:IsStepComplete({ elements = { el } }), true)
    TG.cdb = { turnedIn = { [319] = true } }
    env.eq(TG:IsElementDone(el), true)
  end,

  test_complete_objective_remaps_index_from_guide_text = function()
    local TG = loadEngine()
    TG.GetQuestTitleById = function()
      return "Frostmane Hold"
    end
    TG.GetQuestLogIndexByTitle = function()
      return 1
    end
    TG.GetQuestLogIndexById = function()
      return 1
    end
    local objectives = {
      [1] = { text = "Explore Frostmane Hold", done = true },
      [2] = { text = "Frostmane Headhunters slain: 2/5", done = false },
    }
    TG.GetQuestObjectives = function()
      return objectives
    end
    local el = {
      t = "cmd",
      tag = "complete",
      args = { "287", "1" },
      objectiveText = "Kill Frostmane Headhunter (x5)",
    }
    env.eq(TG:IsElementDone(el), false)
    env.eq(el.args[2], "2")
    objectives[2] = { text = "Frostmane Headhunters slain: 5/5", done = true }
    env.eq(TG:IsElementDone(el), true)
  end,

  test_collect_objective_ignores_account_quest_history = function()
    local TG = loadEngine()
    _G.pfQuest_history = { [319] = true }
    TG.GetQuestLogIndexById = function()
      return nil
    end
    local el = { t = "cmd", tag = "collect", args = { "2488", "1", "319" } }
    env.eq(TG:IsElementDone(el), false)
    TG.cdb = { turnedIn = { [319] = true } }
    env.eq(TG:IsElementDone(el), true)
  end,

  test_complete_item_objective_uses_bag_count = function()
    local TG = loadEngine()
    TG.guides = {
      {
        steps = {
          {
            elements = {
              { tag = "collect", objectiveText = "Collect Crag Boar Rib (x6)", args = { "2886" } },
            },
          },
        },
      },
    }
    _G.GetContainerNumSlots = function(bag)
      return bag == 0 and 1 or 0
    end
    _G.GetContainerItemLink = function()
      return "|Hitem:2886::::::::::::|h[Crag Boar Rib]|h"
    end
    _G.GetContainerItemInfo = function()
      return nil, 6
    end
    TG.GetQuestLogIndexByTitle = function()
      return nil
    end
    TG.GetQuestLogIndexById = function()
      return nil
    end
    local el = {
      t = "cmd",
      tag = "complete",
      args = { "384", "1" },
      objectiveText = "Collect Crag Boar Rib (x6)",
    }
    env.eq(TG:IsElementDone(el), true)
  end,

  test_manual_action_blocks_completion = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "vendor" } } }
    TG.CurrentStep = function()
      return step
    end
    env.eq(TG:IsStepComplete(step), false)
    TG:SignalManualAction("vendor")
    env.eq(TG:IsStepComplete(step), true)
  end,

  test_skip_if_missing_turnin_and_complete = function()
    local TG = loadEngine()
    local turnin = {
      t = "cmd",
      tag = "turnin",
      args = { "-414" },
      text = "Turn in Stout to Kadrell",
      questIds = { 414 },
      skipIfMissing = true,
    }
    local complete = {
      t = "cmd",
      tag = "complete",
      args = { "-386", "1" },
      questIds = { 386 },
      skipIfMissing = true,
    }
    env.eq(TG:IsElementDone(turnin), true)
    env.eq(TG:IsElementDone(complete), true)
  end,

  test_skip_if_missing_waits_while_quest_is_in_log = function()
    local TG = loadEngine()
    _G.GetNumQuestLogEntries = function()
      return 1
    end
    _G.GetQuestLogTitle = function()
      return "Stout to Kadrell", 1, nil, false, false, nil, nil, 414
    end
    TG:InvalidateQuestLedger()
    local el = {
      t = "cmd",
      tag = "turnin",
      args = { "-414" },
      text = "Turn in Stout to Kadrell",
      questIds = { 414 },
      skipIfMissing = true,
    }
    env.eq(TG:IsElementDone(el), false)
  end,
}
