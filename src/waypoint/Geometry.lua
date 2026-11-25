-- pure direction and sprite mapping for the waypoint arrow
local TG = _G.TurtleGuides
local Geometry = {}
TG.Arrow = TG.Arrow or {}
TG.Arrow.Geometry = Geometry

local TURNS = 64
local PER_ROW = 8

function Geometry.bearing(dx, dy)
  return math.atan2(-dx, -dy)
end

function Geometry.relative(bearing, facing)
  return bearing - facing
end

function Geometry.cell(rel)
  local index = math.floor(rel / (2 * math.pi) * TURNS + 0.5)
  index = math.mod(index, TURNS)
  if index < 0 then
    index = index + TURNS
  end
  return index
end

function Geometry.cellCoords(index)
  return math.mod(index, PER_ROW), math.floor(index / PER_ROW)
end
