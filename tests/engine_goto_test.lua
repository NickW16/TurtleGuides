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
}
