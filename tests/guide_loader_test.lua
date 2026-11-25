local env = dofile("tests/env.lua")

local guideText = [[
#name 1-12 Test Zone
#group Turtle Test Guides
#classic
#defaultfor Undead/Mage
<< Horde
step
.accept 1 >> Accept Test Quest
.goto Test Zone,10,20
step
.turnin 1 >> Turn in Test Quest
]]

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/core/Output.lua",
    "src/core/Events.lua",
    "src/core/State.lua",
    "src/parser/Applies.lua",
    "src/parser/Context.lua",
    "src/parser/Elements.lua",
    "src/parser/Guide.lua",
    "src/parser/Registry.lua",
    "src/guides/Registry.lua",
    "src/guides/Loader.lua"
  )
end

return {
  test_meta_index_defers_steps = function()
    local TG = fresh()
    TG:RegisterGuideText(guideText, "test.lua")
    TG:BuildGuideMetaIndex()
    local guide = TG.guideByKey["Turtle Test Guides||1-12 Test Zone"]
    env.eq(guide ~= nil, true)
    env.eq(guide.name, "1-12 Test Zone")
    env.eq(guide.category, "Turtle Survival")
    env.eq(guide.faction, "Horde")
    env.eq(table.getn(guide.steps), 0)
    env.eq(guide._fullyParsed, false)
    env.eq(guide._rawBytes > 0, true)
  end,

  test_meta_index_filters_non_classic = function()
    local TG = fresh()
    TG:RegisterGuideText("#name Modern\n#group Horde\n#tbc 1\nstep\n.accept 1", "modern.lua")
    TG:BuildGuideMetaIndex()
    env.eq(table.getn(TG.guides), 0)
  end,

  test_ensure_guide_parsed_fills_steps = function()
    local TG = fresh()
    TG:RegisterGuideText(guideText, "test.lua")
    TG:BuildGuideMetaIndex()
    local guide = TG.guides[1]
    TG:EnsureGuideParsed(guide)
    env.eq(guide._fullyParsed, true)
    env.eq(table.getn(guide.steps), 2)
    env.eq(guide.steps[1].elements[1].tag, "accept")
    env.eq(guide._raw, nil)
  end,

  test_background_loader_parses_over_frames = function()
    local TG = fresh()
    TG:RegisterGuideText(guideText, "test.lua")
    TG:LoadAllGuides()
    env.eq(TG.updaters.guideLoader ~= nil, true)
    local runs = 0
    while TG._guideLoader do
      TG.updaters.guideLoader.fn()
      runs = runs + 1
      if runs > 10 then
        error("background loader did not finish", 2)
      end
    end
    env.eq(runs, 1)
    env.eq(TG.updaters.guideLoader, nil)
    env.eq(table.getn(TG.guides[1].steps), 2)
  end,

  test_background_loader_skips_opposite_faction = function()
    local TG = fresh()
    TG:RegisterGuideText(
      [[
#name 1-12 Alliance Test
#group Alliance Guides
#classic
#defaultfor Human
step
.accept 1 >> Accept Alliance Quest
]],
      "alliance.lua"
    )
    TG:RegisterGuideText(
      [[
#name 1-12 Horde Test
#group Horde Guides
#classic
#defaultfor Undead
step
.accept 2 >> Accept Horde Quest
]],
      "horde.lua"
    )
    TG:LoadAllGuides()
    env.eq(table.getn(TG._guideLoader.queue), 1)
    env.eq(TG._guideLoader.queue[1].faction, "Horde")
  end,

  test_set_guide_parses_on_demand = function()
    local TG = fresh()
    TG:RegisterGuideText(guideText, "test.lua")
    TG:BuildGuideMetaIndex()
    env.load("src/engine/State.lua", "src/engine/Navigation.lua")
    env.eq(TG:SetGuide("Turtle Test Guides||1-12 Test Zone", 1, true), true)
    env.eq(table.getn(TG.currentGuide.steps), 2)
    env.eq(TG.currentGuide._fullyParsed, true)
  end,
}
