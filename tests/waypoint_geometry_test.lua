local env = dofile("tests/env.lua")

return {
  test_bearing_and_relative = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/compat/Runtime.lua", "src/waypoint/Geometry.lua")
    local Geometry = TG.Arrow.Geometry
    local bearing = Geometry.bearing(0, -1)
    env.eq(bearing, 0)
    env.eq(Geometry.relative(bearing, math.pi / 2), -math.pi / 2)
  end,

  test_cell_mapping_wraps = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/compat/Runtime.lua", "src/waypoint/Geometry.lua")
    local Geometry = TG.Arrow.Geometry
    env.eq(Geometry.cell(0), 0)
    env.eq(Geometry.cell(2 * math.pi), 0)
    local col, row = Geometry.cellCoords(9)
    env.eq(col, 1)
    env.eq(row, 1)
  end,
}
