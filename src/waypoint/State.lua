-- waypoint target, coordinate resolution, and direction logic
local TG = _G.TurtleGuides
local State = {}
TG.Arrow = TG.Arrow or {}
TG.Arrow.State = State

local DIRECTION_SAMPLE_INTERVAL = 0.1
local target
local lastDx, lastDy = 0, -1
local sample
local sampleTime = -math.huge

local function normalized(s)
  s = string.lower(tostring(s or ""))
  return string.gsub(s, "[^%w]", "")
end

local function zoneMatches(a, b)
  if TG.ZoneMatches then
    return TG:ZoneMatches(a, b)
  end
  return normalized(a) == normalized(b)
end

local function cMapPlayerPos(zone)
  if not (C_Map and type(C_Map.GetPlayerMapPosition) == "function") then
    return nil
  end
  local mapId
  if zone and TG.ZoneIdByName then
    mapId = TG:ZoneIdByName(zone)
  end
  if not mapId and type(C_Map.GetBestMapForUnit) == "function" then
    mapId = C_Map.GetBestMapForUnit("player")
  end
  if not mapId then
    return nil
  end
  local okVec, vec = pcall(C_Map.GetPlayerMapPosition, mapId, "player")
  if not okVec or not vec then
    return nil
  end
  local ok, x, y = pcall(function()
    if type(vec.GetXY) == "function" then
      return vec:GetXY()
    end
    return vec.x, vec.y
  end)
  if not ok or type(x) ~= "number" or type(y) ~= "number" then
    return nil
  end
  if x < 0 or x > 1 or y < 0 or y > 1 then
    return nil
  end
  return x * 100, y * 100, mapId
end

local function rawMapPos()
  if not GetPlayerMapPosition then
    return nil
  end
  local px, py = GetPlayerMapPosition("player")
  if not px or not py or (px < 0 or px > 1 or py < 0 or py > 1) or (px == 0 and py == 0) then
    return nil
  end
  return px * 100, py * 100
end

local function playerPos(zone)
  if _G.pfMap and type(_G.pfMap.GetPlayerMapID) == "function" then
    local mapId = _G.pfMap:GetPlayerMapID()
    local wantId = zone and TG.ZoneIdByName and TG:ZoneIdByName(zone)
    if mapId and (not wantId or mapId == wantId) then
      local px, py = _G.pfMap.minimapPlayerX, _G.pfMap.minimapPlayerY
      if px and py and px >= 0 and px <= 1 and py >= 0 and py <= 1 then
        return px * 100, py * 100, mapId, "pfquest"
      end
    end
  end
  local px, py = rawMapPos()
  if px then
    return px, py, nil, "map"
  end
  px, py = cMapPlayerPos(zone)
  if px then
    return px, py, nil, "cmap"
  end
  return nil
end

local function now()
  if GetTime then
    return GetTime()
  end
  if os and os.clock then
    return os.clock()
  end
  return 0
end

local function invalidateSample()
  sample = nil
  sampleTime = -math.huge
end

local clearWorldPosCache = TG.ClearWorldPosCache
function TG:ClearWorldPosCache()
  if clearWorldPosCache then
    clearWorldPosCache(self)
  end
  invalidateSample()
end

function State.invalidate()
  invalidateSample()
end

function State.set(zone, x, y, title, radius)
  TG:ClearWorldPosCache()
  lastDx, lastDy = 0, -1
  if not zone or not x or not y then
    target = nil
    return
  end
  target = {
    zone = zone,
    x = tonumber(x),
    y = tonumber(y),
    radius = tonumber(radius),
    title = title or (zone .. string.format(" %.1f, %.1f", x, y)),
  }
end

function State.clear()
  target = nil
  TG:ClearWorldPosCache()
  lastDx, lastDy = 0, -1
end

function State.get()
  return target
end

function State.sample()
  if not target then
    return nil
  end
  local t = now()
  if sample and t - sampleTime < DIRECTION_SAMPLE_INTERVAL then
    return sample
  end

  local wx, wy, pinstance = TG:PlayerWorldPos()
  local tx, ty, tinstance = TG:ZoneWorldPos(target.zone, target.x, target.y)
  local wrongInstance = pinstance and tinstance and pinstance ~= -1 and tinstance ~= -1 and pinstance ~= tinstance

  local zone = (GetZoneText and GetZoneText()) or (GetSubZoneText and GetSubZoneText()) or ""
  local px, py, _, mapSource = playerPos(target.zone)
  local sameZone = false
  if TG.IsInNamedZone then
    sameZone = TG:IsInNamedZone(target.zone) == true
  end
  if not sameZone then
    sameZone = zoneMatches(zone, target.zone)
  end

  local dx, dy, yards, status
  if px and sameZone and not wrongInstance then
    dx, dy = target.x - px, target.y - py
    yards = math.sqrt(dx * dx + dy * dy) * 10
    status = mapSource or "map"
  elseif wx and tx and not wrongInstance then
    dx, dy = tx - wx, wy - ty
    yards = math.sqrt(dx * dx + dy * dy)
    status = "world"
  elseif wx and not wrongInstance then
    local centerX, centerY
    if TG.ZoneCenter then
      centerX, centerY = TG:ZoneCenter(target.zone)
    end
    local cx, cy
    if centerX and centerY then
      cx, cy = TG:ZoneWorldPos(target.zone, centerX, centerY)
    end
    if cx then
      dx, dy = cx - wx, wy - cy
      status = "travel"
    else
      dx, dy = lastDx, lastDy
      status = wrongInstance and "travel" or "none"
    end
  else
    dx, dy = lastDx, lastDy
    status = wrongInstance and "travel" or "none"
  end
  if dx ~= 0 or dy ~= 0 then
    lastDx, lastDy = dx, dy
  end

  sample = {
    dx = dx,
    dy = dy,
    yards = yards,
    sameZone = sameZone,
    status = status,
    zone = zone,
  }
  sampleTime = t
  return sample
end

function State.direction()
  local result = State.sample()
  if not result then
    return nil
  end
  return result.dx, result.dy, result.yards, result.sameZone, result.status
end

function State.debugLines()
  if not target then
    return { "no waypoint" }
  end
  local wx, wy, pinstance = TG:PlayerWorldPos()
  local tx, ty, tinstance = TG:ZoneWorldPos(target.zone, target.x, target.y)
  local cpx, cpy, cmapId = cMapPlayerPos(target.zone)
  local rpx, rpy = rawMapPos()
  local ppx, ppy, pmapId
  if _G.pfMap and type(_G.pfMap.GetPlayerMapID) == "function" then
    pmapId = _G.pfMap:GetPlayerMapID()
    ppx, ppy = _G.pfMap.minimapPlayerX, _G.pfMap.minimapPlayerY
  end
  local zone = GetZoneText and GetZoneText() or ""
  local sub = GetSubZoneText and GetSubZoneText() or ""
  local map = ""
  if GetMapInfo and (not WorldMapFrame or not WorldMapFrame:IsVisible()) then
    map = GetMapInfo() or ""
  end
  local s = State.sample()
  local lines = {
    "target zone=" .. tostring(target.zone) .. " x=" .. tostring(target.x) .. " y=" .. tostring(target.y),
    "GetZoneText=" .. tostring(zone) .. " sub=" .. tostring(sub) .. " map=" .. tostring(map),
    "pfmap id=" .. tostring(pmapId) .. " pos=" .. tostring(ppx) .. "," .. tostring(ppy),
    "raw map pos=" .. tostring(rpx) .. "," .. tostring(rpy),
    "cmap id=" .. tostring(cmapId) .. " pos=" .. tostring(cpx) .. "," .. tostring(cpy),
    "world pos=" .. tostring(wx) .. "," .. tostring(wy) .. " inst=" .. tostring(pinstance),
    "target world=" .. tostring(tx) .. "," .. tostring(ty) .. " inst=" .. tostring(tinstance),
    "sameZone=" .. tostring(TG.IsInNamedZone and TG:IsInNamedZone(target.zone)),
  }
  if s then
    table.insert(
      lines,
      "sample status="
        .. tostring(s.status)
        .. " dx="
        .. tostring(s.dx)
        .. " dy="
        .. tostring(s.dy)
        .. " yards="
        .. tostring(s.yards)
    )
  end
  return lines
end
