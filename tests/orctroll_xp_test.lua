-- classic xp values from wispxp/questiedb, octo db values for custom quests
local env = dofile("tests/env.lua")
local xp = {
  [4641] = 40, -- Your Place In The World
  [788] = 170, -- Cutting Teeth
  [4402] = 380, -- Galgar's Cactus Apple Surprise
  [789] = 250, -- Sting of the Scorpid
  [5441] = 445, -- Lazy Peons
  [6394] = 445, -- Thazz'ril's Pick
  [2161] = 110, -- A Peon's Burden
  [790] = 450, -- Sarkoth
  [804] = 110, -- Sarkoth
  [794] = 670, -- Burning Blade Medallion
  [805] = 225, -- Report to Sen'jin Village
  [808] = 780, -- Minshina's Skull
  [826] = 840, -- Zalazane
  [823] = 315, -- Report to Orgnil
  [817] = 700, -- Practical Prey
  [818] = 630, -- A Solvent Spirit
  [786] = 700, -- Thwarting Kolkar Aggression
  [806] = 910, -- Dark Storms
  [834] = 780, -- Winds in the Desert
  [831] = 630, -- The Admiral's Orders
  [784] = 630, -- Vanquish the Betrayers
  [837] = 630, -- Encroachment
  [825] = 700, -- From The Wreckage....
  [815] = 700, -- Break a Few Eggs
  [791] = 630, -- Carry Your Weight
  [835] = 880, -- Securing the Lines
  [812] = 980, -- Need for a Cure
  [827] = 910, -- Skull Rock
  [829] = 455, -- Neeru Fireblade
  [832] = 680, -- Burning Shadows
  [840] = 455, -- Conscript of the Horde
  [40390] = 880, -- Aggression's End (OctoWow)
  [40391] = 210, -- A Hunt for Honor (OctoWow)
  [55003] = 375, -- A New Power Source (OctoWow)
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
    "src/guides/OrcTroll-1-10.lua",
    "src/guides/Registry.lua"
  )
end

return {
  test_all_accepts_have_xp_data = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Durotar"]
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
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Durotar"]
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
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Durotar"]
    local lastStep = guide.steps[table.getn(guide.steps)]
    local lastElement = lastStep.elements[table.getn(lastStep.elements)]
    env.eq(lastElement.tag, "xp")
    env.eq(lastElement.args[1], "10")
  end,
}
