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

  test_zone_line_parses_as_command = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide("#name T\n#group G\nstep\n.zone Redridge\n", "test.lua")
    env.eq(guide.steps[1].elements[1].tag, "zone")
    env.eq(guide.steps[1].elements[1].args[1], "Redridge")
  end,

  test_step_ids_follow_source_lines = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide(TEXT, "test.lua")
    env.eq(guide.steps[1].stepId, 4)
    env.eq(guide.steps[2].stepId, 11)
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

  test_softcore_tag_marks_step = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide(
      [[
#name Test Guide
#group Classic
step
#softcore
.goto 1432,10,20
step
#hardcore
.goto 1432,20,30
]],
      "test.lua"
    )
    env.eq(guide.steps[1]._softcore, true)
    env.eq(guide.steps[2]._softcore, false)
  end,

  test_zoneless_goto_inherits_last_zone = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide(
      [[
#name Test Guide
#group Classic
step
.goto Dun Morogh,10,20
.goto 30,40
]],
      "test.lua"
    )
    local first = guide.steps[1].elements[1]
    local second = guide.steps[1].elements[2]
    env.eq(first.args[1], "Dun Morogh")
    env.eq(second.args[1], "30")
    env.eq(second.args[2], "40")
    env.eq(second.gotoZone, "Dun Morogh")
  end,

  test_step_index_labels_and_skip_bookkeeping = function()
    local TG = fresh()
    local guide = TG.Parser.ParseGuide(
      [[
#name Test Guide
#group Classic
step
#label Foo
.accept 1
step
#completewith Foo
.accept 2
step
#completewith next
.accept 3
step
.accept 4
]],
      "test.lua"
    )
    env.eq(guide.steps[1].index, 1)
    env.eq(guide.steps[2].index, 2)
    env.eq(guide.steps[3].index, 3)
    env.eq(guide.labels.Foo, 1)
    env.eq(guide.steps[2].completewithIndex, 1)
    env.eq(guide.steps[3].completewithIndex, 4)
    env.eq(guide.steps[1].stepSkip, nil)
  end,
}
