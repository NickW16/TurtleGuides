local env = dofile("tests/env.lua")

-- Blackstone Island quest XP from the OctoWow database RewXP field
local xp = {
  [80120] = 200, -- Garbage Man
  [41150] = 170, -- Defunct Mainframes
  [41151] = 170, -- Haywire Havoc
  [41152] = 340, -- DV-500
  [41153] = 250, -- Foreman Pipelatch
  [41154] = 170, -- Pit-Iful Work
  [41155] = 70, -- The Robotics Expert
  [41156] = 70, -- Foreman's Blues
  [41157] = 70, -- Delayed Shipments
  [41158] = 360, -- Revenge of the Deep
  [41159] = 180, -- Dirty Deeds Drowned Deep Below
  [41160] = 180, -- Under The Sea
  [41161] = 470, -- The Supercutter 1500
  [41162] = 630, -- Clearing Nuisances
  [41163] = 410, -- Battletron Calamity
  [41164] = 420, -- Salvaging Convoys
  [41165] = 110, -- Dry As A Desert
  [41166] = 280, -- Redistribution
  [41167] = 470, -- The Murloc Threat
  [41168] = 370, -- Maritime Gumbo
  [41169] = 120, -- Bearer Of Bad News
  [41170] = 120, -- Solutions On Their Way
  [41171] = 470, -- Searching Wreckage
  [41172] = 580, -- War on Venture Co.
  [41173] = 780, -- Destroying Venture Co. Leadership
  [41174] = 480, -- Workplace Hazard
  [41175] = 480, -- Mudpaw Mining Mishap
  [41176] = 470, -- She Sells Sea Shells
  [41183] = 780, -- Ashen Pelts
  [41184] = 560, -- Right From Under My Green Nose
  [41185] = 780, -- War On Mudpaw
  [41186] = 880, -- Grabb Mudhide
  [41264] = 680, -- Disruption at Black Ash Mine
  [41265] = 480, -- Disruption at Rustgate Lumber Yard
  [41266] = 40, -- The Big Man
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
    "src/guides/Goblin-1-10.lua",
    "src/guides/Registry.lua"
  )
end

return {
  test_all_accepts_have_xp_data = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Blackstone Island"]
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
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Blackstone Island"]
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
    env.eq(total >= 3000, true, "quest XP total " .. total .. " below 3000")
  end,

  test_guide_still_ends_at_level_ten = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Turtle Guides (H)||1-10 Blackstone Island"]
    local lastStep = guide.steps[table.getn(guide.steps)]
    local lastElement = lastStep.elements[table.getn(lastStep.elements)]
    env.eq(lastElement.tag, "xp")
    env.eq(lastElement.args[1], "10")
  end,
}
