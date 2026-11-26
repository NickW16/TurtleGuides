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

  test_debug_opens_copyable_window = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept Foo" } } }
    TG.currentGuide = { key = "k", name = "Guide", steps = { step } }
    TG.currentStepIndex = 1
    TG.cdb = {}
    TG:DebugCurrentStep()
    local frame
    for _, candidate in ipairs(env.frames) do
      if candidate.name == "TurtleGuidesDebugCopyFrame" then
        frame = candidate
      end
    end
    env.eq(frame ~= nil, true)
    env.eq(frame.visible, true)
    env.eq(string.find(frame.edit.text, "Debug guide: Guide step 1/1", 1, true) ~= nil, true)
  end,

  test_debug_reports_ledger_and_step_state = function()
    local TG = loadEngine()
    local el = {
      t = "cmd",
      tag = "turnin",
      sourceTag = "turnin!",
      args = { "-414" },
      questIds = { 414 },
      skipIfMissing = true,
      text = "Turn in Stout to Kadrell",
    }
    local step = { index = 4, label = "Stout", completewith = "next", elements = { el }, stepSkip = false }
    local steps = {
      { index = 1, elements = { { t = "text", text = "before" } } },
      { index = 2, elements = { { t = "text", text = "before" } } },
      { index = 3, elements = { { t = "text", text = "before" } } },
      step,
    }
    TG.currentGuide = { key = "stout", name = "Stout", steps = steps, labels = { Stout = 4 } }
    TG.currentStepIndex = 4
    TG.cdb = { guideCursors = { stout = 4 }, turnedIn = { [414] = true } }

    TG:DebugCurrentStep()
    local report = TG.cdb.debug
    for _, needle in ipairs({
      "guide key: stout",
      "saved cursor: 4",
      "step index: 4 label=Stout completewith=next",
      "ids={414} skipIfMissing",
      "ledger: id=414",
      "turnedIn=true",
      "step complete: true",
      "stepSkip: false",
    }) do
      env.eq(string.find(report, needle, 1, true) ~= nil, true, needle)
    end
  end,
}
