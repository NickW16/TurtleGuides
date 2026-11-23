local env = dofile("tests/env.lua")

return {
  test_builders_create_frames = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/ui/Widgets.lua")
    local Widgets = TG.UI.Widgets
    local parent = { CreateFrame = nil }
    local button = Widgets.makeButton(parent, "Go", 0, 0, function() end)
    env.eq(button.text, "Go")
    local check = Widgets.makeCheck(parent, "Enable", 0, 20, function()
      return true
    end, function() end)
    env.eq(check.text.value, "Enable")
    local slider = Widgets.makeSlider(parent, "Scale", 0, 40, 1, 2, 0.1, function()
      return 1.5
    end, function() end)
    env.eq(slider.labelText ~= nil, true)
  end,

  test_short_text = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/ui/Widgets.lua")
    env.eq(TG.UI.Widgets.shortText("abcdef", 4), "a...")
  end,
}
