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
    env.eq(table.getn(env.textures), 3)
    env.eq(table.getn(env.texts), 1)
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
    env.eq(env.texts[1].value, "100 yd")
    env.eq(env.textures[3].coords ~= nil, true)
    env.eq(env.textures[3].color, nil)
  end,

  test_driver_updates_pointer_every_frame = function()
    local TG = fresh()
    TG:InitArrow()
    TG:SetWaypoint("Dun Morogh", 50, 60, "Test")
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    _G.GetPlayerFacing = function()
      return 0
    end
    for _, f in ipairs(env.frames) do
      if f.name == "TurtleGuidesArrowDriver" then
        _G.this = f
      end
    end
    env.textures[3].coords = nil
    _G.arg1 = 0.016
    env.scripts.OnUpdate()
    env.eq(env.textures[3].coords ~= nil, true)
  end,

  test_dial_tracks_facing = function()
    local TG = fresh()
    TG:InitArrow()
    TG:SetWaypoint("Dun Morogh", 50, 60, "Test")
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    local facing = 0
    _G.GetPlayerFacing = function()
      return facing
    end
    for _, f in ipairs(env.frames) do
      if f.name == "TurtleGuidesArrowDriver" then
        _G.this = f
      end
    end
    _G.arg1 = 0.016
    env.scripts.OnUpdate()
    local dial = table.concat(env.textures[2].coords, ",")
    facing = math.pi / 2
    env.scripts.OnUpdate()
    env.eq(dial ~= table.concat(env.textures[2].coords, ","), true)
  end,

  test_driver_throttles_text = function()
    local TG = fresh()
    TG:InitArrow()
    TG:SetWaypoint("Dun Morogh", 50, 60, "Test")
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    for _, f in ipairs(env.frames) do
      if f.name == "TurtleGuidesArrowDriver" then
        _G.this = f
      end
    end
    _G.arg1 = 0.016
    env.scripts.OnUpdate()
    env.eq(env.texts[1].value, nil)
    _G.arg1 = 0.1
    env.scripts.OnUpdate()
    env.eq(env.texts[1].value ~= nil, true)
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
