-- quest evidence, tracking, and quest-related event handlers
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local strtrim = TG.Util.strtrim
local Quests = {}
TG.Engine.Quests = Quests

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

function TG:ResolveQuestTitle(el)
  local id = el.args and tonumber(el.args[1])
  local title
  if el.text and el.text ~= "" then
    title = el.text
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
  if not el or el.t ~= "cmd" then
    return false
  end
  local tag = el.tag
  return tag == "accept" or tag == "turnin" or tag == "complete" or tag == "collect" or tag == "xp"
end

function TG:GetQuestLogIdByTitle(title)
  if not title or title == "" or not self.GetQuestIdForLogIndex then
    return nil
  end
  local want = string.lower(title)
  local n = GetNumQuestLogEntries and GetNumQuestLogEntries() or 0
  for i = 1, n do
    local t, _, _, isHeader = GetQuestLogTitle(i)
    if not isHeader and t and string.lower(t) == want then
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
          self._recentAccept[id] = now
        end
      end
    end
  end
  if title and title ~= "" then
    self._turnedInTitles[title] = nil
    self._turninCandidates[title] = nil
  end
end

function TG:IsQuestTurnedIn(id)
  id = tonumber(id)
  if not id then
    return false
  end
  if self.GetQuestLogIndexById and self:GetQuestLogIndexById(id) then
    return false
  end
  if pfQuest_history and pfQuest_history[id] then
    return true
  end
  if self.cdb and self.cdb.turnedIn and self.cdb.turnedIn[id] then
    return true
  end
  return false
end

function TG:MarkQuestTurnedIn(id, title)
  if id then
    self.cdb.turnedIn = self.cdb.turnedIn or {}
    self.cdb.turnedIn[tonumber(id)] = true
  end
  if title then
    self._turnedInTitles[title] = true
  end
end

function TG:ScanQuestTurnins()
  local present = {}
  local n = GetNumQuestLogEntries()
  for i = 1, n do
    local title, _, _, isHeader = GetQuestLogTitle(i)
    if not isHeader and title then
      present[title] = true
    end
  end

  local now = GetTime and GetTime() or 0
  for title, candidate in pairs(self._turninCandidates) do
    local expired = candidate.closedAt and (now - candidate.closedAt) > Shared.TURNIN_CONFIRM_WINDOW
    if expired then
      self._turninCandidates[title] = nil
      self._seenComplete[title] = nil
      self._pendingTurnin[title] = nil
    elseif candidate.closedAt and not present[title] then
      self:MarkQuestTurnedIn(candidate.id, title)
      self._turninCandidates[title] = nil
      self._seenComplete[title] = nil
      self._pendingTurnin[title] = nil
    end
  end
end
