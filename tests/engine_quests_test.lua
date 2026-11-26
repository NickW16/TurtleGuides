local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/compat/QuestLog.lua",
    "src/core/Output.lua",
    "src/core/State.lua",
    "src/engine/State.lua",
    "src/engine/Quests.lua"
  )
end

return {
  test_parse_xp_arg = function()
    local TG = fresh()
    local op, level, xp = TG:ParseXpArg("6+1130")
    env.eq(op, ">=")
    env.eq(level, 6)
    env.eq(xp, 1130)
    local lessOp, lessLevel = TG:ParseXpArg("<8")
    env.eq(lessOp, "<")
    env.eq(lessLevel, 8)
  end,

  test_resolve_quest_title = function()
    local TG = fresh()
    local title, id = TG:ResolveQuestTitle({ args = { "42" }, text = "Accept Foo" })
    env.eq(title, "Foo")
    env.eq(id, 42)
  end,

  test_turn_in_tracking = function()
    local TG = fresh()
    TG.cdb = {}
    env.eq(TG:IsQuestTurnedIn(42), false)
    TG:MarkQuestTurnedIn(42, "Foo")
    env.eq(TG:IsQuestTurnedIn(42), true)
    env.eq(TG._turnedInTitles.Foo, true)
  end,

  test_quest_accepted_uses_log_id = function()
    local TG = fresh()
    _G.GetQuestLogTitle = function()
      return "Foo", 1, nil, false, false, nil, nil, 99
    end
    TG:OnQuestAccepted(1)
    env.eq(TG._recentAccept[99] ~= nil, true)
  end,

  test_empty_quest_log_is_not_readable = function()
    local TG = fresh()
    env.eq(TG.Engine.Quests.canReadQuestIds(), false)
  end,

  test_scan_turnins_ignores_log_churn_without_confirmation = function()
    local TG = fresh()
    TG.cdb = {}
    _G.GetTime = function()
      return 10
    end
    local entries = { { title = "Foo", complete = 1, id = 42 } }
    local function applyLog()
      _G.GetNumQuestLogEntries = function()
        return table.getn(entries)
      end
      _G.GetQuestLogTitle = function(i)
        local e = entries[i]
        if not e then
          return
        end
        return e.title, 1, nil, false, false, e.complete, nil, e.id
      end
    end
    applyLog()
    TG:ScanQuestTurnins()
    entries = {}
    applyLog()
    TG:ScanQuestTurnins()
    env.eq(TG:IsQuestTurnedIn(42), false)
    env.eq(TG._turnedInTitles.Foo, nil)
  end,

  test_scan_turnins_confirms_after_dialog_close = function()
    local TG = fresh()
    TG.cdb = {}
    _G.GetTime = function()
      return 10
    end
    local entries = { { title = "Foo", complete = 1, id = 42 } }
    _G.GetNumQuestLogEntries = function()
      return table.getn(entries)
    end
    _G.GetQuestLogTitle = function(i)
      local e = entries[i]
      if not e then
        return
      end
      return e.title, 1, nil, false, false, e.complete, nil, e.id
    end
    _G.GetTitleText = function()
      return "Foo"
    end
    TG:OnQuestTurninDialog()
    TG:OnQuestFinished()
    entries = {}
    TG:ScanQuestTurnins()
    env.eq(TG:IsQuestTurnedIn(42), true)
    env.eq(TG._turnedInTitles.Foo, true)
  end,

  test_reaccept_clears_turned_in_title = function()
    local TG = fresh()
    TG.cdb = {}
    TG:MarkQuestTurnedIn(42, "Foo")
    _G.GetNumQuestLogEntries = function()
      return 1
    end
    _G.GetQuestLogTitle = function()
      return "Foo", 1, nil, false, false, nil, nil, 42
    end
    TG:OnQuestAccepted(1)
    env.eq(TG._turnedInTitles.Foo, nil)
    env.eq(TG:IsQuestTurnedIn(42), false)
  end,

  test_ledger_prefers_id_over_title = function()
    local TG = fresh()
    TG.cdb = {}
    _G.GetNumQuestLogEntries = function()
      return 2
    end
    _G.GetQuestLogTitle = function(i)
      if i == 1 then
        return "Different Title", 1, nil, false, false, nil, nil, 42
      end
      return "Right Title", 1, nil, false, false, nil, nil, 99
    end
    TG:InvalidateQuestLedger()

    local byId = TG:GetQuestEvidence(42, "Right Title")
    env.eq(byId.id, 42)
    env.eq(byId.title, "Different Title")
    env.eq(byId.inLog, true)

    local byTitle = TG:GetQuestEvidence(nil, "Right Title")
    env.eq(byTitle.id, 99)
    env.eq(byTitle.title, "Right Title")
  end,

  test_element_quest_ids_fallback_normalizes_negative_id = function()
    local TG = fresh()
    local el = { args = { "-414" } }
    local ids = TG:GetElementQuestIds(el)
    env.eq(ids[1], 414)
    el.questIds = { 414 }
    env.eq(TG:GetElementQuestIds(el)[1], 414)
  end,

  test_ledger_survives_id_lookup_errors = function()
    local TG = fresh()
    TG.cdb = {}
    _G.GetNumQuestLogEntries = function()
      return 1
    end
    _G.GetQuestLogTitle = function()
      return "Foo", 1, nil, false, false, nil, nil, 42
    end
    TG.GetQuestIdsForLogIndex = function()
      error("id api unavailable")
    end
    local ok = pcall(function()
      return TG:GetQuestLedger()
    end)
    env.eq(ok, true)
    env.eq(TG:GetQuestLedger().canReadIds, false)
  end,
}
