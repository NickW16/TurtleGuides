local env, loadEngine = dofile("tests/engine_base.lua")

local function evidenceFor(values)
  return function(el)
    local id = tonumber(el.args and el.args[1])
    local value = values[id]
    if not value then
      return nil
    end
    return {
      id = id,
      title = value.title or "Quest " .. tostring(id),
      inLog = value.inLog == true,
      turnedIn = value.turnedIn == true,
      confidence = value.confidence or "confirmed",
    }
  end
end

return {
  test_resume_find_index_returns_first_unfinished_step = function()
    local TG = loadEngine()
    local steps = {
      { elements = { { t = "cmd", tag = "accept", args = { "1" } } } },
      { elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "1", "1" } } } },
      { elements = { { t = "cmd", tag = "turnin", args = { "2" } } } },
    }
    local result = TG.Engine.Resume.findIndex({
      steps = steps,
      currentIndex = 1,
      evidence = evidenceFor({ [2] = { turnedIn = true, title = "Two" } }),
      complete = function(step)
        return step == steps[1]
      end,
      hasManual = function()
        return false
      end,
    })
    env.eq(result.index, 3)
  end,

  test_resume_find_index_walks_over_completed_steps = function()
    local TG = loadEngine()
    local steps = {
      { elements = { { t = "cmd", tag = "accept", args = { "1" } } } },
      { elements = { { t = "cmd", tag = "turnin", args = { "2" } } } },
      { elements = { { t = "text", text = "after" } } },
    }
    local result = TG.Engine.Resume.findIndex({
      steps = steps,
      currentIndex = 1,
      evidence = evidenceFor({ [2] = { turnedIn = true, title = "Two" } }),
      complete = function(step)
        return step == steps[1] or step == steps[2]
      end,
      hasManual = function()
        return false
      end,
    })
    env.eq(result.index, 3)
  end,

  test_resume_find_index_holds_before_confirmed_work = function()
    local TG = loadEngine()
    local steps = {
      { elements = { { t = "cmd", tag = "accept", args = { "1" } } } },
      { elements = { { t = "cmd", tag = "turnin", args = { "2" } } } },
      { elements = { { t = "text", text = "middle" } } },
      { elements = { { t = "cmd", tag = "turnin", args = { "3" } } } },
    }
    local result = TG.Engine.Resume.findIndex({
      steps = steps,
      currentIndex = 1,
      complete = function(step)
        return step == steps[1]
      end,
      pendingEvidence = function(step)
        return step == steps[2]
      end,
      evidence = evidenceFor({
        [2] = { inLog = true, complete = false, title = "Two" },
        [3] = { turnedIn = true, confidence = "weak", title = "Three" },
      }),
      hasManual = function()
        return false
      end,
    })
    env.eq(result.index, 2)
  end,

  test_resume_find_index_ignores_weak_backwards_movement = function()
    local TG = loadEngine()
    local steps = {
      { elements = { { t = "cmd", tag = "turnin", args = { "2" } } } },
      { elements = { { t = "text", text = "two" } } },
      { elements = { { t = "text", text = "three" } } },
      { elements = { { t = "text", text = "four" } } },
      { elements = { { t = "text", text = "five" } } },
    }
    local result = TG.Engine.Resume.findIndex({
      steps = steps,
      currentIndex = 5,
      evidence = evidenceFor({ [2] = { turnedIn = true, confidence = "weak", title = "Two" } }),
      complete = function()
        return false
      end,
      hasManual = function()
        return false
      end,
    })
    env.eq(result.index, 5)
  end,

  test_resume_reports_missing_evidence_for_blocked_step = function()
    local TG = loadEngine()
    local g = {
      key = "Test||Guide",
      name = "Guide",
      steps = { { elements = { { t = "cmd", tag = "turnin", args = { "948" }, text = "Turn in Onu" } } } },
    }
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.currentGuide = g
    TG.currentStepIndex = 1
    local result = TG:FindResumeIndex(g)
    env.eq(result.index, 1)
    env.eq(result.reason, "no evidence for Onu (948)")
  end,

  test_manual_checkoff_persists_across_reload = function()
    local TG = loadEngine()
    local el = { t = "cmd", tag = "accept", args = { "1" }, text = "Accept One" }
    local step = { stepId = 7, elements = { el } }
    local g = { key = "Test||Guide", name = "Guide", steps = { step } }
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { [g.key] = g }
    TG.currentGuide = g
    TG.currentStepIndex = 1
    TG:SetElementManualDone(el, true)
    env.eq(TG.cdb.manualDoneByGuide[g.key]["7:1"], true)
    el._tgManualDone = nil
    TG:RestoreManualElementStates(g)
    env.eq(el._tgManualDone, true)
    env.eq(TG:IsStepComplete(step), true)
  end,

  test_expected_quest_log_tracks_accepts_and_turnins = function()
    local TG = loadEngine()
    local steps = {
      { elements = { { t = "cmd", tag = "accept", args = { "1" } } } },
      { elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "1", "1" } } } },
      { elements = { { t = "cmd", tag = "turnin", args = { "1" } } } },
      { elements = { { t = "cmd", tag = "accept", args = { "2" } } } },
    }
    local expected, turnedIn, future = TG.Engine.Resume.expected(steps, 2, evidenceFor({ [1] = { inLog = true } }))
    env.eq(expected[1], true)
    env.eq(turnedIn[1], nil)
    env.eq(future[1], 3)

    local later, done = TG.Engine.Resume.expected(steps, 3, evidenceFor({}))
    env.eq(later[1], nil)
    env.eq(done[1], true)
  end,

  test_expected_quest_log_walks_guide_chain = function()
    local TG = loadEngine()
    local first = {
      key = "A",
      name = "A",
      steps = { { elements = { { t = "cmd", tag = "accept", args = { "1" } } } } },
    }
    local second = {
      key = "B",
      name = "B",
      next = "A",
      steps = {
        { elements = { { t = "cmd", tag = "turnin", args = { "1" } } } },
        { elements = { { t = "cmd", tag = "accept", args = { "2" } } } },
      },
    }
    TG.db = {}
    TG.cdb = {}
    TG.guideByKey = { A = first, B = second }
    TG.currentGuide = second
    TG.currentStepIndex = 1
    local expected, turnedIn = TG:GetExpectedQuestLog()
    env.eq(expected[1], nil)
    env.eq(turnedIn[1], true)
    env.eq(expected[2], nil)
  end,
}
