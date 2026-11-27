local env, loadEngine = dofile("tests/engine_base.lua")

local function simpleGuide()
  return {
    key = "Test||Guide",
    name = "Guide",
    steps = {
      { elements = { { t = "cmd", tag = "turnin", args = { "2" }, text = "Turn in Two" } } },
      { elements = { { t = "cmd", tag = "accept", args = { "3" }, text = "Accept Three" } } },
    },
  }
end

return {
  test_auto_resume_requires_setting = function()
    local TG = loadEngine()
    local g = simpleGuide()
    TG.db = { autoResume = false }
    TG.cdb = { turnedIn = { [2] = true } }
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1, true, true)
    env.eq(TG:MaybeResume(), false)
    env.eq(TG.currentStepIndex, 1)
  end,

  test_auto_resume_skips_completed_current_step = function()
    local TG = loadEngine()
    local g = simpleGuide()
    TG.db = { autoResume = true }
    TG.cdb = { turnedIn = { [2] = true } }
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1, true, true)
    env.eq(TG:MaybeResume(), true)
    env.eq(TG.currentStepIndex, 2)
    local found = false
    for _, message in ipairs(env.messages) do
      if string.find(message, "Skipped to step 2", 1, true) then
        found = true
      end
    end
    env.eq(found, true)
  end,

  test_auto_resume_holds_on_manual_navigation = function()
    local TG = loadEngine()
    local g = simpleGuide()
    TG.db = { autoResume = true }
    TG.cdb = { turnedIn = { [2] = true } }
    TG.guideByKey = { [g.key] = g }
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG:SetGuide(g.key, 1, true, true)
    TG._manualNavReason = "Next"
    env.eq(TG:MaybeResume(), false)
    env.eq(TG.currentStepIndex, 1)
  end,

  test_resume_updater_respects_debounce = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    local now = 10
    _G.GetTime = function()
      return now
    end
    local calls = 0
    TG.MaybeResume = function()
      calls = calls + 1
      return false
    end
    TG:QueueResume()
    now = 10.3
    TG.updaters.resume.fn()
    env.eq(calls, 0)
    now = 10.6
    TG.updaters.resume.fn()
    env.eq(calls, 1)
    TG.updaters.resume.fn()
    env.eq(calls, 1)
  end,

  test_step_completion_cache_invalidates = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "accept", args = { "1" } } } }
    local calls, value = 0, false
    TG.IsStepComplete = function()
      calls = calls + 1
      return value
    end
    env.eq(TG:CachedStepComplete(step), false)
    env.eq(TG:CachedStepComplete(step), false)
    env.eq(calls, 1)
    value = true
    TG:InvalidateStepCompletionCache()
    env.eq(TG:CachedStepComplete(step), true)
    env.eq(calls, 2)
  end,

  test_step_cache_updater_refreshes_nearby_steps = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    local steps = {}
    for i = 1, 10 do
      table.insert(steps, { elements = { { t = "text", text = "step " .. i } } })
    end
    TG.currentGuide = { key = "k", steps = steps }
    TG.currentStepIndex = 2
    local seen = {}
    TG.IsStepComplete = function(_, step)
      table.insert(seen, step)
      return false
    end
    TG.updaters.stepCache.fn()
    env.eq(table.getn(seen), 8)
    env.eq(seen[1], steps[2])
    env.eq(seen[8], steps[9])
  end,
}
