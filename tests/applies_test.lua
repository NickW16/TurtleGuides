_G.TurtleGuides = {}
dofile("src/core/Util.lua")
dofile("src/parser/Applies.lua")
local Applies = _G.TurtleGuides.Parser.Applies

local function ctx(overrides)
  local player = {
    class = "MAGE",
    race = "HUMAN",
    race2 = "HUMAN",
    faction = "Alliance",
    level = 12,
    sex = 2,
  }
  for key, value in pairs(overrides or {}) do
    player[key] = value
  end
  return player
end

local function eq(actual, expected, label)
  if actual ~= expected then
    error(label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

local cases = {
  { text = nil, player = {}, expect = true },
  { text = "  ", player = {}, expect = true },
  { text = "10", player = { level = 12 }, expect = true },
  { text = "10", player = { level = 9 }, expect = false },
  { text = "Mage", player = {}, expect = true },
  { text = "Mage", player = { class = "WARRIOR" }, expect = false },
  { text = "!Mage", player = {}, expect = false },
  { text = "!Mage", player = { class = "WARRIOR" }, expect = true },
  { text = "Undead", player = { race = "Undead", race2 = "Scourge" }, expect = true },
  { text = "Scourge", player = { race = "Undead", race2 = "Scourge" }, expect = true },
  { text = "Alliance", player = {}, expect = true },
  { text = "Horde", player = {}, expect = false },
  { text = "Horde-", player = { faction = "Horde" }, expect = true },
  { text = "Horde-", player = {}, expect = false },
  { text = "!Horde-", player = {}, expect = true },
  { text = "Mage Warrior", player = {}, expect = false },
  { text = "Mage Alliance", player = {}, expect = true },
  { text = "Mage/Warrior", player = {}, expect = true },
  { text = "Mage/Warrior", player = { class = "PRIEST" }, expect = false },
  { text = "CLASSIC", player = {}, expect = true },
  { text = "TBC", player = {}, expect = false },
  { text = "HARDCORE", player = {}, expect = false },
  { text = "MALE", player = { sex = 2 }, expect = true },
  { text = "FEMALE", player = { sex = 2 }, expect = false },
  { text = "(Mage/Priest) Alliance", player = {}, expect = true },
  { text = "(Mage/Priest) Alliance", player = { class = "WARRIOR" }, expect = false },
  { text = "!(Horde)", player = {}, expect = true },
  { text = "!(Mage/Priest)", player = {}, expect = false },
  { text = "Unknown", player = {}, expect = false },
}

return {
  test_applies_cases = function()
    for _, case in ipairs(cases) do
      local label = case.text or "nil"
      eq(Applies.evaluate(case.text, ctx(case.player)), case.expect, label)
    end
  end,
}
