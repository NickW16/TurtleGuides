local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_auto_advances_once_when_complete = function()
    local TG = loadEngine()
    local step = { elements = {} }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.CheckGotoAdvance = function() end
    TG.StepSkipState = function()
      return false
    end
    TG.IsStepComplete = function()
      return true
    end
    local advanced
    TG.NextStep = function(_, manual)
      advanced = manual
      TG._autoNavTime = 0
    end
    TG:CheckAdvance("tick")
    env.eq(advanced, false)
    advanced = nil
    TG:CheckAdvance("tick")
    env.eq(advanced, nil)
  end,

  test_manual_nav_hold_blocks_advance = function()
    local TG = loadEngine()
    local step = { elements = {} }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG._manualNavHold = true
    TG._manualNavStep = 1
    TG.StepStateSignature = function()
      return "same"
    end
    TG._manualNavSignature = "same"
    TG.PlayerMovedSinceManualNav = function()
      return false
    end
    local advanced = false
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckAdvance("tick")
    env.eq(advanced, false)
  end,

  test_completed_step_ignores_manual_nav_hold = function()
    local TG = loadEngine()
    local step = { elements = {} }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG._manualNavHold = true
    TG._manualNavStep = 1
    TG.StepStateSignature = function()
      return "same"
    end
    TG._manualNavSignature = "same"
    TG.PlayerMovedSinceManualNav = function()
      return false
    end
    TG.IsStepComplete = function()
      return true
    end
    TG.CheckGotoAdvance = function() end
    local advanced = false
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckAdvance("tick")
    env.eq(advanced, true)
  end,

  test_manual_nav_hold_survives_completed_step = function()
    local TG = loadEngine()
    local step = { elements = {} }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG._manualNavHold = true
    TG._manualNavStep = 1
    TG._manualNavReason = "Prev"
    TG.StepStateSignature = function()
      return "same"
    end
    TG._manualNavSignature = "same"
    TG.PlayerMovedSinceManualNav = function()
      return false
    end
    TG.IsStepComplete = function()
      return true
    end
    TG.CheckGotoAdvance = function() end
    local advanced = false
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckAdvance("tick")
    env.eq(advanced, false)
  end,

  test_unseeded_quest_log_blocks_advance = function()
    local TG = loadEngine()
    local step = { elements = {} }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG._questLogSeeded = false
    TG.CheckGotoAdvance = function() end
    TG.IsStepComplete = function()
      return true
    end
    local advanced
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckAdvance("tick")
    env.eq(advanced, nil)
  end,

  test_disable_auto_skip_blocks_skip_advance = function()
    local TG = loadEngine()
    local step = { elements = {} }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    TG.db = { disableAutoSkip = true }
    TG.CheckGotoAdvance = function() end
    TG.StepSkipState = function()
      return true
    end
    TG.IsStepComplete = function()
      return false
    end
    local advanced
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckAdvance("tick")
    env.eq(advanced, nil)
  end,

  test_expired_xp_cap_step_advances = function()
    local TG = loadEngine()
    _G.UnitLevel = function()
      return 8
    end
    local step = {
      elements = {
        { t = "cmd", tag = "xp", args = { "<8", "1" } },
        { t = "cmd", tag = "train", args = {} },
      },
    }
    TG.currentGuide = { key = "k", steps = { step, { elements = {} } } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.cdb = {}
    TG.CheckGotoAdvance = function() end
    local advanced
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckAdvance("tick")
    env.eq(advanced, true)
  end,
}
