local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/ui/State.lua",
    "src/ui/Text.lua",
    "src/ui/Widgets.lua",
    "src/ui/Settings.lua"
  )
end

return {
  test_settings_toggles_are_bound_to_db = function()
    local TG = fresh()
    TG.db = { showArrow = false }
    TG:ShowSettings()
    local frame = TG.UI.State.settings
    env.eq(frame:IsShown(), true)
    env.eq(table.getn(frame.checks), 10)
    local arrow = frame.checks[1]
    arrow:SetChecked(1)
    arrow.scripts.OnClick()
    env.eq(TG.db.showArrow, true)
    TG:RefreshSettings()
    env.eq(arrow.checked, 1)
  end,
}
