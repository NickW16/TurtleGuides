_G.TurtleGuides = {}
dofile("Core/Util.lua")
local Util = _G.TurtleGuides.Util

local function eq(actual, expected)
  if actual ~= expected then
    error("expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

return {
  test_strtrim_removes_padding = function()
    eq(Util.strtrim("  hello  "), "hello")
    eq(Util.strtrim(nil), "")
    eq(Util.strtrim("\thello\n"), "hello")
  end,

  test_split_lines_handles_newline_styles = function()
    local lines = Util.splitLines("a\r\nb\rc\nd")
    eq(#lines, 4)
    eq(lines[1], "a")
    eq(lines[2], "b")
    eq(lines[3], "c")
    eq(lines[4], "d")
  end,

  test_split_lines_handles_empty_input = function()
    eq(#Util.splitLines(nil), 0)
    eq(#Util.splitLines(""), 1)
  end,

  test_copy_defaults_fills_missing_values = function()
    local result = Util.copyDefaults({ a = 1, b = 2 }, { a = 9 })
    eq(result.a, 9)
    eq(result.b, 2)
  end,

  test_copy_defaults_copies_nested_tables = function()
    local source = { nested = { a = 1, b = 2 } }
    local result = Util.copyDefaults(source, { nested = { b = 9 } })
    eq(result.nested.a, 1)
    eq(result.nested.b, 9)
    eq(source.nested.b, 2)
  end,
}
