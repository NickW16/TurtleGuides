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
  TG.db = {}
  return TG
end

local function withGuides(TG)
  TG.GetGuidesForPicker = function()
    return { { name = "Starter", guides = { { key = "human", group = "Alliance", name = "Human 1-10" } } } }
  end
end

return {
  test_picker_has_flipper_instead_of_cog = function()
    local TG = fresh()
    withGuides(TG)
    TG:ShowGuidePicker()
    local picker = TG.UI.State.picker
    env.eq(picker.flipper ~= nil, true)
    env.eq(string.find(picker.flipper.arrow.path or "", "NavChevron", 1, true) ~= nil, true)
  end,

  test_show_picker_docks_settings = function()
    local TG = fresh()
    withGuides(TG)
    TG:ShowGuidePicker()
    local picker = TG.UI.State.picker
    local settings = TG.UI.State.settings
    env.eq(picker:IsShown(), true)
    env.eq(settings:IsShown(), true)
    env.eq(picker.flipper.arrow.path, "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronRight")
  end,

  test_flipper_toggles_settings = function()
    local TG = fresh()
    withGuides(TG)
    TG:ShowGuidePicker()
    local settings = TG.UI.State.settings
    TG:ToggleSettingsDocked()
    env.eq(settings:IsShown(), false)
    env.eq(TG.UI.State.picker.flipper.arrow.path, "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronLeft")
    TG:ToggleSettingsDocked()
    env.eq(settings:IsShown(), true)
  end,

  test_windows_share_main_bar_style = function()
    local TG = fresh()
    withGuides(TG)
    TG:ShowGuidePicker()
    local bars = 0
    for _, texture in ipairs(env.textures) do
      if texture.path == "Interface\\AddOns\\TurtleGuides\\Media\\BarTexture" then
        bars = bars + 1
      end
    end
    env.eq(bars >= 4, true)
  end,

  test_escape_hides_picker_and_settings = function()
    local TG = fresh()
    withGuides(TG)
    TG:ShowGuidePicker()
    local picker = TG.UI.State.picker
    local settings = TG.UI.State.settings
    _G.arg1 = "ESCAPE"
    picker.scripts.OnKeyDown()
    env.eq(picker:IsShown(), false)
    env.eq(settings:IsShown(), false)
  end,
}
