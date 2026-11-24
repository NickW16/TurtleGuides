local env = dofile("tests/env.lua")

return {
  test_default_theme_and_scale = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/ui/State.lua", "src/ui/Theme.lua")
    TG.db = {}
    env.eq(TG.UI.Theme.current().name, "Modern")
    env.eq(TG.UI.Theme.scale(), 1.0)
    env.eq(table.getn(TG.UI.Theme.order), 7)
  end,
}
