-- zone names, map ids, and world coordinate helpers
local TG = _G.TurtleGuides
local zoneData = TG.ZoneData

local function normalizeZoneName(s)
  if s == nil then
    return ""
  end
  s = string.lower(tostring(s))
  s = string.gsub(s, "[^%w]", "")
  return s
end

local MAP_ZONE_NAMES = {}
local ZONE_NAME_TO_MAPID = {}
for id, name in pairs(zoneData) do
  local n = normalizeZoneName(name)
  MAP_ZONE_NAMES[n] = true
  if n ~= "" and not ZONE_NAME_TO_MAPID[n] then
    ZONE_NAME_TO_MAPID[n] = id
  end
end

function TG:ZoneNameFromId(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  if pfDB and pfDB["zones"] then
    local loc = pfDB["zones"]["loc"] or pfDB["zones"]["enUS"] or pfDB["zones"][GetLocale() or "enUS"]
    if loc and loc[id] then
      return loc[id]
    end
  end
  return zoneData[id]
end

function TG:ZoneName(zone)
  if zone == nil then
    return ""
  end
  local num = tonumber(zone)
  if num then
    return self:ZoneNameFromId(num) or "Map " .. tostring(num)
  end
  return tostring(zone)
end

local function pfZoneIdByName(name)
  if not pfDB or type(pfDB["zones"]) ~= "table" then
    return nil
  end
  local want = normalizeZoneName(name)
  for _, tbl in pairs(pfDB["zones"]) do
    if type(tbl) == "table" then
      for id, zoneName in pairs(tbl) do
        if type(zoneName) == "string" and normalizeZoneName(zoneName) == want then
          return tonumber(id)
        end
      end
    end
  end
end

local function pfParentMapId(areaId)
  if not pfDB or type(pfDB["zones"]) ~= "table" then
    return nil
  end
  local data = pfDB["zones"]["data"] or pfDB["zones"]["data-tbc"]
  local entry = data and data[areaId]
  if type(entry) ~= "table" or not entry[1] then
    return nil
  end
  local parentName = pfDB["zones"]["loc"] and pfDB["zones"]["loc"][entry[1]]
  if not parentName then
    local loc = pfDB["zones"][GetLocale() or "enUS"] or pfDB["zones"]["enUS"]
    parentName = loc and loc[entry[1]]
  end
  if not parentName then
    for _, tbl in pairs(pfDB["zones"]) do
      if type(tbl) == "table" and type(tbl[entry[1]]) == "string" then
        parentName = tbl[entry[1]]
        break
      end
    end
  end
  local n = normalizeZoneName(parentName)
  return n ~= "" and ZONE_NAME_TO_MAPID[n] or nil
end

local zoneIdCache = {}

function TG:ZoneIdByName(name)
  local num = tonumber(name)
  if num then
    return num
  end
  local n = normalizeZoneName(name)
  if n == "" then
    return nil
  end
  if zoneIdCache[n] ~= nil then
    return zoneIdCache[n] or nil
  end
  local mapId = ZONE_NAME_TO_MAPID[n]
  if not mapId then
    local areaId = pfZoneIdByName(n)
    if areaId then
      mapId = pfParentMapId(areaId) or areaId
    end
  end
  zoneIdCache[n] = mapId or false
  return mapId
end

-- client coordinate helpers may return y first, normalize to world x, y
local worldPosCache = {}

local function vectorXY(v)
  if type(v) ~= "table" and type(v) ~= "userdata" then
    return nil
  end
  if type(v.GetXY) == "function" then
    local ok, a, b = pcall(v.GetXY, v)
    if ok and type(a) == "number" and type(b) == "number" then
      return a, b
    end
  end
  if type(v.x) == "number" and type(v.y) == "number" then
    return v.x, v.y
  end
end

function TG:ClearWorldPosCache()
  worldPosCache = {}
end

function TG:PlayerWorldPos()
  if not UnitPosition then
    return nil
  end
  local ok, y, x, instance = pcall(UnitPosition, "player")
  if ok and type(x) == "number" and type(y) == "number" then
    return x, y, tonumber(instance) or nil
  end
end

function TG:WorldPosFromMapPos(id, x, y)
  if not id or not C_Map or not C_Map.GetWorldPosFromMapPos then
    return nil
  end
  x, y = tonumber(x), tonumber(y)
  if not x or not y then
    return nil
  end
  local key = tostring(id) .. ":" .. tostring(x) .. ":" .. tostring(y)
  local cached = worldPosCache[key]
  if cached ~= nil then
    if cached == false then
      return nil
    end
    return cached.x, cached.y, cached.instance
  end
  local vec
  if CreateVector2D then
    vec = CreateVector2D(x / 100, y / 100)
  else
    vec = { x = x / 100, y = y / 100 }
  end
  local ok, a, b = pcall(C_Map.GetWorldPosFromMapPos, id, vec)
  if not ok then
    worldPosCache[key] = false
    return nil
  end
  local instance, first, second
  if type(a) == "number" and (type(b) == "table" or type(b) == "userdata") then
    instance = a
    first, second = vectorXY(b)
  else
    first, second = vectorXY(a)
    if type(b) == "number" then
      instance = b
    end
  end
  if first and second then
    local result = { x = second, y = first, instance = tonumber(instance) or nil }
    worldPosCache[key] = result
    return result.x, result.y, result.instance
  end
  worldPosCache[key] = false
  return nil
end

function TG:ZoneWorldPos(zone, x, y)
  local id = self.ZoneIdByName and self:ZoneIdByName(zone)
  if not id then
    return nil
  end
  return self:WorldPosFromMapPos(id, x, y)
end

function TG:WorldDistanceToWaypoint(zone, x, y)
  local px, py, pinstance = self:PlayerWorldPos()
  local tx, ty, tinstance = self:ZoneWorldPos(zone, x, y)
  if not px or not tx then
    return nil
  end
  if pinstance and tinstance and pinstance ~= -1 and tinstance ~= -1 and pinstance ~= tinstance then
    return nil, "travel"
  end
  local dx, dy = tx - px, ty - py
  return math.sqrt(dx * dx + dy * dy), "world"
end

local function currentZoneAliases()
  local aliases = {}
  local function add(s)
    local n = normalizeZoneName(s)
    if n ~= "" then
      aliases[n] = true
    end
  end
  add(GetZoneText and GetZoneText())
  add(GetSubZoneText and GetSubZoneText())
  if GetMapInfo and (not WorldMapFrame or not WorldMapFrame:IsVisible()) then
    local ok, mapName = pcall(GetMapInfo)
    if ok then
      add(mapName)
    end
  end
  return aliases
end

function TG:IsInNamedZone(name, subzoneOnly)
  local want = normalizeZoneName(name)
  if want == "" then
    return nil
  end
  local zone = normalizeZoneName(GetZoneText and GetZoneText())
  local sub = normalizeZoneName(GetSubZoneText and GetSubZoneText())
  local map = ""
  if GetMapInfo and (not WorldMapFrame or not WorldMapFrame:IsVisible()) then
    local ok, m = pcall(GetMapInfo)
    if ok then
      map = normalizeZoneName(m)
    end
  end
  if zone == "" and sub == "" and map == "" then
    return nil
  end
  if sub == want then
    return true
  end
  if not subzoneOnly then
    if zone == want or map == want then
      return true
    end
  end
  return false
end

function TG:ZoneMatches(a, b)
  if not a or not b then
    return false
  end
  if tonumber(a) then
    a = self:ZoneName(a)
  end
  if tonumber(b) then
    b = self:ZoneName(b)
  end
  local la, lb = normalizeZoneName(a), normalizeZoneName(b)
  if la == "" or lb == "" then
    return false
  end
  if la == lb then
    return true
  end
  if currentZoneAliases()[lb] then
    return true
  end
  if not MAP_ZONE_NAMES[la] then
    return true
  end
  return false
end
