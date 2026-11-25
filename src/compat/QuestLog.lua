-- quest log access for the 1.12 client
local TG = _G.TurtleGuides

local function extractDbTitle(v)
  if type(v) == "string" and v ~= "" and v ~= "_" then
    return v
  end
  if type(v) == "table" then
    local t = v["T"] or v["t"] or v[1]
    if type(t) == "string" and t ~= "" and t ~= "_" then
      return t
    end
  end
  return nil
end

local function questTitleFromDb(id)
  if not pfDB or type(pfDB["quests"]) ~= "table" then
    return nil
  end
  local qdb = pfDB["quests"]
  local loc = qdb["loc"]
  local title = loc and extractDbTitle(loc[id])
  if title then
    return title
  end
  local locale = (GetLocale and GetLocale()) or "enUS"
  local tries = { locale, locale .. "-turtle", "enUS", "enUS-turtle" }
  for _, key in ipairs(tries) do
    local tbl = qdb[key]
    title = type(tbl) == "table" and extractDbTitle(tbl[id]) or nil
    if title then
      return title
    end
  end
  for key, tbl in pairs(qdb) do
    if type(key) == "string" and type(tbl) == "table" and (string.find(key, "enUS", 1, true) or string.find(key, locale, 1, true)) then
      title = extractDbTitle(tbl[id])
      if title then
        return title
      end
    end
  end
  return nil
end

local function questIdsByTitle(title)
  local ids, seen = {}, {}
  if not title or title == "" or not pfDB or type(pfDB["quests"]) ~= "table" then
    return ids
  end
  local want = string.lower(title)
  for _, tbl in pairs(pfDB["quests"]) do
    if type(tbl) == "table" then
      for id, value in pairs(tbl) do
        local candidateTitle = extractDbTitle(value)
        local candidateId = tonumber(id)
        if candidateId and candidateTitle and string.lower(candidateTitle) == want and not seen[candidateId] then
          seen[candidateId] = true
          table.insert(ids, candidateId)
        end
      end
    end
  end
  table.sort(ids)
  return ids
end

local function parseQuestLinkId(link)
  local id = string.match(tostring(link or ""), "|Hquest:(%d+):")
  return tonumber(id)
end

function TG:IterateQuestLog()
  local i = 0
  local n = GetNumQuestLogEntries()
  return function()
    i = i + 1
    while i <= n do
      local title, level, tag, isHeader, _, isComplete = GetQuestLogTitle(i)
      if not isHeader then
        return i, title, level, tag, isComplete
      end
      i = i + 1
    end
    return nil
  end
end

function TG:GetQuestLogIndexByTitle(name)
  if not name then
    return nil
  end
  local want = self.stripCodes(name)
  local n = GetNumQuestLogEntries()
  for i = 1, n do
    local title, _, _, isHeader = GetQuestLogTitle(i)
    if not isHeader and title == want then
      return i
    end
  end
  local lwant = string.lower(want)
  for i = 1, n do
    local title, _, _, isHeader = GetQuestLogTitle(i)
    if not isHeader and title and string.lower(title) == lwant then
      return i
    end
  end
  return nil
end

function TG:IsQuestInLog(title)
  return self:GetQuestLogIndexByTitle(title) ~= nil
end

function TG:IsQuestComplete(title)
  local idx = self:GetQuestLogIndexByTitle(title)
  if not idx then
    return nil
  end
  local _, _, _, _, _, isComplete = GetQuestLogTitle(idx)
  return isComplete
end

function TG:GetQuestObjectives(title)
  local idx = self:GetQuestLogIndexByTitle(title)
  if not idx then
    return nil
  end
  local objectives = {}
  local num = GetNumQuestLeaderBoards(idx)
  for j = 1, num do
    local text, objType, finished = GetQuestLogLeaderBoard(j, idx)
    objectives[j] = { text = text, type = objType, done = finished and true or false }
  end
  return objectives
end

function TG:GetObjectiveDone(title, objNum)
  local objectives = self:GetQuestObjectives(title)
  if not objectives or not objectives[objNum] then
    return nil
  end
  return objectives[objNum].done
end

function TG:GetQuestIdsForLogIndex(index)
  index = tonumber(index)
  if not index or not GetQuestLogTitle then
    return nil
  end
  local ok, title, _, _, isHeader = pcall(GetQuestLogTitle, index)
  if not ok or not title or isHeader then
    return nil
  end

  local exact, seen = {}, {}
  local function addExact(candidate)
    candidate = tonumber(candidate)
    if candidate and not seen[candidate] then
      seen[candidate] = true
      table.insert(exact, candidate)
    end
  end

  if C_QuestLog and type(C_QuestLog.GetQuestIDForLogIndex) == "function" then
    local okId, id = pcall(C_QuestLog.GetQuestIDForLogIndex, index)
    if okId then
      addExact(id)
    end
  end

  local _, _, _, _, _, _, seventh, eighth = GetQuestLogTitle(index)
  addExact(eighth)
  addExact(seventh)

  local getQuestLink = GetQuestLinkForLogIndex
  if not getQuestLink and GetQuestLink then
    getQuestLink = function(logIndex)
      return GetQuestLink(logIndex)
    end
  end
  if getQuestLink then
    local okLink, link = pcall(getQuestLink, index)
    if okLink then
      local id = parseQuestLinkId(link)
      if id and (not questTitleFromDb(id) or questTitleFromDb(id) == title) then
        addExact(id)
      end
    end
  end
  if table.getn(exact) > 0 then
    table.sort(exact)
    return exact
  end

  if pfDatabase and type(pfDatabase.GetQuestIDs) == "function" then
    local okIds, candidates = pcall(pfDatabase.GetQuestIDs, index)
    if okIds and type(candidates) == "table" then
      local ids = {}
      for _, candidate in pairs(candidates) do
        candidate = tonumber(candidate)
        if candidate and not seen[candidate] then
          seen[candidate] = true
          table.insert(ids, candidate)
        end
      end
      if table.getn(ids) == 1 then
        return ids
      end
    end
  end

  local byTitle = questIdsByTitle(title)
  if table.getn(byTitle) == 1 then
    return byTitle
  end
  return nil
end

function TG:GetQuestIdForLogIndex(index)
  local ids = self:GetQuestIdsForLogIndex(index)
  return ids and ids[1] or nil
end

function TG:GetQuestLogIndexById(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  local n = GetNumQuestLogEntries()
  for i = 1, n do
    local ids = self:GetQuestIdsForLogIndex(i)
    if ids then
      for _, candidate in ipairs(ids) do
        if candidate == id then
          return i
        end
      end
    end
  end
  return nil
end

function TG:GetQuestTitleById(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  local idx = self.GetQuestLogIndexById and self:GetQuestLogIndexById(id)
  if idx then
    local title = GetQuestLogTitle(idx)
    if title and title ~= "" then
      return title
    end
  end
  return questTitleFromDb(id)
end
