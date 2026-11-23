-- luacheck: push ignore 122 142 143
-- verifies runtime shims install functions missing from older clients
return {
  test_gmatch_fallback = function()
    local s = string
    local originalGmatch = s.gmatch
    local originalGfind = s.gfind
    s.gfind = function(text, pattern)
      return originalGmatch(text, pattern)
    end
    s.gmatch = nil
    _G.TurtleGuides = {}
    dofile("src/compat/Runtime.lua")
    local first = s.gmatch("a b", "%S")()
    s.gmatch = originalGmatch
    s.gfind = originalGfind
    assert(first == "a")
  end,

  test_atan2_fallback = function()
    local m = math
    local original = m.atan2
    m.atan2 = nil
    _G.TurtleGuides = {}
    dofile("src/compat/Runtime.lua")
    local value = m.atan2(1, 1)
    m.atan2 = original
    assert(m.abs(value - m.pi / 4) < 0.0001)
  end,

  test_collect_garbage_is_callable = function()
    _G.TurtleGuides = {}
    dofile("src/compat/Runtime.lua")
    _G.TurtleGuides:CollectGarbage()
  end,
}

-- luacheck: pop
