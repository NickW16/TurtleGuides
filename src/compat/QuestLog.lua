-- quest log access for the 1.12 client
local TG = _G.TurtleGuides

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

function TG:GetQuestLogIndexById(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  local n = GetNumQuestLogEntries()
  for i = 1, n do
    local _, _, _, _, _, _, seventh, eighth = GetQuestLogTitle(i)
    local questId = tonumber(eighth) or tonumber(seventh)
    if questId == id then
      return i
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
  if not pfDB or not pfDB["quests"] then
    return nil
  end
  local qdb = pfDB["quests"]

  local function extract(v)
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

  if qdb["loc"] then
    local t = extract(qdb["loc"][id])
    if t then
      return t
    end
  end

  local locale = (GetLocale and GetLocale()) or "enUS"
  local tries = { locale, locale .. "-turtle", "enUS", "enUS-turtle" }
  for _, key in ipairs(tries) do
    local loc = qdb[key]
    if type(loc) == "table" then
      local t = extract(loc[id])
      if t then
        return t
      end
    end
  end

  for k, loc in pairs(qdb) do
    if type(loc) == "table" and type(k) == "string" and (string.find(k, "enUS") or string.find(k, locale)) then
      local t = extract(loc[id])
      if t then
        return t
      end
    end
  end

  return nil
end
