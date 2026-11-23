local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_debug_saves_current_step_report = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept Foo" } } }
    TG.currentGuide = { key = "k", name = "Guide", steps = { step } }
    TG.currentStepIndex = 1
    TG.cdb = {}
    TG:DebugCurrentStep()
    env.eq(string.find(TG.cdb.debug, "Debug guide: Guide step 1/1", 1, true) ~= nil, true)
  end,
}
