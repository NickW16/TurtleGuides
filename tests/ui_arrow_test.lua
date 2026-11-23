local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  local TG = env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/compat/ZoneData.lua",
    "src/compat/Zone.lua",
    "src/core/Util.lua",
    "src/core/Output.lua",
    "src/core/State.lua",
    "src/core/Events.lua",
    "src/waypoint/Geometry.lua",
    "src/waypoint/State.lua",
    "src/ui/Arrow.lua"
  )
  TG.db = { showArrow = true, arrowFrame = {} }
  return TG
end

return {
  test_init_builds_frames = function()
    local TG = fresh()
    TG:InitArrow()
    env.eq(table.getn(env.frames), 3)
    env.eq(table.getn(env.textures), 1)
    env.eq(table.getn(env.texts), 3)
  end,

  test_waypoint_updates_rendering = function()
    local TG = fresh()
    TG:InitArrow()
    TG:SetWaypoint("Dun Morogh", 50, 60, "Test")
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    TG:ArrowUpdate()
    env.eq(env.texts[1].value, "Test")
    env.eq(env.texts[2].value, "100 yd")
    env.eq(env.textures[1].coords ~= nil, true)
    env.eq(env.textures[1].color ~= nil, true)
  end,

  test_clear_waypoint_hides_frame = function()
    local TG = fresh()
    TG:InitArrow()
    TG:SetWaypoint("Dun Morogh", 50, 60)
    TG:ClearWaypoint()
    env.eq(TG:GetWaypoint(), nil)
    for _, frame in ipairs(env.frames) do
      if frame.name == "TurtleGuidesArrow" then
        env.eq(frame.visible, false)
      end
    end
  end,
}
