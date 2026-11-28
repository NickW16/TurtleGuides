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

local function expectFrame(texture, index)
  local col = math.mod(index, 8)
  local row = math.floor(index / 8)
  env.eq(texture.coords[1], col / 8)
  env.eq(texture.coords[2], (col + 1) / 8)
  env.eq(texture.coords[3], row / 8)
  env.eq(texture.coords[4], (row + 1) / 8)
end

return {
  test_init_builds_frames = function()
    local TG = fresh()
    TG:InitArrow()
    env.eq(table.getn(env.frames), 3)
    env.eq(table.getn(env.textures), 3)
    env.eq(table.getn(env.texts), 2)
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
    env.eq(env.textures[3].color ~= nil, true)
  end,

  test_arrow_shows_current_step_and_distance = function()
    local TG = fresh()
    TG:InitArrow()
    TG.currentGuide = { steps = { {}, {}, {}, {}, {} } }
    TG.currentStepIndex = 3
    TG:SetWaypoint("Dun Morogh", 50, 60, "Test")
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    TG:ArrowUpdate()
    env.eq(env.texts[1].value, "100 yd")
    env.eq(env.texts[2].value, "Step 3/5")
  end,

  test_arrow_shows_go_to_location_when_distance_unknown = function()
    local TG = fresh()
    TG:InitArrow()
    TG.currentGuide = { name = "18-19 Redridge", steps = { {}, {}, {} } }
    TG.currentStepIndex = 2
    TG:SetWaypoint("Redridge", 50, 60, "Test")
    _G.GetPlayerMapPosition = function()
      return 0, 0
    end
    TG:ArrowUpdate()
    env.eq(env.texts[1].value, "Go to Redridge")
    env.eq(env.texts[2].value, "Step 2/3")
  end,

  test_arrow_shows_distance_only_in_target_zone = function()
    local TG = fresh()
    TG:InitArrow()
    TG.currentGuide = { name = "18-19 Redridge", steps = { {}, {} } }
    TG.currentStepIndex = 1
    TG:SetWaypoint("Redridge", 50, 60, "Test")
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    TG:ArrowUpdate()
    env.eq(env.texts[1].value, "Go to Redridge")

    _G.GetZoneText = function()
      return "Redridge"
    end
    TG.Arrow.State.invalidate()
    TG:ArrowUpdate()
    env.eq(env.texts[1].value, "100 yd")
  end,

  test_arrow_uses_zone_name_with_world_map_open = function()
    local TG = fresh()
    TG:InitArrow()
    TG.currentGuide = { steps = { {} } }
    TG.currentStepIndex = 1
    _G.WorldMapFrame = {
      IsVisible = function()
        return true
      end,
      IsShown = function()
        return true
      end,
    }
    _G.GetZoneText = function()
      return "Stormwind City"
    end
    _G.UnitPosition = function()
      return 100, 200, 0, 0
    end
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return 0, {
          GetXY = function()
            return 200, 90
          end,
        }
      end,
    }
    TG:SetWaypoint("Stormwind City", 61.6, 15.3, "Test")
    TG.Arrow.State.invalidate()
    TG:ArrowUpdate()
    env.eq(env.texts[1].value, "149 yd")
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

  test_pointer_uses_clockwise_arrow_frames = function()
    local TG = fresh()
    TG:InitArrow()
    TG:SetWaypoint("Dun Morogh", 50, 50, "Test")
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.6
    end
    local facing = 0
    _G.GetPlayerFacing = function()
      return facing
    end
    TG:ArrowUpdate()
    expectFrame(env.textures[3], 0)
    facing = -math.pi / 2
    TG:ArrowUpdate()
    expectFrame(env.textures[3], 48)
  end,

  test_dial_uses_clockwise_dial_frames = function()
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
    TG:ArrowUpdate()
    expectFrame(env.textures[2], 0)
    facing = -math.pi / 2
    TG:ArrowUpdate()
    expectFrame(env.textures[2], 48)
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
