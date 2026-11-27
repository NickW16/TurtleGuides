-- step resume decision and expected quest log
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local Resume = {}
TG.Engine.Resume = Resume

local CONFIDENCE_RANK = { weak = 1, confirmed = 2 }

local function atLeastAsStrong(a, b)
  return (CONFIDENCE_RANK[a] or 0) >= (CONFIDENCE_RANK[b] or 0)
end

function Resume.findQuestEvidence(self, el)
  if not el or el.t ~= "cmd" then
    return nil
  end
  if el.tag ~= "accept" and el.tag ~= "turnin" and el.tag ~= "complete" then
    return nil
  end
  local title, id = self:ResolveQuestTitle(el)
  if not id and not title then
    return nil
  end

  local evidence = self.GetQuestEvidence and self:GetQuestEvidence(id, title) or nil
  local confidence = self.QuestEvidenceConfidence and self:QuestEvidenceConfidence(id, title) or nil
  if not evidence then
    local inLog = false
    if id and TG.GetQuestLogIndexById and TG:GetQuestLogIndexById(id) then
      inLog = true
    end
    if not inLog and title and TG.IsQuestInLog and TG:IsQuestInLog(title) then
      inLog = true
    end
    local turnedIn = false
    if id and TG.IsQuestTurnedIn and TG:IsQuestTurnedIn(id) then
      turnedIn = true
    end
    if not turnedIn and title and TG._turnedInTitles and TG._turnedInTitles[title] then
      turnedIn = true
    end
    if not inLog and not turnedIn then
      return nil
    end
    local complete = false
    if inLog then
      local done
      if id and TG.GetQuestLogIndexById then
        local idx = TG:GetQuestLogIndexById(id)
        if idx and GetQuestLogTitle then
          local _, _, _, _, _, d = GetQuestLogTitle(idx)
          done = d
        end
      elseif title and TG.IsQuestComplete then
        done = TG:IsQuestComplete(title)
      end
      complete = (done == 1 or done == -1)
    end
    evidence = { id = id, title = title, inLog = inLog, complete = complete, turnedIn = turnedIn }
    confidence = inLog and "confirmed" or "weak"
  end
  evidence.confidence = confidence or "weak"
  return evidence
end

function Resume.findIndex(context)
  local steps = context.steps or {}
  local n = context.n or table.getn(steps)
  if n < 1 then
    return nil
  end
  local currentIndex = context.currentIndex or 1

  local last, cap, evidence = 1, nil, nil
  local lastConfidence, capConfidence
  for i = 1, n do
    local step = steps[i]
    for _, el in ipairs(step.elements or {}) do
      local ev = context.evidence and context.evidence(el)
      if ev then
        if el.tag == "accept" then
          if ev.inLog or ev.turnedIn then
            last, evidence, lastConfidence = i, ev, ev.confidence
          end
        elseif el.tag == "turnin" or el.tag == "complete" then
          if ev.turnedIn then
            last, evidence, lastConfidence = i, ev, ev.confidence
          end
          if not cap and ev.inLog and not ev.complete and not ev.turnedIn then
            cap, capConfidence = i, ev.confidence
          end
        end
      end
    end
  end

  local start = last
  if cap and cap < start and atLeastAsStrong(capConfidence, lastConfidence) then
    start = cap
  end
  if start < 1 then
    start = 1
  end
  if start > n then
    start = n
  end

  local pos = start
  for _ = 1, n + 1 do
    if pos > n then
      break
    end
    local step = steps[pos]
    local skipState = context.skipState and context.skipState(step) or false
    local done = context.completed and context.completed[pos] == true
    if not done and context.complete then
      done = context.complete(step) == true
    end
    local hasWork = false
    for _, el in ipairs(step.elements or {}) do
      if Shared.isObjectiveElement(el) then
        hasWork = true
        break
      end
    end
    if skipState == true or done or (not hasWork and not (context.hasManual and context.hasManual(step))) then
      pos = pos + 1
    else
      break
    end
  end
  if pos > n then
    pos = n
  end
  if pos < currentIndex and lastConfidence ~= "confirmed" then
    pos = currentIndex
  end

  local reason = "start of guide"
  if evidence and evidence.title and evidence.title ~= "" then
    reason = (evidence.inLog and "quest in log: " or "handed in: ") .. evidence.title
  elseif evidence and evidence.id then
    reason = "quest evidence #" .. evidence.id
  end
  if cap and cap <= pos then
    reason = reason .. "; held before unfinished quest work"
  end

  return { index = pos, reason = reason, confidence = lastConfidence, cap = cap, evidence = evidence }
end

function TG:FindResumeIndex(guide, context)
  guide = guide or self.currentGuide
  if not guide then
    return nil
  end
  local steps = guide.steps or {}
  context = context or {}
  local merged = {
    steps = steps,
    n = table.getn(steps),
    currentIndex = context.currentIndex or self.currentStepIndex,
    evidence = context.evidence or function(el)
      return Resume.findQuestEvidence(self, el)
    end,
    skipState = context.skipState or function(step)
      return self.StepSkipState and self:StepSkipState(step) or false
    end,
    complete = context.complete or function(step)
      if self.CachedStepComplete then
        return self:CachedStepComplete(step)
      end
      return self:IsStepComplete(step)
    end,
    hasManual = context.hasManual or function(step)
      return self:StepHasManualAction(step)
    end,
    completed = context.completed
      or (self.cdb and self.cdb.completedByGuide and self.cdb.completedByGuide[guide.key])
      or nil,
  }
  return Resume.findIndex(merged)
end

function TG:QueueResume()
  self._resumeDirtyAt = GetTime and GetTime() or 0
end

function TG:ClearResumeQueue()
  self._resumeDirtyAt = nil
end

function TG:MaybeResume()
  if not self.db or not self.db.autoResume then
    return false
  end
  if not self.currentGuide or not self._questLogSeeded then
    return false
  end
  if self.IsManualNavHeld and self:IsManualNavHeld() then
    local reason = self._manualNavReason
    if reason ~= "guide load" and reason ~= "Find my place" then
      return false
    end
  end
  if self._manualCheckTime then
    return false
  end
  local step = self:CurrentStep()
  if not step then
    return false
  end
  local skip = self.ShouldAutoSkipStep and self:ShouldAutoSkipStep(step) or false
  local complete = self:IsStepComplete(step)
  local hasWork = Shared.stepHasObjective(step)
    or Shared.stepHasItemCountCondition(step)
    or self:StepHasManualAction(step)
  if not (skip == true or complete == true or not hasWork) then
    return false
  end
  local result = self:FindResumeIndex(self.currentGuide)
  if not result or not result.index or result.index <= self.currentStepIndex then
    return false
  end
  if self.GoToStep and self:GoToStep(result.index) then
    self:Print("Skipped to step " .. result.index .. ": " .. result.reason)
    return true
  end
  return false
end

function Resume.expected(steps, upTo, evidence)
  local expected, turnedIn, futureTurnIns = {}, {}, {}
  local n = table.getn(steps or {})
  local limit = math.min(upTo or n, n)
  for i = 1, limit do
    for _, el in ipairs(steps[i].elements or {}) do
      if el.t == "cmd" then
        local ids = TG.GetElementQuestIds and TG:GetElementQuestIds(el) or {}
        if el.tag == "accept" then
          for _, id in ipairs(ids) do
            expected[id] = true
            turnedIn[id] = nil
          end
        elseif el.tag == "turnin" or el.tag == "complete" then
          for _, id in ipairs(ids) do
            expected[id] = nil
            turnedIn[id] = true
          end
        end
      end
    end
  end
  for i = limit + 1, n do
    for _, el in ipairs(steps[i].elements or {}) do
      if el.t == "cmd" and (el.tag == "turnin" or el.tag == "complete") then
        local ev = evidence and evidence(el)
        if ev and ev.inLog then
          for _, id in ipairs(TG.GetElementQuestIds and TG:GetElementQuestIds(el) or {}) do
            futureTurnIns[id] = i
          end
        end
      end
    end
  end
  return expected, turnedIn, futureTurnIns
end

local function previousGuideFor(self, guide)
  for _, candidate in pairs(self.guideByKey or {}) do
    if candidate ~= guide and candidate.next == guide.key then
      return candidate
    end
  end
  return nil
end

function TG:GetExpectedQuestLog()
  local guide = self.currentGuide
  if not guide then
    return {}, {}, {}
  end
  local chain = {}
  local cursor = guide
  local depth = 0
  while cursor and depth < 32 do
    local upTo = cursor == guide and (self.currentStepIndex or 1) or table.getn(cursor.steps or {})
    table.insert(chain, 1, { steps = cursor.steps or {}, upTo = upTo })
    cursor = previousGuideFor(self, cursor)
    depth = depth + 1
  end

  local expected, turnedIn, futureTurnIns = {}, {}, {}
  for _, entry in ipairs(chain) do
    local e, t, f = Resume.expected(entry.steps, entry.upTo, function(el)
      return Resume.findQuestEvidence(self, el)
    end)
    for id in pairs(e) do
      expected[id] = true
      turnedIn[id] = nil
    end
    for id in pairs(t) do
      expected[id] = nil
      turnedIn[id] = true
    end
    for id, index in pairs(f) do
      futureTurnIns[id] = index
    end
  end
  return expected, turnedIn, futureTurnIns
end

Resume.atLeastAsStrong = atLeastAsStrong
