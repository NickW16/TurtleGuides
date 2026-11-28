local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_parse_step_gotos = function()
    local TG = loadEngine()
    local step =
      { elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "50", "60", "5" }, text = "Go north" } } }
    local gotos = TG:GetStepGotos(step)
    env.eq(table.getn(gotos), 1)
    env.eq(gotos[1].zone, "Dun Morogh")
    env.eq(gotos[1].radius, 5)
    env.eq(gotos[1].range, 5)
    env.eq(gotos[1].text, "Go north")
  end,

  test_stormwind_classic_goto_uses_current_map_coords = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "goto", args = { "StormwindClassic", "61.609", "15.269" } } } }
    local gotos = TG:GetStepGotos(step)
    env.eq(gotos[1].zone, "Stormwind City")
    env.eq(math.abs(gotos[1].x - 67.345) < 0.01, true)
    env.eq(math.abs(gotos[1].y - 36.244) < 0.01, true)
  end,

  test_goto_index_selects_waypoint = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } },
        { t = "cmd", tag = "goto", args = { "Loch Modan", "30", "40" } },
      },
    }
    TG._gotoIndex = { [tostring(step)] = 2 }
    local zone, x, y = TG:GetStepGoto(step)
    env.eq(zone, "Loch Modan")
    env.eq(x, 30)
    env.eq(y, 40)
  end,

  test_update_waypoint_sets_target = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "50", "60" } } } }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    local target
    TG.SetWaypoint = function(_, zone, x, y, title)
      target = { zone = zone, x = x, y = y, title = title }
    end
    TG.ClearWaypoint = function()
      target = nil
    end
    TG:UpdateStepWaypoint()
    env.eq(target.zone, "Dun Morogh")
    env.eq(target.title, "Dun Morogh (50.0, 60.0)")
  end,

  test_update_waypoint_falls_back_to_next_goto = function()
    local TG = loadEngine()
    local current = { elements = { { t = "text", text = "talk" } } }
    local upcoming = { elements = { { t = "cmd", tag = "goto", args = { "Darkshore", "40", "50" } } } }
    TG.currentGuide = { steps = { current, upcoming } }
    TG.currentStepIndex = 1
    local target
    TG.SetWaypoint = function(_, zone, x, y)
      target = { zone = zone, x = x, y = y }
    end
    TG.ClearWaypoint = function()
      target = nil
    end
    TG:UpdateStepWaypoint()
    env.eq(target ~= nil, true)
    env.eq(target.zone, "Darkshore")
    env.eq(target.x, 40)
  end,

  test_waypoint_falls_back_to_step_npc_location = function()
    local TG = loadEngine()
    _G.GetZoneText = function()
      return "Stormwind City"
    end
    _G.pfDB = {
      zones = { loc = { [12] = "Stormwind City" } },
      units = {
        loc = { [1234] = "Eniris Brightspear" },
        data = { [1234] = { coords = { { 40.5, 60.5, 12, 0 } } } },
      },
    }
    local step = {
      elements = { { t = "text", text = "Talk to |cRXP_FRIENDLY_Eniris Brightspear|r" } },
    }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    local target
    TG.SetWaypoint = function(_, zone, x, y)
      target = { zone = zone, x = x, y = y }
    end
    TG.ClearWaypoint = function()
      target = nil
    end
    TG:UpdateStepWaypoint()
    env.eq(target ~= nil, true)
    env.eq(target.zone, "Stormwind City")
    env.eq(target.x, 40.5)
  end,

  test_waypoint_matches_plain_trainer_text = function()
    local TG = loadEngine()
    _G.GetZoneText = function()
      return "Stormwind City"
    end
    _G.pfDB = {
      zones = { loc = { [1519] = "Stormwind City" } },
      units = {
        loc = { [5515] = "Einris Brightspear" },
        data = { [5515] = { coords = { { 61.6, 15.3, 1519, 490 } } } },
      },
    }
    local step = {
      elements = {
        { t = "text", text = "Talk to Eniris Brightspear" },
        { t = "cmd", tag = "train", args = { "589" }, text = "Train your class spells" },
      },
    }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    local target
    TG.SetWaypoint = function(_, zone, x, y)
      target = { zone = zone, x = x, y = y }
    end
    TG.ClearWaypoint = function()
      target = nil
    end
    TG:UpdateStepWaypoint()
    env.eq(target ~= nil, true)
    env.eq(target.zone, "Stormwind City")
    env.eq(target.x, 61.6)
  end,

  test_waypoint_matches_misspelled_npc_name = function()
    local TG = loadEngine()
    _G.GetZoneText = function()
      return "Stormwind City"
    end
    _G.pfDB = {
      zones = { loc = { [1519] = "Stormwind City" } },
      units = {
        loc = { [5515] = "Einris Brightspear" },
        data = { [5515] = { coords = { { 61.6, 15.3, 1519, 490 } } } },
      },
    }
    local step = { elements = { { t = "text", text = "Talk to |cRXP_FRIENDLY_Eniris Brightspear|r" } } }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    local target
    TG.SetWaypoint = function(_, zone, x, y)
      target = { zone = zone, x = x, y = y }
    end
    TG.ClearWaypoint = function()
      target = nil
    end
    TG:UpdateStepWaypoint()
    env.eq(target ~= nil, true)
    env.eq(target.zone, "Stormwind City")
    env.eq(target.x, 61.6)
  end,

  test_waypoint_falls_back_to_zone_element = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "zone", args = { "Redridge" } } } }
    TG.currentGuide = { key = "k", steps = { step } }
    TG.currentStepIndex = 1
    local target
    TG.SetWaypoint = function(_, zone, x, y)
      target = { zone = zone, x = x, y = y }
    end
    TG.ClearWaypoint = function()
      target = nil
    end
    TG:UpdateStepWaypoint()
    env.eq(target ~= nil, true)
    env.eq(target.zone, "Redridge")
    env.eq(target.x, 50)
  end,

  test_disable_auto_skip_still_allows_goto_advance = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "50", "60" } } } }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    TG.db = { disableAutoSkip = true }
    TG.StepSkipState = function()
      return true
    end
    TG.WorldDistanceToWaypoint = function()
      return 0
    end
    local advanced = false
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckGotoAdvance()
    env.eq(advanced, true)
  end,

  test_auto_skip_holds_skipped_goto_step = function()
    local TG = loadEngine()
    local step = { elements = { { t = "cmd", tag = "goto", args = { "Dun Morogh", "50", "60" } } } }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.StepSkipState = function()
      return true
    end
    TG.WorldDistanceToWaypoint = function()
      return 0
    end
    local advanced
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckGotoAdvance()
    env.eq(advanced, nil)
  end,

  test_zoneless_goto_uses_parsed_zone = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } },
        { t = "cmd", tag = "goto", args = { "30", "40" }, gotoZone = "Dun Morogh" },
      },
    }
    local gotos = TG:GetStepGotos(step)
    env.eq(gotos[2].zone, "Dun Morogh")
    env.eq(gotos[2].x, 30)
    env.eq(gotos[2].y, 40)
  end,

  test_goto_distance_does_not_fallback_across_instances = function()
    local TG = loadEngine()
    _G.GetZoneText = function()
      return "Dun Morogh"
    end
    _G.GetPlayerMapPosition = function()
      return 0.5, 0.5
    end
    TG.WorldDistanceToWaypoint = function()
      return nil, "travel"
    end
    local dist = TG.Engine.Goto.gotoDistance({ zone = "Dun Morogh", x = 60, y = 60 })
    env.eq(dist, nil)
  end,

  test_check_goto_advance_selects_nearest_candidate = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "80", "80" } },
      },
    }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.WorldDistanceToWaypoint = function(_, _, x)
      if x == 10 then
        return 120
      end
      return 15
    end
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG.NextStep = function() end
    TG:CheckGotoAdvance()
    local _, x = TG:GetStepGoto(step)
    env.eq(x, 80)
    env.eq(TG._gotoIndex[tostring(step)], 2)
  end,

  test_goto_advance_marks_previous_waypoint_reached = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "80", "80" } },
      },
    }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.WorldDistanceToWaypoint = function()
      return 0
    end
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG.NextStep = function() end
    TG:CheckGotoAdvance()
    env.eq(TG._gotoIndex[tostring(step)], 2)
    env.eq(TG._gotoReached[tostring(step)][1], true)
  end,

  test_dynamic_goto_does_not_advance = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20", "-1" } },
      },
    }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.WorldDistanceToWaypoint = function()
      return 0
    end
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    local advanced = false
    TG.NextStep = function()
      advanced = true
    end
    TG:CheckGotoAdvance()
    env.eq(advanced, false)
  end,

  test_pending_objective_overrides_cached_goto = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "accept", id = 1 },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } },
        { t = "cmd", tag = "accept", id = 2 },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "80", "80" } },
      },
    }
    TG.IsElementDone = function(_, el)
      return el.id == 2
    end
    TG._gotoIndex = { [tostring(step)] = 2 }
    local _, x = TG:GetStepGoto(step)
    env.eq(x, 10)
  end,

  test_nearby_later_goto_does_not_skip_pending_objective = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "accept", id = 1 },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } },
        { t = "cmd", tag = "accept", id = 2 },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "80", "80" } },
      },
    }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.IsElementDone = function(_, el)
      return el.id == 2
    end
    TG.WorldDistanceToWaypoint = function(_, _, x)
      if x == 80 then
        return 2
      end
      return 60
    end
    local waypointX
    TG.SetWaypoint = function(_, _, x)
      waypointX = x
    end
    TG.ClearWaypoint = function() end
    TG:CheckGotoAdvance()
    local _, x = TG:GetStepGoto(step)
    env.eq(x, 10)
    env.eq(waypointX, 10)
    env.eq(TG._gotoIndex[tostring(step)], 1)
    env.eq(TG._gotoReached[tostring(step)][1], nil)
  end,

  test_completed_goto_advances_to_next_pending_objective = function()
    local TG = loadEngine()
    local step = {
      elements = {
        { t = "cmd", tag = "accept", id = 1 },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "10", "20" } },
        { t = "cmd", tag = "accept", id = 2 },
        { t = "cmd", tag = "goto", args = { "Dun Morogh", "80", "80" } },
      },
    }
    TG.currentGuide = { steps = { step } }
    TG.currentStepIndex = 1
    TG.db = {}
    local done = { [1] = true, [2] = false }
    TG.IsElementDone = function(_, el)
      return done[el.id] == true
    end
    TG.WorldDistanceToWaypoint = function()
      return 2
    end
    TG.SetWaypoint = function() end
    TG.ClearWaypoint = function() end
    TG.NextStep = function() end
    TG:CheckGotoAdvance()
    local _, x = TG:GetStepGoto(step)
    env.eq(x, 80)
    env.eq(TG._gotoReached[tostring(step)][1], true)
  end,
}
