local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/compat/ZoneData.lua",
    "src/compat/Zone.lua",
    "src/waypoint/Geometry.lua",
    "src/waypoint/State.lua"
  )
end

return {
  test_set_and_clear_target = function()
    local TG = fresh()
    TG.Arrow.State.set("Dun Morogh", 50, 60, "Test")
    local target = TG.Arrow.State.get()
    env.eq(target.zone, "Dun Morogh")
    env.eq(target.x, 50)
    env.eq(target.title, "Test")
    TG.Arrow.State.clear()
    env.eq(TG.Arrow.State.get(), nil)
  end,

  test_direction_from_map_coordinates = function()
    local TG = fresh()
    TG.Arrow.State.set("Dun Morogh", 50, 60)
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    local dx, dy, yards, sameZone = TG.Arrow.State.direction()
    env.eq(dx, 0)
    env.eq(dy, 10)
    env.eq(yards, 100)
    env.eq(sameZone, true)
  end,

  test_direction_holds_last_heading_without_data = function()
    local TG = fresh()
    TG.Arrow.State.set("Dun Morogh", 50, 60)
    local dx, dy = TG.Arrow.State.direction()
    env.eq(dx, 0)
    env.eq(dy, -1)
  end,

  test_direction_reports_world_status = function()
    local TG = fresh()
    _G.UnitPosition = function()
      return 0, 0, 0
    end
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return 0, { GetXY = function()
          return 20, 10
        end }
      end,
    }
    TG.Arrow.State.set("Dun Morogh", 50, 60)
    local _, _, _, _, status = TG.Arrow.State.direction()
    env.eq(status, "world")
  end,

  test_direction_reports_travel_status_on_instance_mismatch = function()
    local TG = fresh()
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    _G.UnitPosition = function()
      return 0, 0, 0
    end
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return 1, { GetXY = function()
          return 20, 10
        end }
      end,
    }
    TG.Arrow.State.set("Dun Morogh", 50, 60)
    local dx, dy, yards, sameZone, status = TG.Arrow.State.direction()
    env.eq(status, "travel")
    env.eq(dx, 0)
    env.eq(dy, -1)
    env.eq(yards, nil)
    env.eq(sameZone, true)
  end,

  test_direction_caches_samples = function()
    local TG = fresh()
    local clock = 10
    _G.GetTime = function()
      return clock
    end
    local calls = 0
    _G.UnitPosition = function()
      calls = calls + 1
      return 0, 0, 0
    end
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return 0, { GetXY = function()
          return 0, 0
        end }
      end,
    }
    TG.Arrow.State.set("Dun Morogh", 50, 60)
    TG.Arrow.State.direction()
    TG.Arrow.State.direction()
    env.eq(calls, 1)
    clock = clock + 0.2
    TG.Arrow.State.direction()
    env.eq(calls, 2)
  end,
}
