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
    env.eq(picker.width, 400)
    env.eq(picker.height, 360)
  end,

  test_picker_has_sidebar_flipper = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    env.eq(picker.sidebar ~= nil, true)
    env.eq(picker.flipper ~= nil, true)
    env.eq(string.find(picker.flipper.arrow.path or "", "NavChevron", 1, true) ~= nil, true)
  end,

  test_sidebar_starts_open_and_flipper_toggles_it = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local picker = TG.UI.State.picker
    env.eq(picker.sidebar:IsVisible(), true)
    TG:ToggleSidebar()
    env.eq(picker.sidebar:IsVisible(), false)
    TG:ToggleSidebar()
    env.eq(picker.sidebar:IsVisible(), true)
  end,

  test_flipper_uses_borderless_chevrons = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local arrow = TG.UI.State.picker.flipper.arrow
    env.eq(arrow.path, "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronRight_Flat")
    TG:ToggleSidebar()
    env.eq(arrow.path, "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronLeft_Flat")
  end,

  test_only_active_sidebar_item_is_gold = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local buttons = TG.UI.State.picker.sidebarButtons
    local colors = {}
    for i, button in ipairs(buttons) do
      button.text.SetTextColor = function(_, r, g, b)
        colors[i] = { r, g, b }
      end
    end
    TG:ShowMenu("guides")
    env.eq(colors[1][3] < colors[2][3], true)
    TG:ShowMenu("settings")
    env.eq(colors[2][3] < colors[1][3], true)
  end,

  test_menu_keeps_topbar = function()
    local TG = fresh()
    TG:ShowMenu("guides")
    local bars = 0
    for _, texture in ipairs(env.textures) do
      if texture.path == "Interface\\AddOns\\TurtleGuides\\Media\\BarTexture" then
        bars = bars + 1
      end
    end
    env.eq(bars >= 1, true)
  end,
}
