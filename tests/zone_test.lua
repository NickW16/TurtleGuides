local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/compat/ZoneData.lua", "src/compat/Zone.lua")
end

return {
  test_zone_name_uses_map_data = function()
    local TG = fresh()
    env.eq(TG:ZoneName(1432), "Loch Modan")
    env.eq(TG:ZoneName("Westfall"), "Westfall")
  end,

  test_guide_zone_id_name_wins_over_zone_database = function()
    local TG = fresh()
    _G.pfDB = { zones = { loc = { [148] = "Darkshore", [1439] = "Dreadmaul Post" } } }
    env.eq(TG:ZoneNameFromId(1439), "Darkshore")
    env.eq(TG:ZoneName(1439), "Darkshore")
    env.eq(TG:ZoneIdByName("Darkshore"), 148)
  end,

  test_zone_id_by_name_normalizes_spacing = function()
    local TG = fresh()
    env.eq(TG:ZoneIdByName("Dun Morogh"), 1426)
    env.eq(TG:ZoneIdByName("dunmorogh"), 1426)
  end,

  test_guide_coords_convert_stormwind_classic = function()
    local TG = fresh()
    local zone, x, y = TG:GuideMapCoords("StormwindClassic", 61.609, 15.269)
    env.eq(zone, "Stormwind City")
    env.eq(math.abs(x - 67.345) < 0.01, true)
    env.eq(math.abs(y - 36.244) < 0.01, true)
  end,

  test_rxp_zone_alias_resolves = function()
    local TG = fresh()
    env.eq(TG:ZoneIdByName("StormwindClassic"), 1453)
    env.eq(TG:ZoneName("StormwindClassic"), "Stormwind City")
  end,

  test_pfquest_zone_id_is_preferred = function()
    local TG = fresh()
    _G.pfDB = { zones = { loc = { [1519] = "Stormwind City" } } }
    env.eq(TG:ZoneIdByName("StormwindClassic"), 1519)
  end,

  test_zone_matches_unknown_subzone = function()
    local TG = fresh()
    _G.GetZoneText = function()
      return "Anvilmar"
    end
    env.eq(TG:ZoneMatches("Dun Morogh", "Anvilmar"), true)
  end,

  test_is_in_named_zone_respects_subzone_only = function()
    local TG = fresh()
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetSubZoneText = function()
      return "Anvilmar"
    end
    env.eq(TG:IsInNamedZone("Anvilmar"), true)
    env.eq(TG:IsInNamedZone("Dun Morogh", true), false)
  end,

  test_world_pos_from_map_pos = function()
    local TG = fresh()
    _G.CreateVector2D = function(x, y)
      return { x = x, y = y }
    end
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return {
          GetXY = function()
            return 30, 20
          end,
        }
      end,
    }
    local x, y = TG:WorldPosFromMapPos(1432, 50, 60)
    env.eq(x, 30)
    env.eq(y, 20)
  end,

  test_world_pos_from_map_pos_returns_instance = function()
    local TG = fresh()
    _G.C_Map = {
      GetWorldPosFromMapPos = function()
        return 1, {
          GetXY = function()
            return 30, 20
          end,
        }
      end,
    }
    local x, y, instance = TG:WorldPosFromMapPos(1432, 50, 60)
    env.eq(x, 30)
    env.eq(y, 20)
    env.eq(instance, 1)
  end,

  test_player_world_pos_returns_instance = function()
    local TG = fresh()
    _G.UnitPosition = function(unit)
      env.eq(unit, "player")
      return 20, 10, 95.5, 0
    end
    local x, y, instance = TG:PlayerWorldPos()
    env.eq(x, 20)
    env.eq(y, 10)
    env.eq(instance, 0)
  end,

  test_world_distance_rejects_instance_mismatch = function()
    local TG = fresh()
    _G.UnitPosition = function()
      return 20, 10, 0, 0
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
    local dist, reason = TG:WorldDistanceToWaypoint("Dun Morogh", 50, 60)
    env.eq(dist, nil)
    env.eq(reason, "travel")
    _G.UnitPosition = function()
      return 20, 10, 0, 1
    end
    TG:ClearWorldPosCache()
    local sameDist = TG:WorldDistanceToWaypoint("Dun Morogh", 50, 60)
    env.eq(type(sameDist), "number")
  end,
}
