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
    "src/guides/Registry.lua",
    "src/guides/Suggestions.lua"
  )
end

return {
  test_high_elf_guide_registers = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    env.eq(table.getn(TG.guides), 1)
    local guide = TG.guides[1]
    env.eq(guide.name, "1-10 High Elf (A)")
    env.eq(guide.category, "Turtle Survival")
    env.eq(guide.faction, "Alliance")
    env.eq(guide.defaultFor, "HighElf")
  end,

  test_high_elf_ends_at_level_ten = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guides[1]
    local lastStep = guide.steps[table.getn(guide.steps)]
    local lastElement = lastStep.elements[table.getn(lastStep.elements)]
    env.eq(lastElement.tag, "xp")
    env.eq(lastElement.args[1], "10")
  end,
}
