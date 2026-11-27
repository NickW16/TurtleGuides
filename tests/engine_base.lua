-- shared engine stack loading for tests
local env = dofile("tests/env.lua")

local function loadEngine()
  env.reset()
  env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/compat/ZoneData.lua",
    "src/compat/Zone.lua",
    "src/compat/QuestLog.lua",
    "src/compat/Item.lua",
    "src/core/Output.lua",
    "src/core/State.lua",
    "src/core/Events.lua",
    "src/engine/State.lua",
    "src/engine/QuestDiff.lua",
    "src/engine/Quests.lua",
    "src/engine/Conditions.lua",
    "src/engine/Manual.lua",
    "src/engine/Completion.lua",
    "src/engine/Goto.lua",
    "src/engine/Navigation.lua",
    "src/engine/Advance.lua",
    "src/engine/Debug.lua"
  )
  local TG = _G.TurtleGuides
  TG._questLogSeeded = true
  return TG
end

return env, loadEngine
