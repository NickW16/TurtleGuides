local env, loadEngine = dofile("tests/engine_base.lua")

local function guide()
  return {
    key = "Test||Guide",
    name = "Guide",
    steps = {
      { elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept Foo" } } },
      { elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } } } },
    },
  }
end

local function softcoreGuide()
  return {
    key = "Test||Guide",
    name = "Guide",
    steps = {
      { elements = { { t = "cmd", tag = "accept", args = { "1" } } } },
      { _softcore = true, elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } } } },
      { elements = { { t = "text", text = "after" } } },
    },
  }
end

return {
  test_set_guide_and_current_step = function()
    local TG = loadEngine()
    local g = guide()
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    env.eq(TG:SetGuide(g.key, 1), true)
    env.eq(TG.currentStepIndex, 1)
    env.eq(TG:CurrentStep(), g.steps[1])
  end,

  test_next_and_prev_navigation = function()
    local TG = loadEngine()
    local g = guide()
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1)
    TG:NextStep(false)
    env.eq(TG.currentStepIndex, 2)
    env.eq(TG.cdb.completedByGuide[g.key][1], true)
    TG:PrevStep()
    env.eq(TG.currentStepIndex, 1)
  end,

  test_disable_auto_skip_keeps_deathskip_steps = function()
    local TG = loadEngine()
    local g = guide()
    g.steps[2]._deathskip = true
    table.insert(g.steps, { elements = { { t = "text", text = "after" } } })
    TG.db = { hardcoreMode = true, disableAutoSkip = true }
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1)
    TG:NextStep(false)
    env.eq(TG.currentStepIndex, 2)
  end,

  test_hardcore_next_skips_softcore_step = function()
    local TG = loadEngine()
    local g = softcoreGuide()
    TG.db = { hardcoreMode = true }
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1)
    TG:NextStep(false)
    env.eq(TG.currentStepIndex, 3)
  end,

  test_hardcore_next_skips_softcore_with_auto_skip_disabled = function()
    local TG = loadEngine()
    local g = softcoreGuide()
    TG.db = { hardcoreMode = true, disableAutoSkip = true }
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1)
    TG:NextStep(false)
    env.eq(TG.currentStepIndex, 3)
  end,

  test_hardcore_prev_skips_softcore_step = function()
    local TG = loadEngine()
    local g = softcoreGuide()
    TG.db = { hardcoreMode = true }
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 3)
    TG:PrevStep()
    env.eq(TG.currentStepIndex, 1)
  end,

  test_hardcore_find_my_place_skips_softcore_step = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = {
        { elements = { { t = "text", text = "before" } } },
        { _softcore = true, elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } } } },
        { elements = { { t = "cmd", tag = "accept", args = { "9" } } } },
      },
    }
    TG.db = { hardcoreMode = true }
    TG.cdb = {}
    TG._questLogSeeded = true
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1)
    TG:FindMyPlace(true)
    env.eq(TG.currentStepIndex, 3)
  end,

  test_saved_cursor_is_per_guide_and_explicit_step_wins = function()
    local TG = loadEngine()
    local a = {
      key = "A",
      name = "A",
      steps = {
        { elements = { { t = "text", text = "a1" } } },
        { elements = { { t = "text", text = "a2" } } },
        { elements = { { t = "text", text = "a3" } } },
      },
    }
    local b = {
      key = "B",
      name = "B",
      steps = {
        { elements = { { t = "text", text = "b1" } } },
        { elements = { { t = "text", text = "b2" } } },
      },
    }
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { A = a, B = b }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end

    env.eq(TG:SetGuide("A", 2, true, true), true)
    env.eq(TG.cdb.guideCursors.A, 2)
    env.eq(TG:SetGuide("B", 2, true, true), true)
    env.eq(TG.cdb.guideCursors.B, 2)

    env.eq(TG:SetGuide("A", 1, true, true), true)
    env.eq(TG.currentStepIndex, 2)
    env.eq(TG:SetGuide("A", 3, true, true), true)
    env.eq(TG.currentStepIndex, 3)
    env.eq(TG.cdb.guideCursors.A, 3)
  end,
}
