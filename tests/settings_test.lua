local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/core/Util.lua", "src/ui/State.lua", "src/ui/Text.lua", "src/ui/Settings.lua")
end

return {
  test_settings_toggles_are_bound_to_db = function()
    local TG = fresh()
    TG.db = { showArrow = false }
    TG:ShowSettings()
    local frame = TG.UI.State.settings
    env.eq(frame:IsShown(), true)
    env.eq(table.getn(frame.rows), 10)
    local arrow = frame.rows[1]
    env.eq(string.find(arrow.text.value or "", "[ ]", 1, true) ~= nil, true)
    arrow.scripts.OnClick()
    env.eq(TG.db.showArrow, true)
    env.eq(string.find(arrow.text.value or "", "[x]", 1, true) ~= nil, true)
  end,

  test_font_size_buttons_change_scale = function()
    local TG = fresh()
    TG.db = { fontScale = 1.0 }
    TG.RefreshFonts = function() end
    TG:ShowSettings()
    local plus
    for _, frame_ in ipairs(env.frames) do
      if frame_.kind == "Button" and frame_.text and frame_.text.value == "+" then
        plus = frame_
      end
    end
    plus.scripts.OnClick()
    env.eq(TG.db.fontScale, 1.1)
  end,
}
