-- quest XP for the 1-10 Teldrassil route, plus OctoWow specific entries
local env = dofile("tests/env.lua")

local xp = {
  [458] = 40, -- The Woodland Protector
  [456] = 170, -- The Balance of Nature
  [457] = 250, -- The Balance of Nature
  [459] = 250, -- The Woodland Protector
  [4495] = 270, -- A Good Friend
  [3519] = 90, -- A Friend in Need
  [3521] = 355, -- Iverron's Antidote
  [3522] = 445, -- Iverron's Antidote
  [916] = 355, -- Webwood Venom
  [917] = 560, -- Webwood Egg
  [920] = 45, -- Tenaron's Summons
  [921] = 335, -- Crown of the Earth
  [928] = 225, -- Crown of the Earth
  [929] = 335, -- Crown of the Earth
  [933] = 780, -- Crown of the Earth
  [2159] = 110, -- Dolanaar Delivery
  [488] = 450, -- Zenn's Bidding
  [997] = 225, -- Denalan's Earth
  [918] = 630, -- Timberling Seeds
  [919] = 790, -- Timberling Sprouts
  [922] = 315, -- Rellian Greenspyre
  [475] = 270, -- A Troubling Breeze
  [476] = 540, -- Gnarlpine Corruption
  [932] = 630, -- Twisted Hatred
  [2438] = 405, -- The Emerald Dreamcatcher
  [489] = 630, -- Seek Redemption!
  [2459] = 880, -- Ferocitas the Dream Eater
  [487] = 700, -- The Road to Darnassus
  [60111] = 975, -- A Decisive Blow (OctoWow specific)
  [40201] = 100, -- Unforeseen Consequences (OctoWow specific)
  [40202] = 100, -- Tesala's Word (OctoWow specific)
  [40203] = 900, -- Rooting Out Corruption (OctoWow specific)
  [40204] = 100, -- A Meeting With Adaena (OctoWow specific)
  [40205] = 900, -- Securing Darnassus (OctoWow specific)
}

local guideKey = "Turtle Guides (A)||1-10 Teldrassil"

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
    "src/guides/NightElf-1-10.lua",
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
