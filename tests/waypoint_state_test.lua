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
      return 0, 0, 0, 0
    end
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return 0, {
          GetXY = function()
            return 20, 10
          end,
        }
      end,
    }
    TG.Arrow.State.set("Dun Morogh", 50, 60)
    local _, _, _, _, status = TG.Arrow.State.direction()
    env.eq(status, "world")
  end,

  test_direction_prefers_pfquest_player_position = function()
    local TG = fresh()
    _G.pfDB = { zones = { loc = { [1519] = "Stormwind City" } } }
    _G.pfMap = {
      GetPlayerMapID = function()
        return 1519
      end,
      minimapPlayerX = 0.616,
      minimapPlayerY = 0.153,
    }
    _G.GetZoneText = function()
      return "Stormwind City"
    end
    TG.Arrow.State.set("Stormwind City", 61.609, 15.269)
    local dx, dy, yards, sameZone, status = TG.Arrow.State.direction()
    env.eq(status, "pfquest")
    env.eq(sameZone, true)
    env.eq(math.abs(dx - 0.009) < 0.0001, true)
    env.eq(math.abs(dy + 0.031) < 0.0001, true)
    env.eq(math.abs(yards - 0.323) < 0.01, true)
  end,

  test_direction_prefers_cmap_player_position = function()
    local TG = fresh()
    _G.GetZoneText = function()
      return "Stormwind City"
    end
    _G.C_Map = {
      GetBestMapForUnit = function()
        return 1519
      end,
      GetPlayerMapPosition = function()
        return {
          GetXY = function()
            return 0.616, 0.153
          end,
        }
      end,
      GetWorldPosFromMapPos = function()
        return 0, {
          GetXY = function()
            return -8000, 500
          end,
        }
      end,
    }
    _G.UnitPosition = function()
      return 500, -8000, 90, 0
    end
    TG.Arrow.State.set("Stormwind City", 61.6, 15.3)
    local dx, dy, yards, sameZone, status = TG.Arrow.State.direction()
    env.eq(sameZone, true)
    env.eq(status, "cmap")
    env.eq(math.abs(dx) < 0.0001, true)
    env.eq(math.abs(dy) < 0.0001, true)
    env.eq(yards < 0.0001, true)
  end,

  test_direction_from_world_coordinates = function()
    local TG = fresh()
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
    TG.Arrow.State.set("Dun Morogh", 50, 60)
    local dx, dy, yards, _, status = TG.Arrow.State.direction()
    env.eq(status, "world")
    env.eq(dx, 100)
    env.eq(dy, 110)
    env.eq(math.abs(yards - 148.6607) < 0.001, true)
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
      return 0, 0, 0, 0
    end
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return 1, {
          GetXY = function()
            return 20, 10
          end,
        }
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
        return 0, {
          GetXY = function()
            return 0, 0
          end,
        }
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
