-- pure helpers shared by state and parsing modules
local TG = _G.TurtleGuides
local Util = {}
TG.Util = Util

function Util.strtrim(s)
  if not s then
    return ""
  end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  return s
end

function Util.splitLines(text)
  local lines = {}
  if not text then
    return lines
  end
  text = string.gsub(text, "\r\n", "\n")
  text = string.gsub(text, "\r", "\n")
  local pos = 1
  while true do
    local start, finish = string.find(text, "\n", pos, true)
    if not start then
      table.insert(lines, string.sub(text, pos))
      break
    end
    table.insert(lines, string.sub(text, pos, start - 1))
    pos = finish + 1
  end
  return lines
end

function Util.copyDefaults(src, dst)
  if type(dst) ~= "table" then
    dst = {}
  end
  for key, value in pairs(src) do
    if type(value) == "table" then
      dst[key] = Util.copyDefaults(value, dst[key])
    elseif dst[key] == nil then
      dst[key] = value
    end
  end
  return dst
end
