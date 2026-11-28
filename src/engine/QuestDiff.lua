-- pure quest log snapshot diff
local TG = _G.TurtleGuides
TG.Engine = TG.Engine or {}
local QuestDiff = {}
TG.Engine.QuestDiff = QuestDiff

local function sortedKeys(rows)
  local keys = {}
  for key in pairs(rows or {}) do
    table.insert(keys, key)
  end
  table.sort(keys)
  return keys
end

function QuestDiff.diff(previous, current)
  local result = { accepted = {}, removed = {} }
  for _, key in ipairs(sortedKeys(current)) do
    if not previous or not previous[key] then
      table.insert(result.accepted, current[key])
    end
  end
  for _, key in ipairs(sortedKeys(previous)) do
    if not current or not current[key] then
      table.insert(result.removed, previous[key])
    end
  end
  return result
end
