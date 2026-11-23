local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  _G.UnitFactionGroup = function()
    return "Alliance"
  end
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/core/Output.lua",
    "src/core/State.lua",
    "src/parser/Applies.lua",
    "src/parser/Context.lua",
    "src/parser/Elements.lua",
    "src/parser/Guide.lua",
    "src/parser/Registry.lua",
    "src/guides/HighElf-1-10.lua",
    "src/guides/Human-1-10.lua",
    "src/guides/Registry.lua",
    "src/guides/Suggestions.lua"
  )
end

return {
  test_human_guide_registers = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    env.eq(table.getn(TG.guides), 2)
    local guide = TG.guideByKey["Turtle Guides (A)||1-10 Elwynn Forest"]
    env.eq(guide ~= nil, true)
    env.eq(guide.defaultFor, "Human")
    env.eq(guide.next, "10-16 Westfall")
  end,

  test_human_guide_ends_at_level_ten = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Turtle Guides (A)||1-10 Elwynn Forest"]
    local lastStep = guide.steps[table.getn(guide.steps)]
    local lastElement = lastStep.elements[table.getn(lastStep.elements)]
    env.eq(lastElement.tag, "xp")
    env.eq(lastElement.args[1], "10")
  end,
}
