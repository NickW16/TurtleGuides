local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("Core.lua", "Compat/Text.lua")
end

return {
  test_strip_codes_removes_markup = function()
    local TG = fresh()
    local out = TG.stripCodes("|cRXP_FRIENDLY_Bob|r and |cffff0000red|r and |Hitem:1|hThing|h")
    assert(string.find(out, "RXP", 1, true) == nil)
    assert(string.find(out, "|c", 1, true) == nil)
    assert(string.find(out, "Thing", 1, true) ~= nil)
  end,

  test_clean_rxp_colors_maps_known_tags = function()
    local TG = fresh()
    local out = TG.cleanRxpColors("|cRXP_FRIENDLY_Bob|r")
    env.eq(out, "|cff00ff00Bob|r")
  end,
}
