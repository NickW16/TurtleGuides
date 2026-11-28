local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_missing_prerequisites_use_pfquest_data = function()
    local TG = loadEngine()
    TG.db = {}
    TG.cdb = {}
    _G.pfDB = {
      quests = {
        loc = { [10] = "Ten", [20] = "Twenty" },
        data = { [10] = { pre = { 20 }, min = 5 } },
      },
    }
    _G.UnitLevel = function()
      return 3
    end
    local missing = TG:GetMissingPrerequisites(10)
    env.eq(table.getn(missing), 2)
    local hasQuest, hasLevel = false, false
    for _, item in ipairs(missing) do
      if item.id == 20 and item.title == "Twenty" then
        hasQuest = true
      end
      if item.level == 5 then
        hasLevel = true
      end
    end
    env.eq(hasQuest, true)
    env.eq(hasLevel, true)
  end,

  test_completed_prerequisites_are_not_missing = function()
    local TG = loadEngine()
    TG.db = {}
    TG.cdb = {}
    _G.pfDB = {
      quests = {
        loc = { [10] = "Ten", [20] = "Twenty" },
        data = { [10] = { pre = { 20 }, min = 5 } },
      },
    }
    _G.pfQuest_history = { [20] = true }
    _G.UnitLevel = function()
      return 6
    end
    local missing = TG:GetMissingPrerequisites(10)
    env.eq(table.getn(missing), 0)
  end,

  test_prerequisite_warning_prints_once = function()
    local TG = loadEngine()
    TG.db = {}
    TG.cdb = {}
    _G.pfDB = {
      quests = {
        loc = { [10] = "Ten", [20] = "Twenty" },
        data = { [10] = { pre = { 20 } } },
      },
    }
    local step = { elements = { { t = "cmd", tag = "accept", args = { "10" } } } }
    TG:WarnStepPrerequisites(step)
    TG:WarnStepPrerequisites(step)
    local count = 0
    for _, message in ipairs(env.messages) do
      if string.find(message, "Missing prerequisites for Ten: Twenty", 1, true) then
        count = count + 1
      end
    end
    env.eq(count, 1)
  end,

  test_no_pfquest_data_has_no_warnings = function()
    local TG = loadEngine()
    TG.db = {}
    TG.cdb = {}
    env.eq(table.getn(TG:GetMissingPrerequisites(10)), 0)
  end,
}
