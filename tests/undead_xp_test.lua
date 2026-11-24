local env = dofile("tests/env.lua")

-- classic quest XP from WispXP (QuestieDB Classic table)
local xp = {
  [363] = 40, -- Rude Awakening
  [364] = 170, -- The Mindless Ones
  [376] = 170, -- The Damned
  [3901] = 250, -- Rattling the Rattlecages
  [3902] = 315, -- Scavenging Deathknell
  [380] = 355, -- Night Web's Hollow
  [381] = 355, -- The Scarlet Crusade
  [6395] = 450, -- Marla's Last Wish
  [382] = 670, -- The Red Messenger
  [383] = 335, -- Vital Intelligence
  [8] = 110, -- A Rogue's Deal
  [5481] = 225, -- Gordo's Task
  [5482] = 540, -- Doom Weed
  [365] = 630, -- Fields of Grief
  [404] = 405, -- A Putrid Task
  [367] = 540, -- A New Plague
  [426] = 880, -- The Mills Overrun
  [368] = 780, -- A New Plague
  [375] = 700, -- The Chill of Death
  [427] = 700, -- At War With The Scarlet Crusade
  [370] = 780, -- At War With The Scarlet Crusade
  [372] = 840, -- At War With The Scarlet Crusade
  [374] = 630, -- Proof of Demise
  [398] = 840, -- Wanted: Maggot Eye
  [358] = 700, -- Graverobbers
  [407] = 160, -- Fields of Grief
  [405] = 175, -- The Prodigal Lich
  [355] = 85, -- Speak with Sevren
  [359] = 195, -- Forsaken Duties
  [362] = 420, -- The Haunted Mills
  [366] = 350, -- Return the Book
  [445] = 630, -- Delivery to Silverpine Forest
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
    "src/guides/Undead-1-10.lua",
    "src/guides/Registry.lua"
  )
end

return {
  test_all_accepts_have_xp_data = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Tirisfal Glades"]
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
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Tirisfal Glades"]
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
    env.eq(total >= 14000, true, "quest XP total " .. total .. " below 14000")
  end,

  test_guide_still_ends_at_level_ten = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Tirisfal Glades"]
    local lastStep = guide.steps[table.getn(guide.steps)]
    local lastElement = lastStep.elements[table.getn(lastStep.elements)]
    env.eq(lastElement.tag, "xp")
    env.eq(lastElement.args[1], "10")
  end,
}
