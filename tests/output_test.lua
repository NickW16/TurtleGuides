local env = dofile("tests/env.lua")

return {
  test_print_prefixes_message = function()
    env.reset()
    local TG = env.load("src/Core.lua", "src/core/Output.lua")
    TG:Print("hello")
    env.eq(#env.messages, 1)
    env.eq(env.messages[1], TG.C.gold .. "TurtleGuides:|r hello")
  end,
}
