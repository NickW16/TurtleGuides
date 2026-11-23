-- waypoint target, coordinate resolution, and direction logic
local TG = _G.TurtleGuides
local State = {}
TG.Arrow = TG.Arrow or {}
TG.Arrow.State = State

local target
local lastDx, lastDy = 0, -1

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

function State.direction()
  if not target then
    return nil
  end
  local wx, wy = TG:PlayerWorldPos()
  local tx, ty = TG:ZoneWorldPos(target.zone, target.x, target.y)
  local zone = (GetZoneText and GetZoneText() or "")
  local px, py
  if not (wx and tx) then
    zone, px, py = playerPos()
  end
  local sameZone = zoneMatches(zone, target.zone)

  local dx, dy, yards
  if wx and tx then
    dx, dy = tx - wx, wy - ty
    yards = math.sqrt(dx * dx + dy * dy)
  elseif px and sameZone then
    dx, dy = target.x - px, target.y - py
    yards = math.sqrt(dx * dx + dy * dy) * 10
  else
    dx, dy = lastDx, lastDy
  end
  if dx ~= 0 or dy ~= 0 then
    lastDx, lastDy = dx, dy
  end
  return dx, dy, yards, sameZone
end
