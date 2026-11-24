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
}
