local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/ui/State.lua",
    "src/ui/Theme.lua",
    "src/ui/StepText.lua",
    "src/ui/MainWindow.lua"
  )
end

return {
  test_init_creates_main_window = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    env.eq(TG.mainFrame ~= nil, true)
    env.eq(table.getn(TG.UI.State.stepRows), 32)
  end,

  test_update_without_guide = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    TG:UpdateUI()
    env.eq(TG.mainFrame.guideName.value, "No guide selected. Click Guides.")
  end,

  test_toggle_hides_and_shows = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    TG:ToggleUI()
    env.eq(TG.mainFrame.visible, false)
    TG:ToggleUI()
    env.eq(TG.mainFrame.visible, true)
  end,
}
