-- auto-advance orchestration and quest log updates
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared

function TG:CheckAdvance()
  if not self.currentGuide then
    return
  end
  if not self._questLogSeeded then
    return
  end
  if self._manualCheckTime then
    local checkNow = GetTime and GetTime() or 0
    local checkStep = self._manualCheckStep
    if checkStep and self.currentStepIndex ~= checkStep then
      self:ClearManualCheckHold()
    elseif checkNow - self._manualCheckTime < Shared.MANUAL_CHECK_VISIBLE_DELAY then
      return
    else
      self:ClearManualCheckHold()
    end
  end
  if self.PollBindLocation then
    self:PollBindLocation()
  end
  if self:IsManualNavHeld() then
    local heldStep = self:CurrentStep()
    local sig = heldStep and self:StepStateSignature(heldStep) or ""
    local moved = self:PlayerMovedSinceManualNav()
    local complete = heldStep and self:IsStepComplete(heldStep) or false
    local reason = self._manualNavReason
    if complete and (not reason or reason == "" or reason == "guide load") then
      self:ClearManualNavHold("step already complete")
    elseif sig ~= self._manualNavSignature or moved then
      self:ClearManualNavHold(moved and "player moved" or "completion state changed")
    else
      return
    end
  end
  local now = GetTime and GetTime() or 0
  if self._autoNavTime and (now - self._autoNavTime) < 0.25 then
    return
  end
  local step = self:CurrentStep()
  if not step then
    return
  end

  local idxBefore = self.currentStepIndex
  if self.CheckGotoAdvance then
    self:CheckGotoAdvance()
  end
  if self.currentStepIndex ~= idxBefore then
    self._wasStepComplete = nil
    return
  end
  step = self:CurrentStep()
  if not step then
    return
  end

  local shouldSkip = self.ShouldAutoSkipStep and self:ShouldAutoSkipStep(step) or false
  if shouldSkip == true then
    self:NextStep(false, true)
    self._wasStepComplete = nil
    return
  end
  local isComplete = self:IsStepComplete(step)
  if isComplete and not self._wasStepComplete then
    self:NextStep(false)
    self._wasStepComplete = nil
  else
    self._wasStepComplete = isComplete
  end
end

function TG:OnQuestLogUpdate()
  if self.SeedQuestLog then
    self:SeedQuestLog()
  else
    self._questLogSeeded = true
    if self.InvalidateQuestLedger then
      self:InvalidateQuestLedger()
    end
  end
  self:ScanQuestTurnins()
  self:CheckAdvance("event")
  self:MarkUIDirty()
end
