local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  local TG = env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/ui/State.lua",
    "src/ui/Icons.lua",
    "src/ui/Text.lua",
    "src/ui/Scrollbar.lua",
    "src/ui/Picker.lua",
    "src/ui/Settings.lua"
  )
  TG.GetGuidesForPicker = function()
    return {}
  end
  TG.db = {}
  return TG
end

return {
  test_settings_toggles_are_bound_to_db = function()
    local TG = fresh()
    TG.db = { showArrow = false }
    TG:ShowSettings()
    local frame = TG.UI.State.settings
    env.eq(TG.UI.State.picker:IsShown(), true)
    env.eq(frame:IsShown(), true)
    env.eq(table.getn(frame.rows), 10)
    local arrow = frame.rows[1]
    env.eq(arrow.checked, false)
    arrow.scripts.OnClick()
    env.eq(TG.db.showArrow, true)
    env.eq(arrow.checked, true)
  end,

  test_font_size_buttons_change_scale = function()
    local TG = fresh()
    TG.db = { fontScale = 1.0 }
    TG.RefreshFonts = function() end
    TG:ShowSettings()
    local plus
    for _, frame in ipairs(env.frames) do
      if frame.kind == "Button" and frame.text and frame.text.value == "+" then
        plus = frame
      end
    end
    plus.scripts.OnClick()
    env.eq(TG.db.fontScale, 1.1)
  end,

  test_escape_hides_the_menu = function()
    local TG = fresh()
    TG:ShowSettings()
    local picker = TG.UI.State.picker
    env.eq(picker:IsShown(), true)
    _G.arg1 = "ESCAPE"
    picker.search.scripts.OnKeyDown()
    env.eq(picker:IsShown(), false)
  end,

  test_menu_switches_views = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    env.eq(picker.title.value, "TurtleGuides")
    env.eq(picker.fieldBox:IsVisible(), true)
    env.eq(TG.UI.State.settings, nil)
    TG:ShowMenu("settings")
    env.eq(picker.title.value, "TurtleGuides")
    env.eq(picker.fieldBox:IsVisible(), false)
    env.eq(TG.UI.State.settings:IsShown(), true)
  end,
}
