local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/compat/Text.lua", "src/compat/QuestLog.lua")
end

local function withQuestLog(TG)
  local entries = {
    { title = "Header", level = 0, tag = nil, header = true, complete = nil, id = nil },
    { title = "First Quest", level = 10, tag = nil, header = false, complete = nil, id = 101 },
    { title = "Second Quest", level = 12, tag = nil, header = false, complete = 1, id = 102 },
  }
  _G.GetNumQuestLogEntries = function()
    return table.getn(entries)
  end
  _G.GetQuestLogTitle = function(i)
    local e = entries[i]
    if not e then
      return
    end
    return e.title, e.level, e.tag, e.header, false, e.complete, nil, e.id
  end
  return TG
end

return {
  test_iterate_skips_headers = function()
    local TG = withQuestLog(fresh())
    local titles = {}
    for _, title in TG:IterateQuestLog() do
      table.insert(titles, title)
    end
    env.eq(table.concat(titles, ","), "First Quest,Second Quest")
  end,

  test_lookup_strips_color_codes = function()
    local TG = withQuestLog(fresh())
    env.eq(TG:GetQuestLogIndexByTitle("|cffff0000First Quest|r"), 2)
    env.eq(TG:GetQuestLogIndexByTitle("first quest"), 2)
  end,

  test_complete_status_comes_from_log = function()
    local TG = withQuestLog(fresh())
    env.eq(TG:IsQuestComplete("Second Quest"), 1)
  end,

  test_quest_lookup_by_id = function()
    local TG = withQuestLog(fresh())
    env.eq(TG:GetQuestLogIndexById(101), 2)
    env.eq(TG:GetQuestTitleById(101), "First Quest")
  end,

  test_objectives_are_read_from_leaderboard = function()
    local TG = withQuestLog(fresh())
    _G.GetNumQuestLeaderBoards = function()
      return 1
    end
    _G.GetQuestLogLeaderBoard = function()
      return "Kill 3 boars", "monster", true
    end
    local objectives = TG:GetQuestObjectives("First Quest")
    env.eq(objectives[1].text, "Kill 3 boars")
    env.eq(objectives[1].done, true)
    env.eq(TG:GetObjectiveDone("First Quest", 1), true)
  end,
}
