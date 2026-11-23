-- luacheck: push ignore 122 142 143
-- lua runtime shims for the 1.12 client
local TG = _G.TurtleGuides
local m, s = math, string

if not m.atan2 then
  m.atan2 = function(y, x)
    if x > 0 then
      return m.atan(y / x)
    end
    if x < 0 and y >= 0 then
      return m.atan(y / x) + m.pi
    end
    if x < 0 and y < 0 then
      return m.atan(y / x) - m.pi
    end
    if x == 0 and y > 0 then
      return m.pi / 2
    end
    if x == 0 and y < 0 then
      return -m.pi / 2
    end
    return 0
  end
end
TG.math_atan2 = m.atan2

if not m.mod then
  m.mod = m.fmod or function(a, b)
    return a - m.floor(a / b) * b
  end
end
if not m.fmod then
  m.fmod = m.mod
end

if not s.match then
  s.match = function(text, pattern, init)
    local from, to, c1, c2, c3, c4, c5, c6, c7, c8 = s.find(text, pattern, init)
    if not from then
      return nil
    end
    if c1 ~= nil then
      return c1, c2, c3, c4, c5, c6, c7, c8
    end
    return s.sub(text, from, to)
  end
end

if not s.gmatch then
  s.gmatch = s.gfind
end

function TG:CollectGarbage()
  if not collectgarbage then
    return
  end
  local ok = pcall(collectgarbage, "collect")
  if not ok then
    pcall(collectgarbage, 0)
  end
end

-- luacheck: pop
