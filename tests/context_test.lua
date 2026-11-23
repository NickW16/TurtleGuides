local env = dofile("tests/env.lua")

return {
  test_context_uses_player_info = function()
    env.reset()
    local TG = env.load(
      "src/Core.lua",
      "src/core/Util.lua",
      "src/core/Output.lua",
      "src/core/State.lua",
      "src/parser/Applies.lua",
      "src/parser/Context.lua"
    )
    local ctx = TG.Parser.Context.player()
    env.eq(ctx.class, "MAGE")
    env.eq(ctx.race, "Undead")
    env.eq(ctx.race2, "Scourge")
    env.eq(ctx.faction, "Horde")
    env.eq(ctx.level, 42)
    env.eq(ctx.sex, 2)
  end,
}
