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
}
