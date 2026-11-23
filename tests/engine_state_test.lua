local env = dofile("tests/env.lua")

return {
  test_constants_are_exposed = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/engine/State.lua")
    local Shared = TG.Engine.Shared
    env.eq(Shared.RECENT_ACCEPT_WINDOW, 5)
    env.eq(Shared.MANUAL_CHECK_VISIBLE_DELAY, 0.6)
    env.eq(Shared.OBJECTIVE_TAGS.accept, true)
    env.eq(Shared.MANUAL_ACTION_TAGS.vendor, true)
  end,

  test_objective_helpers = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/engine/State.lua")
    local Shared = TG.Engine.Shared
    local step = { elements = { { t = "cmd", tag = "accept" }, { t = "text", text = "hi" } } }
    env.eq(Shared.isObjectiveElement(step.elements[1]), true)
    env.eq(Shared.isObjectiveElement(step.elements[2]), false)
    env.eq(Shared.stepHasObjective(step), true)
    env.eq(Shared.stepHasItemCountCondition(step), false)
  end,
}
