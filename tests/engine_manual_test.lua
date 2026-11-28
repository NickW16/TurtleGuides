local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  local TG = env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/engine/State.lua",
    "src/engine/QuestDiff.lua",
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

  test_hs_action_detected_by_signal = function()
    local TG = fresh()
    TG._testStep = { elements = {} }
    env.eq(TG:IsHearthstoneSpell(8690), true)
    env.eq(TG:IsHearthstoneSpell(556), true)
    env.eq(TG:IsHearthstoneSpell(123), false)
    env.eq(TG:SignalHearthstoneUse(), true)
    local stepKey = tostring(TG._testStep)
    env.eq(TG:ManualActionDetected({ t = "cmd", tag = "hs" }, stepKey), true)
    env.eq(TG:ManualActionDetected({ t = "cmd", tag = "hearth" }, stepKey), true)
    env.eq(TG:SignalHearthstoneUse(), false)
  end,

  test_hs_cooldown_transition_signals_use = function()
    local TG = fresh()
    TG._testStep = { elements = {} }
    local cooldown = { start = 0, duration = 0 }
    _G.GetTime = function()
      return 100
    end
    _G.GetSpellCooldown = nil
    _G.GetItemCooldown = function()
      return cooldown.start, cooldown.duration
    end
    env.eq(TG:PollHearthstoneUse(), false)
    cooldown.start = 100
    cooldown.duration = 3600
    env.eq(TG:PollHearthstoneUse(), true)
    env.eq(TG:ManualActionDetected({ t = "cmd", tag = "hs" }, tostring(TG._testStep)), true)
  end,

  test_abandon_auto_completes_when_quest_is_missing = function()
    local TG = fresh()
    TG._questLogSeeded = true
    local el = { t = "cmd", tag = "abandon", args = { "9" }, text = "Abandon The Killing Fields" }
    local step = { elements = { el } }
    local title, id = TG:ResolveQuestTitle(el)
    env.eq(title, "The Killing Fields")
    env.eq(id, 9)
    env.eq(TG:ManualActionDetected(el, tostring(step)), true)
    env.eq(TG:StepManualActionsSatisfied(step), true)
  end,

  test_abandon_waits_when_quest_is_in_log = function()
    local TG = fresh()
    TG._questLogSeeded = true
    TG.GetQuestEvidence = function()
      return { id = 9, inLog = true, complete = false, turnedIn = false }
    end
    local el = { t = "cmd", tag = "abandon", args = { "9" }, text = "Abandon The Killing Fields" }
    local step = { elements = { el } }
    env.eq(TG:ManualActionDetected(el, tostring(step)), false)
    env.eq(TG:StepManualActionsSatisfied(step), false)
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
