local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/engine/State.lua",
    "src/engine/Quests.lua",
    "src/ui/State.lua",
    "src/ui/StepText.lua"
  )
end

return {
  test_text_element = function()
    local TG = fresh()
    env.eq(TG.UI.StepText.elToText({ t = "text", text = "hello" }), "hello")
  end,

  test_accept_element = function()
    local TG = fresh()
    local text = TG.UI.StepText.elToText({ t = "cmd", tag = "accept", args = { "1" }, text = "Accept Foo" })
    env.eq(text, "|cff00ff00Accept:|r Foo")
  end,

  test_objective_comment = function()
    local TG = fresh()
    local name, need, isItem = TG.UI.StepText.parseObjectiveComment("Collect Thick Bear Fur (x2)")
    env.eq(name, "Thick Bear Fur")
    env.eq(need, 2)
    env.eq(isItem ~= false, true)
  end,

  test_xp_step_text = function()
    local TG = fresh()
    _G.UnitLevel = function()
      return 1
    end
    local text = TG.UI.StepText.elToText({ t = "cmd", tag = "xp", args = { "10" } })
    env.eq(text, "|cffaaaaaaGrind to level 10|r")
  end,

  test_aux_signature = function()
    local TG = fresh()
    local step = {
      elements = {
        { t = "cmd", tag = "complete", args = { "5" } },
        { t = "cmd", tag = "collect", args = { "42" } },
      },
    }
    env.eq(TG.UI.StepText.auxStepSignature(step), "collect:42|complete:5:")
  end,
}
