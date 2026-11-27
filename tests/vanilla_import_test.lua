local env = dofile("tests/env.lua")

local guideFiles = {
  "src/guides/Speedrun-Alliance-NightElf-1-10.lua",
  "src/guides/Speedrun-Alliance-Human-1-13.lua",
  "src/guides/Speedrun-Alliance-DwarfGnome-1-14.lua",
  "src/guides/Speedrun-Alliance-11-20.lua",
  "src/guides/Speedrun-Alliance-Mage-AoE-1-22.lua",
  "src/guides/Speedrun-Alliance-Mage-1-12.lua",
  "src/guides/Speedrun-Alliance-Mage-12-21.lua",
  "src/guides/Speedrun-Horde-Durotar-1-12.lua",
  "src/guides/Speedrun-Horde-Undead-1-14.lua",
  "src/guides/Speedrun-Horde-Mulgore-1-12.lua",
  "src/guides/Speedrun-Horde-Barrens-12-22.lua",
  "src/guides/Speedrun-Horde-Mage-12-21.lua",
  "src/guides/Speedrun-Era-Custom-1-60.lua",
  "src/guides/Survival-Alliance-NightElf-1-10.lua",
  "src/guides/Survival-Alliance-Human-1-13.lua",
  "src/guides/Survival-Alliance-DwarfGnome-1-14.lua",
  "src/guides/Survival-Alliance-NightElf-11-16.lua",
  "src/guides/Survival-Alliance-11-20.lua",
  "src/guides/Survival-Alliance-Hardcore-18-19-LochModan.lua",
  "src/guides/Survival-Alliance-Hardcore-19-20-Redridge.lua",
  "src/guides/Survival-Custom-1-60.lua",
  "src/guides/Survival-Horde-Durotar-1-13.lua",
  "src/guides/Survival-Horde-Undead-1-13.lua",
  "src/guides/Survival-Horde-Mulgore-1-13.lua",
  "src/guides/Survival-Horde-Silverpine-13-15.lua",
  "src/guides/Survival-Horde-Barrens-15-23.lua",
}

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
    unpack(guideFiles)
  )
end

local function header(text)
  return text:match("^(.-)\nstep") or text
end

return {
  test_vanilla_import_registers_all_guides = function()
    local TG = fresh()
    env.eq(table.getn(TG.rawGuides), 238)
  end,

  test_vanilla_import_headers_are_clean = function()
    local TG = fresh()
    for _, entry in ipairs(TG.rawGuides) do
      local head = header(entry.text)
      local low = head:lower()
      for _, word in ipairs({ "rxp", "restedxp", "sod", "som", "tbc", "wotlk", "wrath", "retail" }) do
        if low:find(word, 1, true) then
          error("imported header mentions " .. word .. ": " .. entry.source, 2)
        end
      end
      if not low:find("#classic", 1, true) then
        error("imported guide is missing #classic: " .. entry.source, 2)
      end
    end
  end,

  test_survival_guides_have_no_softcore_or_deathskip_steps = function()
    local TG = fresh()
    for _, entry in ipairs(TG.rawGuides) do
      if string.find(entry.source or "", "Survival%-", 1) then
        local low = string.lower(entry.text)
        if low:find("#softcore", 1, true) or low:find(".deathskip", 1, true) then
          error("survival guide still has softcore/deathskip content: " .. entry.source, 2)
        end
      end
    end
  end,

  test_vanilla_import_guides_parse = function()
    local TG = fresh()
    for i, entry in ipairs(TG.rawGuides) do
      local head = header(entry.text)
      _G.UnitFactionGroup = function()
        if head:find("<< Horde", 1, true) then
          return "Horde"
        end
        return "Alliance"
      end
      local guide, reason = TG.Parser.ParseGuide(entry.text, entry.source)
      if not guide and reason ~= "not applicable" then
        error("guide " .. i .. " failed to parse: " .. tostring(reason), 2)
      end
    end
  end,

  test_vanilla_import_index_builds_for_both_factions = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    if table.getn(TG.guides) == 0 then
      error("no Horde guides indexed", 2)
    end
    _G.UnitFactionGroup = function()
      return "Alliance"
    end
    TG:BuildGuideIndex()
    if table.getn(TG.guides) == 0 then
      error("no Alliance guides indexed", 2)
    end
  end,

  test_southern_barrens_safe_route_is_available_to_horde = function()
    local TG = fresh()
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Classic Survival Horde||25-27 Southern Barrens/Stonetalon"]
    env.eq(guide ~= nil, true, "Horde Southern Barrens/Stonetalon safe route missing")
    env.eq(guide and guide.category, "Survival", "wrong category for Southern Barrens/Stonetalon safe route")
  end,

  test_tundra_macgrann_talk_step_has_no_backtrack_waypoints = function()
    local TG = fresh()
    _G.UnitFactionGroup = function()
      return "Alliance"
    end
    _G.UnitRace = function()
      return "Gnome", "Gnome"
    end
    _G.UnitClass = function()
      return "Warrior", "WARRIOR"
    end
    TG:BuildGuideIndex()
    local guide = TG.guideByKey["Classic Survival Alliance||6-10 Dun Morogh"]
    env.eq(guide ~= nil, true, "survival Dun Morogh guide missing")
    local found = false
    for _, step in ipairs(guide.steps) do
      local hasAccept = false
      for _, el in ipairs(step.elements) do
        if el.t == "cmd" and el.tag == "accept" and tostring(el.args and el.args[1]) == "312" then
          hasAccept = true
        end
      end
      if hasAccept then
        found = true
        local gotos = {}
        for _, el in ipairs(step.elements) do
          if el.t == "cmd" and el.tag == "goto" then
            table.insert(
              gotos,
              tostring(el.args and el.args[1])
                .. ","
                .. tostring(el.args and el.args[2])
                .. ","
                .. tostring(el.args and el.args[3])
            )
          end
        end
        env.eq(table.getn(gotos), 1, "Tundra MacGrann step has backtrack waypoints")
        env.eq(gotos[1], "Dun Morogh,34.577,51.652", "wrong Tundra MacGrann waypoint")
      end
    end
    env.eq(found, true, "Tundra MacGrann accept step missing")
  end,
}
