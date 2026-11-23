local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_engine_events_are_registered = function()
    loadEngine()
    env.load("src/engine/Events.lua")
    local found = {}
    for _, event in ipairs(env.registered) do
      found[event] = true
    end
    env.eq(found.QUEST_LOG_UPDATE, true)
    env.eq(found.QUEST_ACCEPTED, true)
    env.eq(found.BAG_UPDATE, true)
    env.eq(found.PLAYER_LEVEL_UP, true)
  end,
}
