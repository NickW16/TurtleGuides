local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/core/Output.lua",
    "src/core/State.lua",
    "src/parser/Applies.lua",
    "src/parser/Context.lua",
    "src/parser/Elements.lua",
    "src/parser/Guide.lua"
  )
end

local TEXT = [[
#name Test Guide
#group Classic

step << Mage
.goto 1432,10,20

step
#season 1
.accept 5

step
.accept 6
]]

return {
  test_guide_metadata = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide(TEXT, "test.lua")
    env.eq(guide.name, "Test Guide")
    env.eq(guide.group, "Classic")
    env.eq(guide.key, "Classic||Test Guide")
    env.eq(guide.isClassic, false)
  end,

  test_steps_and_season_skip = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide(TEXT, "test.lua")
    env.eq(table.getn(guide.steps), 2)
    env.eq(guide.steps[1].cond, "Mage")
    env.eq(guide.steps[2].elements[1].tag, "accept")
  end,

  test_inapplicable_guide = function()
    local TG = fresh()
    local guide, reason = TG.Parser.ParseGuide("<< Alliance\nstep\n.accept 1", "test.lua")
    env.eq(guide, nil)
    env.eq(reason, "not applicable")
  end,

  test_classic_tag = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide("#classic 1\nstep\n.accept 1", "test.lua")
    env.eq(guide.isClassic, true)
  end,
}
