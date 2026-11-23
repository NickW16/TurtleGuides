local env = dofile("tests/env.lua")

return {
  test_on_initialize_runs_modules_in_order = function()
    env.reset()
    local TG = env.load(
      "src/Core.lua",
      "src/core/Util.lua",
      "src/core/Output.lua",
      "src/core/State.lua",
      "src/core/Events.lua",
      "src/core/Init.lua"
    )
    local calls = {}
    TG.InitCompat = function()
      table.insert(calls, "compat")
    end
    TG.LoadAllGuides = function()
      table.insert(calls, "guides")
    end
    TG.InitArrow = function()
      table.insert(calls, "arrow")
    end
    TG.InitUI = function()
      table.insert(calls, "ui")
    end
    TG.InitAutomation = function()
      table.insert(calls, "automation")
    end
    TG.InitVendor = function()
      table.insert(calls, "vendor")
    end
    TG.InitMinimap = function()
      table.insert(calls, "minimap")
    end
    TG.CollectGarbage = function()
      table.insert(calls, "gc")
    end
    TG:OnInitialize()
    env.eq(table.concat(calls, ","), "compat,guides,arrow,ui,automation,vendor,minimap,gc")
  end,

  test_player_login_event_registered = function()
    env.reset()
    env.load("src/Core.lua", "src/core/Events.lua", "src/core/Init.lua")
    env.eq(env.registered[1], "PLAYER_LOGIN")
  end,
}
