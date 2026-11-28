-- quest evidence, tracking, and quest-related event handlers
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local QuestDiff = TG.Engine.QuestDiff
local strtrim = TG.Util.strtrim
local Quests = {}
TG.Engine.Quests = Quests

local Ledger = {}
TG.Engine.QuestLedger = Ledger

local function titleKey(title)
  if not title or title == "" then
    return nil
  end
  return string.lower(title)
end

local function ensureIdRecord(ledger, id, title)
  local rec = ledger.byId[id]
  if not rec then
    rec = { id = id, title = title, inLog = false, complete = false, logIndex = nil }
    ledger.byId[id] = rec
    table.insert(ledger.logIds, id)
  end
  return rec
end

function Quests.canReadQuestIds()
  if not GetNumQuestLogEntries or not GetQuestLogTitle or not TG.GetQuestIdsForLogIndex then
    return false
  end
  local ok, n = pcall(GetNumQuestLogEntries)
  if not ok or type(n) ~= "number" or n == 0 then
    return false
  end
  for i = 1, n do
    local ids = TG:GetQuestIdsForLogIndex(i)
    if ids and ids[1] then
      return true
    end
  end
  return false
end

function Quests.recentlyAccepted(id)
  if not GetTime then
    return false
  end
  local t = TG._recentAccept and TG._recentAccept[tonumber(id)]
  if not t then
    return false
  end
  return (GetTime() - t) <= Shared.RECENT_ACCEPT_WINDOW
end

function TG:QuestEvidenceConfidence(id, title)
  local ledger = self:GetQuestLedger()
  local numeric = tonumber(id)
  if numeric then
    if ledger.turnedIn[numeric] or Quests.recentlyAccepted(numeric) then
      return "confirmed"
    end
    local rec = ledger.byId[numeric]
    if rec and rec.inLog then
      return "confirmed"
    end
  end
  local key = titleKey(title)
  if key then
    local titleRec = ledger.byTitle[key]
    if titleRec and titleRec.inLog then
      return "confirmed"
    end
    if ledger.confirmedTitles[key] then
      return "confirmed"
    end
    if ledger.turnedInTitles[key] then
      return "weak"
    end
  end
  if numeric and ledger.accountTurnedIn[numeric] then
    return "weak"
  end
  return nil
end

function TG:SeedQuestLog()
  self._questLogSeeded = true
  if self.InvalidateQuestLedger then
    self:InvalidateQuestLedger()
  end
end

function TG:InvalidateQuestLedger()
  self._questLedgerDirty = true
end

function TG:RefreshQuestLedger()
  local ledger = {
    byId = {},
    byTitle = {},
    logIds = {},
    turnedIn = {},
    accountTurnedIn = {},
    turnedInTitles = {},
    confirmedTitles = {},
    recent = {},
    canReadIds = false,
  }
  local okRead, canRead = pcall(Quests.canReadQuestIds)
  ledger.canReadIds = okRead and canRead or false

  for id in pairs(self.cdb and self.cdb.turnedIn or {}) do
    local numeric = tonumber(id)
    if numeric then
      ledger.turnedIn[numeric] = true
      ensureIdRecord(ledger, numeric)
    end
  end
  if type(pfQuest_history) == "table" then
    for id in pairs(pfQuest_history) do
      local numeric = tonumber(id)
      if numeric then
        ledger.accountTurnedIn[numeric] = true
        ensureIdRecord(ledger, numeric)
      else
        local key = titleKey(id)
        if key then
          ledger.turnedInTitles[key] = true
        end
      end
    end
  end
  for id in pairs(self._recentAccept or {}) do
    local numeric = tonumber(id)
    if numeric then
      ledger.recent[numeric] = true
      ensureIdRecord(ledger, numeric)
    end
  end
  for title in pairs(self._turnedInTitles or {}) do
    local key = titleKey(title)
    if key then
      ledger.turnedInTitles[key] = true
    end
  end
  for title in pairs(self.cdb and self.cdb.turnedInTitles or {}) do
    local key = titleKey(title)
    if key then
      ledger.confirmedTitles[key] = true
      ledger.turnedInTitles[key] = true
    end
  end

  local n = 0
  if GetNumQuestLogEntries then
    local okCount, count = pcall(GetNumQuestLogEntries)
    if okCount and type(count) == "number" then
      n = count
    end
  end
  for i = 1, n do
    if GetQuestLogTitle then
      local okTitle, title, _, _, isHeader, _, isComplete = pcall(GetQuestLogTitle, i)
      if okTitle and title and not isHeader then
        local complete = isComplete == 1 or isComplete == -1
        local key = titleKey(title)
        local titleRec = ledger.byTitle[key]
        if not titleRec then
          titleRec = { title = title, ids = {}, inLog = false, complete = false, logIndex = nil }
          ledger.byTitle[key] = titleRec
        end
        titleRec.inLog = true
        titleRec.logIndex = titleRec.logIndex or i
        titleRec.complete = titleRec.complete or complete

        local okIds, ids = pcall(function()
          return self.GetQuestIdsForLogIndex and self:GetQuestIdsForLogIndex(i)
        end)
        if not okIds then
          ids = nil
        end
        for _, rawId in ipairs(ids or {}) do
          local id = tonumber(rawId)
          if id then
            local rec = ledger.byId[id]
            if not rec then
              rec = { id = id, title = title, inLog = false, complete = false, logIndex = nil }
              ledger.byId[id] = rec
              table.insert(ledger.logIds, id)
            end
            rec.inLog = true
            rec.logIndex = rec.logIndex or i
            rec.complete = rec.complete or complete
            local seen = false
            for _, existing in ipairs(titleRec.ids) do
              if existing == id then
                seen = true
                break
              end
            end
            if not seen then
              table.insert(titleRec.ids, id)
            end
          end
        end
      end
    end
  end

  self._questLedger = ledger
  self._questLedgerDirty = false
  return ledger
end

function TG:GetQuestLedger()
  if self._questLedgerDirty or not self._questLedger then
    return self:RefreshQuestLedger()
  end
  return self._questLedger
end

function TG:GetQuestEvidence(id, title)
  local ledger = self:GetQuestLedger()
  local numericId = tonumber(id)
  local rec = numericId and ledger.byId[numericId] or nil
  local key = titleKey(title)
  local titleRec = key and ledger.byTitle[key] or nil
  if not rec and titleRec and titleRec.ids[1] then
    rec = ledger.byId[titleRec.ids[1]]
  end
  if not rec and not titleRec then
    if key and (ledger.confirmedTitles[key] or ledger.turnedInTitles[key]) then
      return { id = numericId, title = title, inLog = false, complete = false, turnedIn = true, logIndex = nil }
    end
    return nil
  end

  local result = {
    id = rec and rec.id or (titleRec and titleRec.ids[1] or nil),
    title = (rec and rec.title) or (titleRec and titleRec.title) or title,
    inLog = false,
    complete = false,
    turnedIn = false,
    logIndex = nil,
  }
  if rec then
    result.inLog = rec.inLog == true
    result.complete = rec.complete == true
    result.logIndex = rec.logIndex
  end
  if titleRec then
    result.inLog = result.inLog or titleRec.inLog == true
    result.complete = result.complete or titleRec.complete == true
    result.logIndex = result.logIndex or titleRec.logIndex
    result.title = result.title or titleRec.title
  end
  if result.id then
    local numeric = tonumber(result.id)
    result.turnedIn = false
    if not result.inLog and (ledger.turnedIn[numeric] or ledger.accountTurnedIn[numeric]) then
      result.turnedIn = true
    end
  end
  if key and not result.inLog and ledger.turnedInTitles[key] then
    result.turnedIn = true
  end
  return result
end

function TG:GetElementQuestIds(el)
  if el and el.questIds and table.getn(el.questIds) > 0 then
    return el.questIds
  end
  local ids = {}
  if el then
    local id = tonumber(el.args and el.args[1])
    if id then
      table.insert(ids, math.abs(id))
    end
  end
  return ids
end

function TG:ResolveQuestTitle(el)
  local ids = self:GetElementQuestIds(el)
  local id = ids[1]
  local title
  if el.text and el.text ~= "" then
    title = TG.stripCodes and TG.stripCodes(el.text) or el.text
    title = string.gsub(title, "^Accept%s+", "")
    title = string.gsub(title, "^Turn in%s+", "")
    title = string.gsub(title, "^Turn In%s+", "")
    title = strtrim(title)
  end
  if (not title or title == "") and id and TG.GetQuestTitleById then
    title = TG:GetQuestTitleById(id)
  end
  return title, id
end

function TG:ParseXpArg(str)
  if not str then
    return nil, nil, nil
  end
  str = string.gsub(tostring(str), "%s", "")
  local op, levelStr, xpStr = string.match(str, "^([<>]?)(%d+)([%+%.%-]?%d*)$")
  if not levelStr then
    return nil, nil, nil
  end
  local level = tonumber(levelStr)
  local xp
  if xpStr and xpStr ~= "" then
    local sign = string.sub(xpStr, 1, 1)
    local value = tonumber(string.sub(xpStr, 2))
    if sign == "+" and value then
      xp = value
    elseif sign == "-" and value then
      xp = -value
    elseif sign == "." and value then
      xp = tonumber("0." .. value)
    else
      xp = tonumber(xpStr)
    end
  end
  if op == "<" then
    return "<", level, xp
  end
  if op == ">" then
    return ">", level, xp
  end
  return ">=", level, xp
end

function TG:IsElementTrackable(el)
  return el ~= nil
end

function TG:GetQuestLogIdByTitle(title)
  if not title or title == "" or not self.GetQuestIdForLogIndex then
    return nil
  end
  local want = string.lower(TG.stripCodes and TG.stripCodes(title) or title)
  local n = GetNumQuestLogEntries and GetNumQuestLogEntries() or 0
  for i = 1, n do
    local t, _, _, isHeader = GetQuestLogTitle(i)
    if not isHeader and t and string.lower(TG.stripCodes and TG.stripCodes(t) or t) == want then
      local id = self:GetQuestIdForLogIndex(i)
      if id then
        return id
      end
    end
  end
  return nil
end

function TG:OnQuestTurninDialog()
  local title = GetTitleText and GetTitleText() or nil
  if not title or title == "" then
    return
  end
  self._seenComplete[title] = true
  self._pendingTurnin[title] = self:GetQuestLogIdByTitle(title)
  self._turninCandidates[title] = {
    id = self._pendingTurnin[title],
    closedAt = nil,
  }
end

function TG:OnQuestFinished()
  local now = GetTime and GetTime() or 0
  local title = GetTitleText and GetTitleText() or nil
  local candidate = title and self._turninCandidates[title] or nil
  if candidate then
    candidate.closedAt = now
  else
    for _, pending in pairs(self._turninCandidates) do
      if not pending.closedAt then
        pending.closedAt = now
      end
    end
  end
  if self.OnQuestLogUpdate then
    self:OnQuestLogUpdate()
  end
end

function TG:OnQuestAccepted(questLogIndex)
  local idx = tonumber(questLogIndex)
  local title
  if idx and GetQuestLogTitle then
    title = GetQuestLogTitle(idx)
    if self.GetQuestIdsForLogIndex then
      local ids = self:GetQuestIdsForLogIndex(idx)
      if ids then
        local now = GetTime and GetTime() or 0
        for _, id in ipairs(ids) do
          local numeric = tonumber(id)
          if numeric then
            self._recentAccept[numeric] = now
            if self.cdb and self.cdb.turnedIn then
              self.cdb.turnedIn[numeric] = nil
            end
          end
        end
      end
    end
  end
  if title and title ~= "" then
    local key = titleKey(title)
    self._turnedInTitles[title] = nil
    self._turninCandidates[title] = nil
    if self.cdb and self.cdb.turnedInTitles then
      self.cdb.turnedInTitles[key] = nil
    end
  end
  self:InvalidateQuestLedger()
end

function TG:IsQuestTurnedIn(id)
  id = tonumber(id)
  if not id then
    return false
  end
  local evidence = self:GetQuestEvidence(id)
  if not evidence then
    return false
  end
  if evidence.inLog then
    return false
  end
  return evidence.turnedIn == true
end

function TG:MarkQuestTurnedIn(id, title)
  if id then
    local numeric = tonumber(id)
    self.cdb.turnedIn = self.cdb.turnedIn or {}
    self.cdb.turnedIn[numeric] = true
  end
  if title and title ~= "" then
    local key = titleKey(title)
    self._turnedInTitles[title] = true
    self.cdb.turnedInTitles = self.cdb.turnedInTitles or {}
    self.cdb.turnedInTitles[key] = true
  end
  self:InvalidateQuestLedger()
end

local function snapshotQuestLog(self)
  local rows = {}
  local n = 0
  if GetNumQuestLogEntries then
    local ok, count = pcall(GetNumQuestLogEntries)
    if ok and type(count) == "number" then
      n = count
    end
  end
  for i = 1, n do
    if GetQuestLogTitle then
      local ok, title, _, _, isHeader, _, isComplete = pcall(GetQuestLogTitle, i)
      local key = ok and title and not isHeader and titleKey(TG.stripCodes and TG.stripCodes(title) or title)
      if key then
        local ids = {}
        if self.GetQuestIdsForLogIndex then
          local okIds, found = pcall(self.GetQuestIdsForLogIndex, self, i)
          if okIds then
            ids = found or {}
          end
        end
        rows[key] = {
          title = title,
          ids = ids,
          complete = isComplete == 1 or isComplete == -1,
        }
      end
    end
  end
  return rows
end

local function candidateForTitle(self, title)
  local key = titleKey(title)
  for candidateTitle, candidate in pairs(self._turninCandidates) do
    if titleKey(candidateTitle) == key then
      return candidate, candidateTitle
    end
  end
  return nil
end

function TG:ApplyQuestLogDiff(previous, current)
  if not QuestDiff then
    return
  end
  local diff = QuestDiff.diff(previous, current)
  local now = GetTime and GetTime() or 0
  for _, row in ipairs(diff.accepted) do
    for _, id in ipairs(row.ids or {}) do
      local numeric = tonumber(id)
      if numeric then
        self._recentAccept[numeric] = now
        if self.cdb and self.cdb.turnedIn then
          self.cdb.turnedIn[numeric] = nil
        end
      end
    end
  end
  for _, row in ipairs(diff.removed) do
    local candidate = candidateForTitle(self, row.title)
    local confirmed = row.complete == true or (candidate and candidate.closedAt ~= nil)
    if confirmed then
      local marked = false
      for _, id in ipairs(row.ids or {}) do
        local numeric = tonumber(id)
        if numeric then
          self:MarkQuestTurnedIn(numeric, row.title)
          marked = true
        end
      end
      if not marked then
        self:MarkQuestTurnedIn(nil, row.title)
      end
    end
  end
end

function TG:ScanQuestTurnins()
  self:InvalidateQuestLedger()
  local snapshot = snapshotQuestLog(self)
  local previous = self._questLogSnapshot
  self._questLogSnapshot = snapshot
  if previous then
    self:ApplyQuestLogDiff(previous, snapshot)
  end

  local now = GetTime and GetTime() or 0
  for title, candidate in pairs(self._turninCandidates) do
    local expired = candidate.closedAt and (now - candidate.closedAt) > Shared.TURNIN_CONFIRM_WINDOW
    local absent = not snapshot[titleKey(title)]
    if expired then
      self._turninCandidates[title] = nil
      self._seenComplete[title] = nil
      self._pendingTurnin[title] = nil
    elseif candidate.closedAt and absent then
      self:MarkQuestTurnedIn(candidate.id, title)
      self._turninCandidates[title] = nil
      self._seenComplete[title] = nil
      self._pendingTurnin[title] = nil
    end
  end
end

Ledger.refresh = function()
  return TG:RefreshQuestLedger()
end
