local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/core/Output.lua", "src/core/Events.lua")
end

return {
  test_register_event_deduplicates_registration = function()
    local TG = fresh()
    local calls = 0
    TG:RegisterEvent("TEST", function()
      calls = calls + 1
    end)
    TG:RegisterEvent("TEST", function()
      calls = calls + 1
    end)
    env.eq(#env.registered, 1)
    _G.event = "TEST"
    env.scripts.OnEvent()
    env.eq(calls, 2)
  end,

  test_event_dispatch_forwards_arguments = function()
    local TG = fresh()
    local received
    TG:RegisterEvent("TEST", function(ev, arg1, arg2)
      received = { ev, arg1, arg2 }
    end)
    _G.event = "TEST"
    _G.arg1 = "first"
    env.scripts.OnEvent()
    env.eq(received[1], "TEST")
    env.eq(received[2], "first")
  end,

  test_unregister_event_removes_handlers = function()
    local TG = fresh()
    TG:RegisterEvent("TEST", function() end)
    TG:UnregisterEvent("TEST")
    env.eq(TG.events.TEST, nil)
  end,

  test_updaters_run_on_interval = function()
    local TG = fresh()
    local runs = 0
    TG:AddUpdater("tick", 1, function()
      runs = runs + 1
    end)
    _G.arg1 = 0.5
    env.scripts.OnUpdate()
    env.eq(runs, 0)
    _G.arg1 = 0.6
    env.scripts.OnUpdate()
    env.eq(runs, 1)
    TG:RemoveUpdater("tick")
    env.scripts.OnUpdate()
    env.eq(runs, 1)
  end,

  test_updater_error_does_not_stop_other_updaters = function()
    local TG = fresh()
    local runs = 0
    TG:AddUpdater("bad", 1, function()
      error("boom")
    end)
    TG:AddUpdater("good", 1, function()
      runs = runs + 1
    end)
    _G.arg1 = 1
    env.scripts.OnUpdate()
    env.eq(runs, 1)
    env.scripts.OnUpdate()
    env.eq(runs, 2)
    local reported = 0
    for _, msg in ipairs(env.messages) do
      if string.find(msg, "bad failed", 1, true) then
        reported = reported + 1
      end
    end
    env.eq(reported, 1)
  end,

  test_updater_can_remove_itself = function()
    local TG = fresh()
    local runs = 0
    TG:AddUpdater("once", 1, function()
      runs = runs + 1
      TG:RemoveUpdater("once")
    end)
    _G.arg1 = 1
    env.scripts.OnUpdate()
    env.scripts.OnUpdate()
    env.eq(runs, 1)
  end,
}
