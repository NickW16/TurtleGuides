-- classic xp values from wispxp/questiedb, octo db values for custom quests
local env = dofile("tests/env.lua")
local xp = {
  [747] = 170, -- The Hunt Begins
  [752] = 85, -- A Humble Task
  [753] = 250, -- A Humble Task
  [3376] = 670, -- Break Sharptusk!
  [750] = 250, -- The Hunt Continues
  [780] = 445, -- The Battleboars
  [763] = 335, -- Rites of the Earthmother
  [745] = 540, -- Sharing the Land
  [767] = 55, -- Rite of Vision
  [746] = 700, -- Dwarven Digging
  [743] = 700, -- Dangers of the Windfury
  [748] = 450, -- Poison Water
  [761] = 680, -- Swoop Hunting
  [766] = 700, -- Mazzranache
  [1656] = 110, -- A Task Unfinished
  [771] = 630, -- Rite of Vision
  [772] = 475, -- Rite of Vision
  [754] = 540, -- Winterhoof Cleansing
  [756] = 630, -- Thunderhorn Totem
  [758] = 700, -- Thunderhorn Cleansing
  [759] = 840, -- Wildmane Totem
  [760] = 1050, -- Wildmane Cleansing
  [861] = 840, -- The Hunter's Way
  [773] = 840, -- Rite of Wisdom
  [833] = 630, -- A Sacred Burial
  [775] = 420, -- Journey into Thunder Bluff
  [770] = 910, -- The Demon Scarred Cloak
  [781] = 355, -- Attack on Camp Narache
  [40583] = 175, -- A Curious Leaf (OctoWow)
  [40584] = 175, -- A Dryad in Mulgore (OctoWow)
  [40585] = 175, -- A Quest For an Antidote (OctoWow)
  [40587] = 275, -- A Dryad's Gratitude (OctoWow)
  [40365] = 840, -- A Trial of Sincerity (OctoWow)
  [40366] = 150, -- An Earnest Offering (OctoWow)
}

local function fresh()
  env.reset()
  _G.UnitFactionGroup = function()
    return "Horde"
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
    "src/guides/Tauren-1-10.lua",
    "src/guides/Registry.lua"
  )
end

return {
  test_all_accepts_have_xp_data = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Mulgore"]
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
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Mulgore"]
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
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Mulgore"]
    local lastStep = guide.steps[table.getn(guide.steps)]
    local lastElement = lastStep.elements[table.getn(lastStep.elements)]
    env.eq(lastElement.tag, "xp")
    env.eq(lastElement.args[1], "10")
  end,
}
