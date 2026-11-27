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

  test_find_my_place_resolves_negative_quest_ids_and_seeds_log = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = {
        { elements = { { t = "text", text = "before" } } },
        { elements = { { t = "cmd", tag = "turnin", args = { "-414" } } } },
        { elements = { { t = "text", text = "after" } } },
      },
    }
    TG.db = {}
    TG.cdb = { turnedIn = { [414] = true } }
    TG.guideByKey = { [g.key] = g }
    TG.GetQuestTitleById = function()
      return "Foo"
    end
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG._questLogSeeded = false
    TG:SetGuide(g.key, 1)
    TG:FindMyPlace(true)
    env.eq(TG._questLogSeeded, true)
    env.eq(TG.currentStepIndex, 3)
  end,

  test_find_my_place_keeps_confirmed_cap_over_weak_later_evidence = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = {
        { elements = { { t = "text", text = "before" } } },
        { elements = { { t = "cmd", tag = "turnin", args = { "99" }, text = "Early" } } },
        { elements = { { t = "text", text = "middle" } } },
        { elements = { { t = "cmd", tag = "turnin", args = { "414" }, text = "Later" } } },
      },
    }
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.GetQuestTitleById = function()
      return "Later"
    end
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    _G.GetNumQuestLogEntries = function()
      return 1
    end
    _G.GetQuestLogTitle = function()
      return "Early", 1, nil, false, false, nil, nil, 99
    end
    _G.pfQuest_history = { [414] = true }
    TG:SetGuide(g.key, 1)
    TG:FindMyPlace(true)
    env.eq(TG.currentStepIndex, 2)
  end,

  test_find_my_place_does_not_move_backwards_on_weak_evidence = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = {
        {
          elements = {
            { t = "cmd", tag = "turnin", args = { "414" }, text = "Later" },
            { t = "cmd", tag = "collect", args = { "5", "1", "999" }, text = "Pending" },
          },
        },
        { elements = { { t = "text", text = "two" } } },
        { elements = { { t = "text", text = "three" } } },
        { elements = { { t = "text", text = "four" } } },
        { elements = { { t = "text", text = "five" } } },
      },
    }
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.GetQuestTitleById = function()
      return "Later"
    end
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    _G.pfQuest_history = { [414] = true }
    TG:SetGuide(g.key, 5)
    TG:FindMyPlace(true)
    env.eq(TG.currentStepIndex, 5)
  end,

  test_next_step_skips_already_complete_steps = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = {
        { elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept One" } } },
        { elements = { { t = "cmd", tag = "turnin", args = { "2" }, text = "Turn in Two" } } },
        { elements = { { t = "cmd", tag = "accept", args = { "3" }, text = "Accept Three" } } },
        { elements = { { t = "text", text = "after" } } },
      },
    }
    TG.db = {}
    TG.cdb = { turnedIn = { [2] = true } }
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1, true, true)
    TG:NextStep(false)
    env.eq(TG.currentStepIndex, 3)
    env.eq(TG.cdb.completedByGuide[g.key][2], true)
  end,

  test_set_guide_uses_resume_index = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = {
        { elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept One" } } },
        { elements = { { t = "cmd", tag = "turnin", args = { "2" }, text = "Turn in Two" } } },
        { elements = { { t = "cmd", tag = "accept", args = { "3" }, text = "Accept Three" } } },
      },
    }
    TG.db = {}
    TG.cdb = { turnedIn = { [2] = true } }
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, nil, true)
    env.eq(TG.currentStepIndex, 3)
  end,

  test_saved_step_id_survives_guide_edit = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = {
        { stepId = 10, elements = { { t = "text", text = "one" } } },
        { stepId = 20, elements = { { t = "text", text = "two" } } },
      },
    }
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 2, true, true)
    env.eq(TG.cdb.guideStepIds[g.key], 20)

    local edited = {
      key = g.key,
      name = "Guide",
      steps = {
        { stepId = 10, elements = { { t = "text", text = "one" } } },
        { stepId = 15, elements = { { t = "text", text = "inserted" } } },
        { stepId = 20, elements = { { t = "text", text = "two" } } },
      },
    }
    TG.guideByKey[g.key] = edited
    TG:SetGuide(g.key, nil, true, true)
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
