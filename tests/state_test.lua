local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/core/Util.lua", "src/core/Output.lua", "src/core/State.lua")
end

return {
  test_init_db_applies_defaults = function()
    local TG = fresh()
    TG:InitDB()
    env.eq(TG.db.showArrow, true)
    env.eq(TG.cdb.stepIndex, 1)
  end,

  test_init_db_keeps_legacy_font_scale = function()
    local TG = fresh()
    _G.TurtleGuidesDB = { fontScale = 1.5 }
    TG:InitDB()
    env.eq(TG.db.fontScale, 1.5)
    env.eq(TG.db.uiScale, 1.0)
  end,

  test_player_info_uses_unit_globals = function()
    local TG = fresh()
    local player = TG:PlayerInfo()
    env.eq(player.class, "MAGE")
    env.eq(player.race, "Undead")
    env.eq(player.faction, "Horde")
    env.eq(player.level, 42)
  end,

  test_reset_guide_returns_to_first_step = function()
    local TG = fresh()
    TG:InitDB()
    TG.currentGuide = {}
    TG.currentStepIndex = 7
    TG:ResetGuide()
    env.eq(TG.currentStepIndex, 1)
    env.eq(TG.cdb.stepIndex, 1)
  end,
}
