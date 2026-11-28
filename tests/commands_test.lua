local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/core/Util.lua", "src/core/Output.lua", "src/core/Commands.lua")
end

return {
  test_toggle_command_calls_ui = function()
    local TG = fresh()
    local toggled = false
    TG.ToggleUI = function()
      toggled = true
    end
    _G.SlashCmdList.TURTLEGUIDES("toggle")
    env.eq(toggled, true)
  end,

  test_arrow_command_toggles_setting = function()
    local TG = fresh()
    TG.db = { showArrow = false }
    _G.SlashCmdList.TURTLEGUIDES("arrow")
    env.eq(TG.db.showArrow, true)
    env.eq(env.messages[1], TG.C.gold .. "TurtleGuides:|r Arrow: on")
  end,

  test_orphans_command_calls_announcement = function()
    local TG = fresh()
    local called = false
    TG.AnnounceOrphanQuests = function()
      called = true
    end
    _G.SlashCmdList.TURTLEGUIDES("orphans")
    env.eq(called, true)
  end,

  test_unknown_command_prints_help = function()
    fresh()
    _G.SlashCmdList.TURTLEGUIDES("bogus")
    env.eq(#env.messages, 1)
    env.eq(string.find(env.messages[1], "Commands:", 1, true) ~= nil, true)
  end,

  test_suggest_falls_back_to_settings = function()
    local TG = fresh()
    local tab
    TG.ShowSettings = function(_, value)
      tab = value
    end
    _G.SlashCmdList.TURTLEGUIDES("suggest")
    env.eq(tab, "Guides")
  end,
}
