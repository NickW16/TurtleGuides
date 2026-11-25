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

local function playerPos()
  if SetMapToCurrentZone and (not WorldMapFrame or not WorldMapFrame:IsVisible()) then
    SetMapToCurrentZone()
  end
  local px, py = GetPlayerMapPosition("player")
  if not px or not py or (px == 0 and py == 0) then
    return nil, nil, nil
  end
  return (GetZoneText and GetZoneText() or ""), px * 100, py * 100
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
  local wrongInstance = pinstance and tinstance and pinstance ~= -1
    and tinstance ~= -1 and pinstance ~= tinstance

  local zone, px, py
  if not (wx and tx) or wrongInstance then
    zone, px, py = playerPos()
  end
  local sameZone = zoneMatches(zone, target.zone)

  local dx, dy, yards, status
  if wx and tx and not wrongInstance then
    dx, dy = tx - wx, wy - ty
    yards = math.sqrt(dx * dx + dy * dy)
    status = "world"
  elseif px and sameZone and not wrongInstance then
    dx, dy = target.x - px, target.y - py
    yards = math.sqrt(dx * dx + dy * dy) * 10
    status = "map"
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
