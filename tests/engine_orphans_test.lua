local env, loadEngine = dofile("tests/engine_base.lua")

return {
  test_orphan_quests_are_flagged = function()
    local TG = loadEngine()
    TG.db = {}
    TG.cdb = {}
    TG.currentGuide = {
      key = "A",
      name = "A",
      steps = {
        { elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept One" } } },
        { elements = { { t = "cmd", tag = "turnin", args = { "1" }, text = "Turn in One" } } },
      },
    }
    TG.currentStepIndex = 1
    _G.GetNumQuestLogEntries = function()
      return 2
    end
    _G.GetQuestLogTitle = function(i)
      if i == 1 then
        return "One", 1, nil, false, false, nil, nil, 1
      end
      return "Stray", 1, nil, false, false, nil, nil, 99
    end
    local orphans = TG:GetOrphanQuests()
    env.eq(table.getn(orphans), 1)
    env.eq(orphans[1].id, 99)
    env.eq(orphans[1].title, "Stray")
  end,

  test_orphan_announcement_prints_lines = function()
    local TG = loadEngine()
    TG.db = {}
    TG.cdb = {}
    TG.currentGuide = {
      key = "A",
      name = "A",
      steps = { { elements = { { t = "text", text = "only" } } } },
    }
    TG.currentStepIndex = 1
    _G.GetNumQuestLogEntries = function()
      return 1
    end
    _G.GetQuestLogTitle = function()
      return "Stray", 1, nil, false, false, nil, nil, 99
    end
    TG:AnnounceOrphanQuests()
    local found = false
    for _, message in ipairs(env.messages) do
      if string.find(message, "Orphan quest: Stray (99)", 1, true) then
        found = true
      end
    end
    env.eq(found, true)
  end,

  test_no_guide_has_no_orphans = function()
    local TG = loadEngine()
    TG.db = {}
    TG.cdb = {}
    TG.currentGuide = nil
    env.eq(table.getn(TG:GetOrphanQuests()), 0)
  end,
}
