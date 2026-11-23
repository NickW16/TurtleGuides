local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/compat/Runtime.lua", "src/ui/Minimap.lua")
end

return {
  test_init_creates_button = function()
    local TG = fresh()
    TG.db = { showMinimap = true, minimapPos = 220 }
    TG:InitMinimap()
    env.eq(TG.minimapButton ~= nil, true)
  end,

  test_visibility_setting_hides_button = function()
    local TG = fresh()
    TG.db = { showMinimap = true, minimapPos = 220 }
    TG:InitMinimap()
    TG.db.showMinimap = false
    TG:UpdateMinimap()
    env.eq(TG.minimapButton.visible, false)
  end,
}
