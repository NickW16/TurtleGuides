-- guide selection and step navigation
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local strtrim = TG.Util.strtrim
local Navigation = {}
TG.Engine.Navigation = Navigation

function TG:CurrentStep()
  local guide = self.currentGuide
  if not guide then
    return nil
  end
  return guide.steps[self.currentStepIndex]
end

function TG:SetGuide(key, stepIndex, silent, noAutoDetect)
  if not key then
    return false
  end
  local guide = self.guideByKey and self.guideByKey[key]
  if not guide then
    return false
  end
  if self.ClearManualCheckHold then
    self:ClearManualCheckHold()
  end
  if self.currentGuide and self.ClearManualElementStates then
    for _, step in ipairs(self.currentGuide.steps or {}) do
      self:ClearManualElementStates(step)
    end
  end
  self.currentGuide = guide
  local n = table.getn(guide.steps or {})
  if n < 1 then
    n = 1
  end
  local idx = tonumber(stepIndex) or 1

  if self.cdb then
    if not self.cdb.completedByGuide then
      self.cdb.completedByGuide = {}
      if self.cdb.completedSteps and self.cdb.currentGuideKey then
        self.cdb.completedByGuide[self.cdb.currentGuideKey] = self.cdb.completedSteps
      end
    end
    if not self.cdb.completedByGuide[key] then
      self.cdb.completedByGuide[key] = {}
    end
  end

  if (not stepIndex or stepIndex == 1) and self.cdb and not noAutoDetect then
    local completed = self.cdb.completedByGuide[key] or {}
    local hasCompleted = next(completed) ~= nil
    if hasCompleted then
      for i = 1, n do
        local step = guide.steps[i]
        if step and not completed[i] then
          local hasCompletion, allCompletionDone, hasAnyFalse = false, true, false
          for _, el in ipairs(step.elements or {}) do
            if Shared.OBJECTIVE_TAGS[el.tag] then
              hasCompletion = true
              local done = self:IsElementDone(el)
              if done == false then
                allCompletionDone = false
                hasAnyFalse = true
              elseif done == nil then
                allCompletionDone = false
              end
            end
          end
          if hasCompletion and allCompletionDone and not hasAnyFalse then
            idx = i
            break
          end
        end
      end
    end
  end

  if idx < 1 then
    idx = 1
  end
  if idx > n then
    idx = n
  end
  if TG.db and TG.db.hardcoreMode then
    local skipDeathskip = not self.AutoSkipEnabled or self:AutoSkipEnabled()
    while idx <= n do
      local step = guide.steps[idx]
      local skip = self.ShouldSkipStepForHardcoreMode and self:ShouldSkipStepForHardcoreMode(step)
      if skipDeathskip and step and step._deathskip then
        skip = true
      end
      if skip then
        idx = idx + 1
      else
        break
      end
    end
    if idx > n then
      idx = n
    end
  end
  self.currentStepIndex = idx
  if self.cdb then
    self.cdb.currentGuideKey = key
    self.cdb.stepIndex = self.currentStepIndex
  end
  if self.ResetManualSignals then
    self:ResetManualSignals()
  end
  self.activeAuxSteps = {}
  if self.CaptureManualNavState then
    self:CaptureManualNavState("guide load")
  end
  if self.UpdateUI then
    self:UpdateUI()
  end
  if self.UpdateStepWaypoint then
    self:UpdateStepWaypoint()
  end
  if not silent then
    self:Print("Guide: " .. (guide.name or key))
  end
  return true
end

function TG:GetActiveAuxSteps()
  local result = {}
  local guide = self.currentGuide
  if not guide then
    return result
  end
  local idx = self.currentStepIndex or 1
  for i, step in ipairs(guide.steps) do
    if i < idx and (step.sticky or step.completewith) then
      local targetIdx
      if step.completewith then
        if step.completewith == "next" then
          targetIdx = i + 1
        else
          for j, other in ipairs(guide.steps) do
            if other.label == step.completewith then
              targetIdx = j
              break
            end
          end
        end
      end
      local hidden = false
      if not self:StepConditionsMet(step) then
        hidden = true
      elseif self.ShouldSkipStepForHardcoreMode and self:ShouldSkipStepForHardcoreMode(step) then
        hidden = true
      elseif self.ShouldSkipStepByZone and self:ShouldSkipStepByZone(step) then
        hidden = true
      elseif targetIdx and idx > targetIdx then
        hidden = true
      elseif self:IsStepComplete(step) then
        hidden = true
      elseif not Shared.stepHasObjective(step) and not Shared.stepHasItemCountCondition(step) then
        hidden = true
      end
      if not hidden then
        table.insert(result, step)
      end
    end
  end
  return result
end

function TG:NextStep(manual, isSkip)
  if not self.currentGuide then
    return
  end
  if manual == nil then
    manual = true
  end
  local curStep = self.currentGuide.steps[self.currentStepIndex]
  if curStep and self.ClearManualElementStates then
    self:ClearManualElementStates(curStep)
  end
  if self.ClearManualCheckHold then
    self:ClearManualCheckHold()
  end
  if self.cdb and curStep and not isSkip and not curStep.completewith and not curStep.sticky then
    if not self.cdb.completedByGuide then
      self.cdb.completedByGuide = {}
    end
    local key = self.currentGuide.key
    if not self.cdb.completedByGuide[key] then
      self.cdb.completedByGuide[key] = {}
    end
    self.cdb.completedByGuide[key][self.currentStepIndex] = true
  end
  if self.currentStepIndex < table.getn(self.currentGuide.steps) then
    self.currentStepIndex = self.currentStepIndex + 1
    if TG.db and TG.db.hardcoreMode then
      local skipDeathskip = not self.AutoSkipEnabled or self:AutoSkipEnabled()
      while self.currentStepIndex <= table.getn(self.currentGuide.steps) do
        local step = self.currentGuide.steps[self.currentStepIndex]
        local skip = self.ShouldSkipStepForHardcoreMode and self:ShouldSkipStepForHardcoreMode(step)
        if skipDeathskip and step and step._deathskip then
          skip = true
        end
        if skip then
          self.currentStepIndex = self.currentStepIndex + 1
        else
          break
        end
      end
    end
    if self.currentStepIndex > table.getn(self.currentGuide.steps) then
      self:Print("Guide complete.")
      return
    end
    self.cdb.stepIndex = self.currentStepIndex
    self._gotoIndex = {}
    if self.ResetManualSignals then
      self:ResetManualSignals()
    end
    local now = GetTime and GetTime() or 0
    if manual then
      if self.CaptureManualNavState then
        self:CaptureManualNavState("Next")
      end
    else
      self._autoNavTime = now
    end
    self._wasStepComplete = nil
    if self.UpdateUI then
      self:UpdateUI()
    end
    if self.UpdateStepWaypoint then
      self:UpdateStepWaypoint()
    end
  else
    local guide = self.currentGuide
    if guide and guide.next then
      local nextKey = guide.next
      if self.guideByKey and self.guideByKey[nextKey] then
        self:Print("Loading next guide: " .. nextKey)
        self:SetGuide(nextKey, 1, false, true)
        return
      end
      for key, value in pairs(self.guideByKey or {}) do
        if string.find(key, nextKey, 1, true) or string.find(value.name or "", nextKey, 1, true) then
          self:Print("Loading next guide: " .. (value.name or key))
          self:SetGuide(key, 1, false, true)
          return
        end
      end
      self:Print("Guide complete. Next guide not found: " .. tostring(nextKey))
    else
      self:Print("Guide complete.")
    end
  end
end

function TG:GoToStep(index)
  if not self.currentGuide then
    return false
  end
  local total = table.getn(self.currentGuide.steps or {})
  if total == 0 then
    return false
  end
  index = tonumber(index) or 1
  if index < 1 then
    index = 1
  end
  if index > total then
    index = total
  end
  if self.currentStepIndex == index then
    return true
  end
  return self:SetGuide(self.currentGuide.key, index, true, true)
end

function TG:PrevStep()
  if not self.currentGuide then
    return
  end
  if self.ClearManualCheckHold then
    self:ClearManualCheckHold()
  end
  if self.currentStepIndex > 1 then
    local leaving = self.currentGuide.steps[self.currentStepIndex]
    if leaving and self.ClearManualElementStates then
      self:ClearManualElementStates(leaving)
    end
    self.currentStepIndex = self.currentStepIndex - 1
    if TG.db and TG.db.hardcoreMode then
      while self.currentStepIndex >= 1 do
        local step = self.currentGuide.steps[self.currentStepIndex]
        local skip = self.ShouldSkipStepForHardcoreMode and self:ShouldSkipStepForHardcoreMode(step)
        if step and step._deathskip then
          skip = true
        end
        if skip then
          self.currentStepIndex = self.currentStepIndex - 1
        else
          break
        end
      end
    end
    if self.currentStepIndex < 1 then
      self.currentStepIndex = 1
    end
    local arriving = self.currentGuide.steps[self.currentStepIndex]
    if arriving and self.ClearManualElementStates then
      self:ClearManualElementStates(arriving)
    end
    self.cdb.stepIndex = self.currentStepIndex
    self._gotoIndex = {}
    if self.ResetManualSignals then
      self:ResetManualSignals()
    end
    if self.CaptureManualNavState then
      self:CaptureManualNavState("Prev")
    end
    self._wasStepComplete = nil
    if self.UpdateUI then
      self:UpdateUI()
    end
    if self.UpdateStepWaypoint then
      self:UpdateStepWaypoint()
    end
  end
end

local function findQuestEvidence(el)
  if not el or el.t ~= "cmd" then
    return nil
  end
  if el.tag ~= "accept" and el.tag ~= "turnin" and el.tag ~= "complete" then
    return nil
  end
  local id = tonumber(el.args and el.args[1])
  local title = el.text
  if title and title ~= "" then
    title = string.gsub(title, "^Accept%s+", "")
    title = string.gsub(title, "^Turn in%s+", "")
    title = string.gsub(title, "^Turn In%s+", "")
    title = strtrim(title)
    if title == "" then
      title = nil
    end
  end
  if not title and id and TG.GetQuestTitleById then
    title = TG:GetQuestTitleById(id)
  end
  if not id and not title then
    return nil
  end

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
  return { id = id, title = title, inLog = inLog, complete = complete, turnedIn = turnedIn }
end

function TG:FindMyPlace(quiet)
  local guide = self.currentGuide
  if not guide then
    if not quiet then
      self:Print("Find my place: no guide is running. Pick a guide first.")
    end
    return nil
  end
  if not self._questLogSeeded then
    if not quiet then
      self:Print("Find my place: the quest log has not been read yet. Try again in a moment.")
    end
    return nil
  end
  local steps = guide.steps or {}
  local n = table.getn(steps)
  if n == 0 then
    if not quiet then
      self:Print("Find my place: this guide has no steps.")
    end
    return nil
  end

  local last, cap, evidence = 1, nil, nil
  for i, step in ipairs(steps) do
    for _, el in ipairs(step.elements or {}) do
      local ev = findQuestEvidence(el)
      if ev then
        if el.tag == "accept" then
          if ev.inLog or ev.turnedIn then
            last, evidence = i, ev
          end
        elseif el.tag == "turnin" or el.tag == "complete" then
          if ev.turnedIn then
            last, evidence = i, ev
          end
          if not cap and ev.inLog and not ev.complete and not ev.turnedIn then
            cap = i
          end
        end
      end
    end
  end
  local start = last
  if cap and cap < start then
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
    local skipState = self.StepSkipState and self:StepSkipState(step) or false
    local done = self:IsStepComplete(step) == true
    local hasWork = false
    for _, el in ipairs(step.elements or {}) do
      if Shared.isObjectiveElement(el) then
        hasWork = true
        break
      end
    end
    if skipState == true or done or (not hasWork and not self:StepHasManualAction(step)) then
      pos = pos + 1
    else
      break
    end
  end
  if pos > n then
    pos = n
  end

  self.currentStepIndex = pos
  if self.cdb then
    self.cdb.stepIndex = pos
  end
  self._gotoIndex = {}
  self._wasStepComplete = nil
  self._autoNavTime = nil
  if self.ResetManualSignals then
    self:ResetManualSignals()
  end
  if self.CaptureManualNavState then
    self:CaptureManualNavState("Find my place")
  end
  if self.UpdateUI then
    self:UpdateUI()
  end
  if self.UpdateStepWaypoint then
    self:UpdateStepWaypoint()
  end

  if not quiet then
    local why = "start of guide"
    if evidence and evidence.title and evidence.title ~= "" then
      why = (evidence.inLog and "quest in log: " or "handed in: ") .. evidence.title
    elseif evidence and evidence.id then
      why = "quest evidence #" .. evidence.id
    end
    if cap and cap <= pos then
      why = why .. "; held before unfinished quest work"
    end
    self:Print("Find my place: step " .. pos .. " of " .. n .. " (" .. why .. ").")
  end
  return pos
end

Navigation.findQuestEvidence = findQuestEvidence
