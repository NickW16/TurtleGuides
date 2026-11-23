local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  local TG = env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/engine/State.lua",
    "src/engine/Quests.lua",
    "src/engine/Manual.lua"
  )
  TG.CurrentStep = function()
    return TG._testStep
  end
  TG.IsElementDone = function()
    return true
  end
  TG.StepSkipState = function()
    return false
  end
  return TG
end

return {
  test_manual_action_tags = function()
    local TG = fresh()
    local found, tag = TG:StepHasManualAction({ elements = { { t = "cmd", tag = "vendor" } } })
    env.eq(found, true)
    env.eq(tag, "vendor")
  end,

  test_bind_signal_detects_change = function()
    local TG = fresh()
    TG:ResetManualSignals()
    env.eq(TG._bindBaseline, "Dun Morogh")
    _G.GetBindLocation = function()
      return "Ironforge"
    end
    TG:PollBindLocation()
    env.eq(TG._bindSignal, true)
  end,

  test_signal_manual_action = function()
    local TG = fresh()
    TG._testStep = { elements = {} }
    TG:SignalManualAction("vendor")
    local el = { t = "cmd", tag = "vendor" }
    env.eq(TG:ManualActionDetected(el, tostring(TG._testStep)), true)
  end,

  test_home_action_matches_bind_location = function()
    local TG = fresh()
    _G.GetBindLocation = function()
      return "Ironforge"
    end
    local el = { t = "cmd", tag = "home", text = "Set your Hearthstone to Ironforge." }
    env.eq(TG:ManualActionDetected(el, "unused"), true)
  end,

  test_manual_checkbox_override = function()
    local TG = fresh()
    local el = { t = "cmd", tag = "accept" }
    env.eq(TG:SetElementManualDone(el, true), true)
    env.eq(el._tgManualDone, true)
    env.eq(TG:IsElementTrackable(el), true)
    TG:ClearManualElementStates({ elements = { el } })
    env.eq(el._tgManualDone, nil)
  end,

  test_manual_nav_hold = function()
    local TG = fresh()
    TG.currentStepIndex = 1
    TG._testStep = { elements = {} }
    TG:CaptureManualNavState("Next")
    env.eq(TG:IsManualNavHeld(), true)
    TG:ClearManualNavHold("test")
    env.eq(TG:IsManualNavHeld(), false)
  end,
}
