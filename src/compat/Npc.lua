-- npc name and spawn lookup
local TG = _G.TurtleGuides

local nameCache = {}

local function editDistance(a, b, limit)
  if a == b then
    return 0
  end
  local lenA, lenB = string.len(a), string.len(b)
  if math.abs(lenA - lenB) > limit then
    return limit + 1
  end
  local previous, current = {}, {}
  for index = 1, lenB + 1 do
    previous[index] = index - 1
  end
  for i = 1, lenA do
    current[1] = i
    local rowMin = current[1]
    for j = 1, lenB do
      local cost = string.sub(a, i, i) == string.sub(b, j, j) and 0 or 1
      current[j + 1] = math.min(current[j] + 1, previous[j + 1] + 1, previous[j] + cost)
      if current[j + 1] < rowMin then
        rowMin = current[j + 1]
      end
    end
    if rowMin > limit then
      return limit + 1
    end
    previous, current = current, previous
  end
  return previous[lenB + 1]
end

local function cleanName(name)
  if not name then
    return nil
  end
  name = string.gsub(name, "|c%x%x%x%x%x%x%x%x", "")
  name = string.gsub(name, "|r", "")
  name = string.gsub(name, "^%s*(.-)%s*$", "%1")
  if name == "" then
    return nil
  end
  return string.lower(name)
end

function TG:NpcIdByName(name)
  local key = cleanName(name)
  if not key then
    return nil
  end
  if nameCache[key] ~= nil then
    return nameCache[key]
  end
  local ids
  if pfDatabase and type(pfDatabase.GetIDByName) == "function" then
    local found = pfDatabase:GetIDByName(name, "units", "LOWER")
    ids = next(found or {})
  end
  if not ids and pfDB and type(pfDB.units) == "table" then
    local limit = string.len(key) > 8 and 2 or 1
    local best, bestDistance = nil, limit + 1
    for id, loc in pairs(pfDB.units["loc"] or pfDB.units["enUS"] or {}) do
      local value = type(loc) == "table" and (loc.T or loc.t or loc[1]) or loc
      if type(value) == "string" then
        local candidate = string.lower(value)
        local distance = editDistance(key, candidate, limit)
        if distance < bestDistance then
          best, bestDistance = id, distance
          if distance == 0 then
            break
          end
        end
      end
    end
    ids = bestDistance <= limit and best or nil
  end
  nameCache[key] = ids or false
  return nameCache[key] or nil
end

function TG:NpcLocation(id)
  id = tonumber(id)
  if not id or not pfDB or type(pfDB.units) ~= "table" then
    return nil
  end
  local data = pfDB.units["data"] and pfDB.units["data"][id]
  local coords = data and data.coords
  if type(coords) ~= "table" then
    return nil
  end
  local current = GetZoneText and GetZoneText() or ""
  local fallback
  for _, entry in pairs(coords) do
    local x, y, zone = entry[1], entry[2], entry[3]
    if x and y and zone and zone > 0 then
      local zoneName = tostring(zone)
      if type(self.ZoneNameFromId) == "function" then
        zoneName = self:ZoneNameFromId(zone) or zoneName
      end
      local candidate = { zone = zoneName, x = x, y = y }
      if current ~= "" and self.ZoneMatches and self:ZoneMatches(current, zoneName) then
        return candidate
      end
      fallback = fallback or candidate
    end
  end
  return fallback
end

function TG:StepNpcLocation(step)
  if not step then
    return nil
  end
  local function resolve(name)
    if not name then
      return nil
    end
    name = string.gsub(name, "^%s*(.-)%s*$", "%1")
    if name == "" then
      return nil
    end
    local id = self:NpcIdByName(name)
    return id and self:NpcLocation(id) or nil
  end
  local plainPatterns = {
    "[Tt]alk to ([^%.,%!%?%|%[%]\n]+)",
    "[Ss]peak to ([^%.,%!%?%|%[%]\n]+)",
    "[Ss]peak with ([^%.,%!%?%|%[%]\n]+)",
    "[Tt]rain with ([^%.,%!%?%|%[%]\n]+)",
    "[Vv]isit ([^%.,%!%?%|%[%]\n]+)",
    "[Ff]ind ([^%.,%!%?%|%[%]\n]+)",
  }
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (el.tag == "mob" or el.sourceTag == "target") then
      local location = resolve(el.args and el.args[1] or el.text)
      if location then
        return location
      end
    end
    local text = el.text
    if text then
      for name in string.gmatch(text, "|cRXP_FRIENDLY_([^|]+)|r") do
        local location = resolve(name)
        if location then
          return location
        end
      end
      for name in string.gmatch(text, "|cRXP_ENEMY_([^|]+)|r") do
        local location = resolve(name)
        if location then
          return location
        end
      end
      local plain = TG.stripCodes and TG.stripCodes(text) or text
      for _, pattern in ipairs(plainPatterns) do
        for name in string.gmatch(plain, pattern) do
          local location = resolve(name)
          if location then
            return location
          end
        end
      end
    end
  end
  return nil
end
