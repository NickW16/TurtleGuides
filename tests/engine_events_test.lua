local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_engine_events_are_registered = function()
    loadEngine()
    env.load("src/engine/Events.lua")
    local found = {}
    for _, event in ipairs(env.registered) do
      found[event] = true
    end
    env.eq(found.QUEST_LOG_UPDATE, true)
    env.eq(found.QUEST_ACCEPTED, true)
    env.eq(found.BAG_UPDATE, true)
    env.eq(found.PLAYER_LEVEL_UP, true)
    env.eq(found.TRAINER_CLOSED, true)
    env.eq(found.PLAYER_LOGIN, true)
  end,

  test_player_login_seeds_quest_log = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    TG._questLogSeeded = false
    _G.event = "PLAYER_LOGIN"
    env.scripts.OnEvent()
    env.eq(TG._questLogSeeded, true)
  end,

  test_trainer_signals_wait_until_dialog_closes = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    local signals = {}
    TG.SignalManualAction = function(_, tag)
      table.insert(signals, tag)
    end
    _G.event = "TRAINER_SHOW"
    env.scripts.OnEvent()
    env.eq(table.getn(signals), 0)
    _G.event = "TRAINER_CLOSED"
    env.scripts.OnEvent()
    env.eq(table.concat(signals, ","), "trainer,train")
  end,

  test_trainer_step_advances_on_dialog_close = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    local step = { elements = { { t = "cmd", tag = "train", args = {} } } }
    TG.currentGuide = { key = "k", steps = { step, { elements = {} } } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.cdb = {}
    local advanced = false
    TG.NextStep = function()
      advanced = true
    end
    _G.event = "TRAINER_SHOW"
    env.scripts.OnEvent()
    env.eq(advanced, false)
    _G.event = "TRAINER_CLOSED"
    env.scripts.OnEvent()
    env.eq(advanced, true)
  end,

  test_trainer_close_signals_even_without_show = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    local signals = {}
    TG.SignalManualAction = function(_, tag)
      table.insert(signals, tag)
    end
    _G.event = "TRAINER_CLOSED"
    env.scripts.OnEvent()
    env.eq(table.concat(signals, ","), "trainer,train")
  end,

  test_trainer_visibility_poll_signals_close = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    local signals = {}
    TG.SignalManualAction = function(_, tag)
      table.insert(signals, tag)
    end
    local visible = false
    _G.ClassTrainerFrame = {
      IsVisible = function()
        return visible
      end,
    }
    visible = true
    TG.updaters.trainerClose.fn()
    env.eq(table.getn(signals), 0)
    visible = false
    TG.updaters.trainerClose.fn()
    env.eq(table.concat(signals, ","), "trainer,train")
  end,

  test_trainer_close_clears_manual_nav_hold_and_completes = function()
    local TG = loadEngine()
    env.load("src/engine/Events.lua")
    _G.UnitLevel = function()
      return 7
    end
    _G.UnitXP = function()
      return 100
    end
    _G.UnitXPMax = function()
      return 1000
    end
    local step = {
      elements = {
        { t = "cmd", tag = "xp", args = { "<8", "1" } },
        { t = "cmd", tag = "train", args = {} },
      },
    }
    TG.currentGuide = { key = "k", steps = { step, { elements = {} } } }
    TG.currentStepIndex = 1
    TG.db = {}
    TG.cdb = {}
    TG._manualNavHold = true
    TG._manualNavStep = 1
    TG._manualNavSignature = "stale"
    TG.PlayerMovedSinceManualNav = function()
      return false
    end
    local advanced = false
    TG.NextStep = function()
      advanced = true
    end
    _G.event = "TRAINER_SHOW"
    env.scripts.OnEvent()
    env.eq(advanced, false)
    _G.event = "TRAINER_CLOSED"
    env.scripts.OnEvent()
    env.eq(TG._manualNavHold, nil)
    env.eq(advanced, true)
  end,
}
