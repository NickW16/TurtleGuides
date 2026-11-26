-- live objective detection and step completion
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local Quests = TG.Engine.Quests
local strtrim = TG.Util.strtrim
local Completion = {}
TG.Engine.Completion = Completion

local function characterQuestTurnedIn(self, id, title)
  if id and self.cdb and self.cdb.turnedIn and self.cdb.turnedIn[id] then
    return true
  end
  if title and self._turnedInTitles and self._turnedInTitles[title] then
    return true
  end
  return false
end

local function itemObjectiveSatisfied(self, el)
  local getter = self.GetObjectiveItemProgress
  if not getter then
    return false
  end
  local have, need = getter(self, el)
  return have ~= nil and need ~= nil and have >= need
end

local function questObjectivesForElement(self, title, id)
  local objectives
  if title and self.GetQuestObjectives then
    objectives = self:GetQuestObjectives(title)
  end
  if (not objectives or table.getn(objectives) == 0) and id and self.GetQuestObjectivesById then
    objectives = self:GetQuestObjectivesById(id)
  end
  return objectives
end

function TG:DetectElementDone(el)
  if not el or el.t ~= "cmd" then
    return nil
  end
  local tag = el.tag
  if tag == "accept" then
    local title, id = self:ResolveQuestTitle(el)
    local evidence = self:GetQuestEvidence(id, title)
    if evidence and (evidence.inLog or evidence.turnedIn) then
      return true
    end
    if id and Quests.recentlyAccepted(id) then
      return true
    end
    return false
  elseif tag == "turnin" then
    local title, id = self:ResolveQuestTitle(el)
    local evidence = self:GetQuestEvidence(id, title)
    if evidence and evidence.turnedIn then
      return true
    end
    if el.skipIfMissing and (not evidence or not evidence.inLog) then
      return true
    end
    return false
  elseif tag == "complete" then
    local title, id = self:ResolveQuestTitle(el)
    local objNum = el.args and tonumber(el.args[2])
    local objectives = questObjectivesForElement(self, title, id)
    if objNum and objectives and self.FindQuestObjective then
      local matchedIndex, matchedObjective = self:FindQuestObjective(el, objectives, objNum)
      if matchedIndex and matchedObjective and matchedIndex ~= objNum then
        el.args[2] = tostring(matchedIndex)
        objNum = matchedIndex
      end
    end
    local evidence = self:GetQuestEvidence(id, title)
    local characterDone = characterQuestTurnedIn(self, id, title)
    if el.skipIfMissing and (not evidence or (not evidence.inLog and not characterDone)) then
      return true
    end
    if characterDone then
      return true
    end
    if itemObjectiveSatisfied(self, el) then
      return true
    end
    local logIdx = evidence and evidence.logIndex or nil
    if not logIdx and title and self.GetQuestLogIndexByTitle then
      logIdx = self:GetQuestLogIndexByTitle(title)
    end
    if not logIdx and id and self.GetQuestLogIndexById then
      logIdx = self:GetQuestLogIndexById(id)
    end
    if logIdx then
      if objNum then
        local objective = objectives and objectives[objNum]
        local done = objective and objective.done
        if done == nil and title and self.GetObjectiveDone then
          done = self:GetObjectiveDone(title, objNum)
        end
        if done ~= nil then
          return done
        end
        if GetQuestLogLeaderBoard then
          local _, _, finished = GetQuestLogLeaderBoard(objNum, logIdx)
          if finished ~= nil then
            return finished and true or false
          end
        end
        return nil
      end
      local _, _, _, _, _, isComplete = GetQuestLogTitle(logIdx)
      if isComplete == 1 then
        return true
      end
      if title then
        local complete = self:IsQuestComplete(title)
        if complete == 1 then
          return true
        end
      end
      return false
    end
    if title and not self:IsQuestInLog(title) then
      return false
    end
    return false
  elseif tag == "collect" then
    local itemId = tonumber(el.args and el.args[1])
    local count = tonumber(el.args and el.args[2]) or 1
    local questId = tonumber(el.args and el.args[3])
    if questId then
      if characterQuestTurnedIn(self, questId) then
        return true
      end
      if self.GetQuestLogIndexById then
        local idx = self:GetQuestLogIndexById(questId)
        if idx then
          local _, _, _, _, _, isComplete = GetQuestLogTitle(idx)
          if isComplete == 1 then
            return true
          end
        end
      end
    end
    if itemId then
      return self:GetItemCount(itemId) >= count
    end
    return nil
  elseif tag == "itemcount" then
    return self:IsItemCountConditionMet(el)
  elseif tag == "xp" then
    local op, level, xp = self:ParseXpArg(el.args and el.args[1])
    if not level then
      return nil
    end
    if not UnitLevel or not UnitXP or not UnitXPMax then
      return nil
    end
    local curLevel = UnitLevel("player")
    local curXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    if not curLevel or not curXP or not maxXP or maxXP < 1 then
      return nil
    end
    xp = xp or 0
    if op == "<" then
      return curLevel < level
    end
    if op == ">" then
      return curLevel >= level
    end
    if xp < 0 then
      return curLevel >= level or (curLevel == level - 1 and curXP >= maxXP + xp)
    end
    if xp > 0 and xp < 1 then
      return curLevel > level or (curLevel == level and curXP >= maxXP * xp)
    end
    if xp > 0 then
      return curLevel > level or (curLevel == level and curXP >= xp)
    end
    return curLevel >= level
  end
  return nil
end

function TG:IsElementDone(el)
  self._tgDoneSource = nil
  if el and el._tgManualDone then
    self._tgDoneSource = "manual checkbox"
    return true
  end
  local done = self:DetectElementDone(el)
  if done == true then
    self._tgDoneSource = tostring(el and el.tag or "objective") .. " detected"
  end
  return done
end

function TG:IsStepComplete(step)
  if not step then
    return false
  end
  local hasManual = self:StepHasManualAction(step)
  if hasManual and not self:StepManualActionsSatisfied(step) then
    return false
  end
  local hasReq, allDone = false, true
  for _, el in ipairs(step.elements or {}) do
    if Shared.isObjectiveElement(el) then
      hasReq = true
      if self:IsElementDone(el) ~= true then
        allDone = false
      end
    end
  end
  if not hasReq then
    return hasManual
  end
  return allDone
end

Completion.strtrim = strtrim
