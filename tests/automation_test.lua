local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_auto_accept_quest = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua")
    TG.db = { autoTurnIn = true }
    local accepted = false
    _G.AcceptQuest = function()
      accepted = true
    end
    TG:OnQuestDetail()
    env.eq(accepted, true)
  end,

  test_auto_use_fires_once_per_step = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua")
    TG.db = { autoUseQuestItems = true }
    TG.currentStepIndex = 1
    TG.CurrentStep = function()
      return { elements = { { t = "cmd", tag = "use", args = { "42" } } } }
    end
    _G.GetContainerNumSlots = function()
      return 1
    end
    _G.GetContainerItemLink = function()
      return "|Hitem:42::::::::::::|h[x]|h"
    end
    local uses = 0
    _G.UseContainerItem = function()
      uses = uses + 1
    end
    TG:AutoUseQuestItems()
    TG:AutoUseQuestItems()
    env.eq(uses, 1)
  end,

  test_auto_take_flight_matches_taxi_node_name = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua")
    TG.db = { autoTakeFlight = true }
    _G.IsShiftKeyDown = function()
      return false
    end
    _G.TaxiFrame = {
      IsShown = function()
        return true
      end,
    }
    _G.NumTaxiNodes = function()
      return 2
    end
    _G.TaxiNodeName = function(index)
      return index == 2 and "Stormwind City" or "Westfall"
    end
    _G.TaxiNodeGetType = function()
      return "REACHABLE"
    end
    local taken
    _G.TakeTaxiNode = function(index)
      taken = index
    end
    TG.CurrentStep = function()
      return {
        elements = {
          { t = "cmd", tag = "fly", args = { "Stormwind" }, text = "Fly to Stormwind City" },
        },
      }
    end
    env.eq(TG:AutoTakeFlight(), true)
    env.eq(taken, 2)
  end,

  test_auto_take_flight_uses_inline_text_without_location_arg = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua")
    TG.db = { autoTakeFlight = true }
    _G.IsShiftKeyDown = function()
      return false
    end
    _G.TaxiFrame = {
      IsShown = function()
        return true
      end,
    }
    _G.NumTaxiNodes = function()
      return 1
    end
    _G.TaxiNodeName = function()
      return "Ironforge"
    end
    _G.TaxiNodeGetType = function()
      return "REACHABLE"
    end
    local taken
    _G.TakeTaxiNode = function(index)
      taken = index
    end
    TG.CurrentStep = function()
      return {
        elements = {
          { t = "cmd", tag = "fly", args = {}, text = "Fly to Ironforge" },
        },
      }
    end
    env.eq(TG:AutoTakeFlight(), true)
    env.eq(taken, 1)
  end,

  test_auto_select_taxi_gossip_for_flight_step = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua")
    TG.db = { autoTakeFlight = true }
    _G.IsShiftKeyDown = function()
      return false
    end
    _G.GetGossipOptions = function()
      return "Taxi", "taxi", "Hello", "quest"
    end
    local selected
    _G.SelectGossipOption = function(index)
      selected = index
    end
    TG.CurrentStep = function()
      return {
        elements = {
          { t = "cmd", tag = "fp", args = { "Westfall" } },
        },
      }
    end
    env.eq(TG:AutoSelectTaxiGossip(), true)
    env.eq(selected, 1)
  end,

  test_taxi_open_captures_flight_step_before_auto_take = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua", "src/automation/Events.lua")
    TG:InitAutomation()
    TG.db = { autoTakeFlight = true }
    _G.GetTime = function()
      return 1
    end
    _G.IsShiftKeyDown = function()
      return false
    end
    _G.UnitOnTaxi = function()
      return false
    end
    _G.TaxiFrame = {
      IsShown = function()
        return true
      end,
    }
    _G.NumTaxiNodes = function()
      return 1
    end
    _G.TaxiNodeName = function()
      return "Stormwind, Elwynn Forest"
    end
    _G.TaxiNodeGetType = function()
      return "REACHABLE"
    end
    local taken
    _G.TakeTaxiNode = function(index)
      taken = index
    end
    local flyStep = {
      elements = { { t = "cmd", tag = "fly", args = { "Stormwind" }, text = "Fly to Stormwind" } },
    }
    local otherStep = { elements = {} }
    TG.CurrentStep = function()
      return flyStep
    end
    TG.events.TAXIMAP_OPENED[1]()
    TG.CurrentStep = function()
      return otherStep
    end
    TG.updaters.autoFlight.fn()
    env.eq(taken, 1)
  end,

  test_taxi_start_signals_captured_flight_step = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua", "src/automation/Events.lua")
    TG:InitAutomation()
    TG.db = { autoTakeFlight = true }
    _G.GetTime = function()
      return 1
    end
    _G.IsShiftKeyDown = function()
      return false
    end
    _G.UnitOnTaxi = function()
      return true
    end
    _G.TaxiFrame = {
      IsShown = function()
        return true
      end,
    }
    _G.NumTaxiNodes = function()
      return 0
    end
    local flyStep = {
      elements = { { t = "cmd", tag = "fly", args = { "Stormwind" }, text = "Fly to Stormwind" } },
    }
    TG.CurrentStep = function()
      return flyStep
    end
    TG.events.TAXIMAP_OPENED[1]()
    TG.updaters.autoFlight.fn()
    env.eq(TG._manualSignals[tostring(flyStep) .. ":fly"], true)
    env.eq(TG._autoFlightStep, nil)
  end,

  test_taxi_close_signals_flight_path_step = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua", "src/automation/Events.lua")
    TG:InitAutomation()
    TG.db = { autoTakeFlight = true }
    _G.GetTime = function()
      return 1
    end
    _G.IsShiftKeyDown = function()
      return false
    end
    _G.UnitOnTaxi = function()
      return false
    end
    local fpStep = { elements = { { t = "cmd", tag = "fp", args = { "Westfall" } } } }
    TG.CurrentStep = function()
      return fpStep
    end
    TG.events.TAXIMAP_OPENED[1]()
    TG.events.TAXIMAP_CLOSED[1]()
    env.eq(TG._manualSignals[tostring(fpStep) .. ":fp"], true)
    env.eq(TG._autoFlightStep, nil)
  end,

  test_turnin_cooldown = function()
    local TG = loadEngine()
    env.load("src/automation/Actions.lua")
    local Actions = TG.Automation.Actions
    _G.GetTime = function()
      return 10
    end
    TG._lastAutoTurnin = 10
    TG._lastAutoTurninQuest = "Foo"
    env.eq(Actions.canAutoTurnin("Foo"), false)
    env.eq(Actions.canAutoTurnin("Bar"), true)
  end,
}
