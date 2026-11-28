-- quests in the log that the active guide does not expect
local TG = _G.TurtleGuides
local Orphans = {}
TG.Engine.Orphans = Orphans

function TG:GetOrphanQuests()
  if not self.currentGuide then
    return {}
  end
  local expected, turnedIn, future = self:GetExpectedQuestLog()
  local ledger = self:GetQuestLedger()
  local result = {}
  for id, rec in pairs(ledger.byId) do
    if rec.inLog and not expected[id] and not future[id] and not turnedIn[id] then
      local title = rec.title
      if not title or title == "" then
        title = self.GetQuestTitleById and self:GetQuestTitleById(id) or nil
      end
      table.insert(result, { id = id, title = title or ("#" .. tostring(id)) })
    end
  end
  table.sort(result, function(a, b)
    return tostring(a.title) < tostring(b.title)
  end)
  return result
end

function TG:AnnounceOrphanQuests()
  local orphans = self:GetOrphanQuests()
  if table.getn(orphans) == 0 then
    self:Print("No orphan quests found.")
    return
  end
  for _, orphan in ipairs(orphans) do
    self:Print("Orphan quest: " .. orphan.title .. " (" .. orphan.id .. ")")
  end
end

Orphans.list = TG.GetOrphanQuests
