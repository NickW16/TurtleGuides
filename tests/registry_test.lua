local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/parser/Registry.lua")
end

return {
  test_register_guide_text = function()
    local TG = fresh()
    TG:RegisterGuideText("step\n.accept 1", "manual")
    env.eq(table.getn(TG.rawGuides), 1)
    env.eq(TG.rawGuides[1].source, "manual")
  end,

  test_external_registration = function()
    local TG = fresh()
    _G.RXPGuides.RegisterGuide("step\n.accept 2", "Imported")
    env.eq(TG.rawGuides[1].source, "Imported")
  end,
}
