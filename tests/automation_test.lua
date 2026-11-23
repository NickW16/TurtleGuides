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
