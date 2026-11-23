local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
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
    "src/guides/Registry.lua",
    "src/guides/Suggestions.lua"
  )
end

local function addGuide(TG, text, source)
  TG:RegisterGuideText(text, source)
  TG:BuildGuideIndex()
end

return {
  test_level_range_from_name = function()
    local TG = fresh()
    local lo, hi = TG:GuideLevelRange({ name = "1-12 Durotar", group = "Horde" })
    env.eq(lo, 1)
    env.eq(hi, 12)
  end,

  test_build_index_filters_non_classic = function()
    local TG = fresh()
    addGuide(TG, "#name 1-12 Test\n#group Horde\n#classic 1\nstep\n.accept 1", "test.lua")
    addGuide(TG, "#name Modern\n#group Horde\n#tbc 1\nstep\n.accept 2", "modern.lua")
    env.eq(table.getn(TG.guides), 1)
    env.eq(TG.guides[1].category, "Speedrun")
    env.eq(TG.guides[1].faction, "Horde")
  end,

  test_guide_matches_player = function()
    local TG = fresh()
    local guide = { faction = "Horde", meta = { defaultfor = "Orc/Troll" } }
    env.eq(TG:GuideMatchesPlayer(guide, { faction = "Horde", race = "Orc", class = "MAGE" }), true)
    env.eq(TG:GuideMatchesPlayer(guide, { faction = "Alliance", race = "Human", class = "MAGE" }), false)
  end,

  test_suggestions_use_level = function()
    local TG = fresh()
    _G.UnitLevel = function()
      return 5
    end
    addGuide(TG, "#name 1-12 Durotar\n#group Horde\n#classic 1\nstep\n.accept 1", "test.lua")
    local list = TG:SuggestGuides()
    env.eq(table.getn(list), 1)
    env.eq(list[1].guide.name, "1-12 Durotar")
  end,

  test_picker_groups = function()
    local TG = fresh()
    _G.UnitLevel = function()
      return 5
    end
    addGuide(TG, "#name 1-12 Durotar\n#group Horde\n#classic 1\nstep\n.accept 1", "test.lua")
    local groups = TG:GetGuidesForPicker()
    env.eq(groups[1].name, "Recommended for you")
  end,
}
