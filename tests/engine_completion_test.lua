local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_manual_override_wins = function()
    local TG = loadEngine()
    local el = { t = "cmd", tag = "accept", _tgManualDone = true }
    env.eq(TG:IsElementDone(el), true)
    env.eq(TG._tgDoneSource, "manual checkbox")
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

  test_xp_uses_live_counters = function()
    local TG = loadEngine()
    _G.UnitLevel = function()
      return 10
    end
    env.eq(TG:IsElementDone({ t = "cmd", tag = "xp", args = { "10" } }), true)
  end,

  test_complete_objective_ignores_account_quest_history = function()
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
    env.eq(TG:IsElementDone(el), false)
    env.eq(TG:IsStepComplete({ elements = { el } }), false)
    TG.cdb = { turnedIn = { [319] = true } }
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
