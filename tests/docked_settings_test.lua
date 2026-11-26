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
    return { { name = "Starter", guides = {} } }
  end
  TG.db = {}
  return TG
end

return {
  test_escape_binding_is_temporary = function()
    local TG = fresh()
    env.bindings.ESCAPE = "TOGGLEGAMEMENU"
    TG:ShowMenu("guides")
    env.eq(env.bindings.ESCAPE, "CLICK TurtleGuidesMenuCloseButton:LeftButton")
    TG:HideMenu()
    env.eq(env.bindings.ESCAPE, "TOGGLEGAMEMENU")
  end,

  test_menu_does_not_capture_keyboard = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    env.eq(picker.keyboardEnabled, nil)
    env.eq(picker.scripts.OnKeyDown, nil)
  end,

  test_opening_menu_does_not_focus_search = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    picker.search.SetFocus = function()
      error("search must not steal movement keys")
    end
    TG:ShowMenu("guides")
  end,

  test_picker_default_size = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    env.eq(picker.width, 280)
    env.eq(picker.height, 360)
  end,

  test_view_tabs_show_active_state = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    local colors = {}
    for _, tab in ipairs(picker.viewTabs) do
      tab.text.SetTextColor = function(_, r, g, b)
        colors[tab.view] = { r, g, b }
      end
    end
    TG:ShowMenu("guides")
    env.eq(colors.guides[3] < colors.settings[3], true)
    env.eq(picker.fieldBox:IsVisible(), true)
    picker.settingsTab.scripts.OnClick()
    env.eq(colors.settings[3] < colors.guides[3], true)
    env.eq(picker.fieldBox:IsVisible(), false)
    env.eq(TG.UI.State.settings:IsShown(), true)
    picker.guidesTab.scripts.OnClick()
    env.eq(colors.guides[3] < colors.settings[3], true)
    env.eq(picker.fieldBox:IsVisible(), true)
  end,

  test_footer_has_links_and_version = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    env.eq(picker.version.value, "v0.1.0")
    env.eq(picker.githubButton ~= nil, true)
    env.eq(picker.kofiButton ~= nil, true)
    picker.githubButton.scripts.OnClick()
    env.eq(TG.UI.State.linkPopup:IsShown(), true)
    env.eq(TG.UI.State.linkPopup.box:GetText(), "https://github.com/NickW16/TurtleGuides")
  end,
}
