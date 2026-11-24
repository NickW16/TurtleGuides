-- quest XP for the 1-10 Dun Morogh route, plus OctoWow specific entries
local env = dofile("tests/env.lua")

local xp = {
  [179] = 80, -- Dwarven Outfitters
  [170] = 170, -- A New Threat
  [233] = 190, -- Coldridge Valley Mail Delivery
  [3361] = 250, -- A Refugee's Quandary
  [234] = 270, -- Coldridge Valley Mail Delivery
  [183] = 250, -- The Boar Hunter
  [182] = 355, -- The Troll Cave
  [218] = 560, -- The Stolen Journal
  [282] = 335, -- Senir's Observations
  [420] = 335, -- Senir's Observations
  [2160] = 110, -- Supplies to Tannok
  [400] = 110, -- Tools for Steelgrill
  [5541] = 540, -- Ammo for Rumbleshot
  [317] = 680, -- Stocking Jetsteam
  [313] = 630, -- The Grizzled Den
  [318] = 160, -- Evershine
  [319] = 530, -- A Favor for Evershine
  [320] = 880, -- Return to Bellowfiz
  [315] = 780, -- The Perfect Stout
  [310] = 135, -- Bitter Rivals
  [311] = 630, -- Return to Marleth
  [287] = 590, -- Frostmane Hold
  [412] = 840, -- Operation Recombobulation
  [312] = 910, -- Tundra MacGrann's Stolen Stash
  [41640] = 660, -- Restless (OctoWow specific)
  [60114] = 1042, -- The Terror of Chill Breeze (OctoWow specific)
}

local guideKey = "Turtle Guides (A)||1-10 Dun Morogh"

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
    "src/guides/DwarfGnome-1-10.lua",
    "src/guides/Registry.lua"
  )
end

return {
  test_all_accepts_have_xp_data = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey[guideKey]
    for _, step in ipairs(guide.steps) do
      for _, el in ipairs(step.elements) do
        if el.t == "cmd" and el.tag == "accept" then
          local id = tonumber(el.args and el.args[1])
          env.eq(xp[id] ~= nil, true, "missing XP for quest " .. tostring(id))
        end
      end
    end
  end,

  test_quest_xp_budget = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey[guideKey]
    local seen, total = {}, 0
    for _, step in ipairs(guide.steps) do
      for _, el in ipairs(step.elements) do
        if el.t == "cmd" and el.tag == "accept" then
          local id = tonumber(el.args and el.args[1])
          if id and not seen[id] and xp[id] then
            seen[id] = true
            total = total + xp[id]
          end
        end
      end
    end
    env.eq(total >= 10000, true, "quest XP total " .. total .. " below 10000")
  end,

  test_guide_still_ends_at_level_ten = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey[guideKey]
    local lastStep = guide.steps[table.getn(guide.steps)]
    local lastElement = lastStep.elements[table.getn(lastStep.elements)]
    env.eq(lastElement.tag, "xp")
    env.eq(lastElement.args[1], "10")
  end,
}
