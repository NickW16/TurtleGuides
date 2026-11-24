local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/ui/State.lua", "src/ui/Theme.lua", "src/ui/TextWrap.lua")
end

return {
  test_short_text_stays_on_one_line = function()
    local TG = fresh()
    local wrapped, lines = TG.UI.TextWrap.wrap("Accept the quest", 200, 10)
    env.eq(wrapped, "Accept the quest")
    env.eq(lines, 1)
  end,

  test_long_text_wraps_with_explicit_newlines = function()
    local TG = fresh()
    local wrapped, lines = TG.UI.TextWrap.wrap("one two three four five six seven eight", 50, 10)
    env.eq(lines > 1, true)
    env.eq(string.find(wrapped, "\n", 1, true) ~= nil, true)
  end,

  test_existing_newlines_are_preserved = function()
    local TG = fresh()
    local wrapped, lines = TG.UI.TextWrap.wrap("first\nsecond", 200, 10)
    env.eq(wrapped, "first\nsecond")
    env.eq(lines, 2)
  end,

  test_color_codes_do_not_change_wrapping = function()
    local TG = fresh()
    local _, plainLines = TG.UI.TextWrap.wrap("one two three four five six", 70, 10)
    local colored, coloredLines = TG.UI.TextWrap.wrap("|cff66ff66one|r two three four five six", 70, 10)
    env.eq(coloredLines, plainLines)
    env.eq(string.find(colored, "|cff66ff66", 1, true) ~= nil, true)
  end,

  test_height_scales_with_line_count = function()
    local TG = fresh()
    local _, one = TG.UI.TextWrap.wrapAndHeight("short", 200, 10)
    local _, many = TG.UI.TextWrap.wrapAndHeight("one two three four five six seven eight", 50, 10)
    env.eq(many > one, true)
  end,
}
