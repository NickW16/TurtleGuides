-- engine event and updater registration
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared

TG:RegisterEvent("PLAYER_LOGIN", function()
  TG:OnQuestLogUpdate()
end)
TG:RegisterEvent("QUEST_LOG_UPDATE", function()
  TG:OnQuestLogUpdate()
end)
TG:RegisterEvent("QUEST_ACCEPTED", function(index)
  TG:OnQuestAccepted(index)
  if TG.QueueResume then
    TG:QueueResume()
  end
end)
TG:RegisterEvent("QUEST_COMPLETE", function()
  TG:OnQuestTurninDialog()
end)
TG:RegisterEvent("MERCHANT_SHOW", function()
  TG:SignalManualAction("vendor")
  TG:SignalManualAction("repair")
end)
TG:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, id)
  if unit ~= "player" then
    return
  end
  if TG.IsHearthstoneSpell and TG:IsHearthstoneSpell(id) then
    TG:SignalHearthstoneUse()
  end
end)
TG:RegisterEvent("SPELLCAST_STOP", function()
  TG:PollHearthstoneUse()
end)
local function trainerFrameVisible()
  return ClassTrainerFrame and ClassTrainerFrame.IsVisible and ClassTrainerFrame:IsVisible() or false
end

function TG:OnTrainerShown()
  self._trainerOpen = true
end

function TG:OnTrainerClosed(force)
  if not force and not self._trainerOpen then
    return
  end
  self._trainerOpen = nil
  if self.ClearManualCheckHold then
    self:ClearManualCheckHold()
  end
  if self.ClearManualNavHold then
    self:ClearManualNavHold("trainer closed")
  end
  self._autoNavTime = nil
  self:SignalManualAction("trainer")
  self:SignalManualAction("train")
end

TG:RegisterEvent("TRAINER_SHOW", function()
  TG:OnTrainerShown()
end)
TG:RegisterEvent("TRAINER_CLOSED", function()
  TG:OnTrainerClosed(true)
end)

local trainerPollVisible = false
TG:AddUpdater("trainerClose", 0.1, function()
  local visible = trainerFrameVisible()
  if visible then
    trainerPollVisible = true
    TG:OnTrainerShown()
  elseif trainerPollVisible then
    trainerPollVisible = false
    TG:OnTrainerClosed()
  end
end)
TG:RegisterEvent("TAXIMAP_OPENED", function()
  TG:SignalManualAction("fly")
  TG:SignalManualAction("f")
  TG:SignalManualAction("fp")
end)
TG:RegisterEvent("QUEST_FINISHED", function()
  TG:OnQuestFinished()
end)
TG:RegisterEvent("BAG_UPDATE", function()
  if TG.InvalidateStepCompletionCache then
    TG:InvalidateStepCompletionCache()
  end
  TG:CheckAdvance("event")
  if TG.QueueResume then
    TG:QueueResume()
  end
  TG:MarkUIDirty()
end)
TG:RegisterEvent("UNIT_INVENTORY_CHANGED", function(_, unit)
  if unit and unit ~= "player" then
    return
  end
  if TG.InvalidateStepCompletionCache then
    TG:InvalidateStepCompletionCache()
  end
  TG:CheckAdvance("event")
  if TG.QueueResume then
    TG:QueueResume()
  end
  TG:MarkUIDirty()
end)
TG:RegisterEvent("PLAYER_LEVEL_UP", function()
  if TG.InvalidateStepCompletionCache then
    TG:InvalidateStepCompletionCache()
  end
  TG:CheckAdvance("event")
  if TG.QueueResume then
    TG:QueueResume()
  end
  TG:MarkUIDirty()
end)
TG:RegisterEvent("PLAYER_XP_UPDATE", function()
  TG:MarkUIDirty()
end)
TG:RegisterEvent("UI_INFO_MESSAGE", function() end)
TG:AddUpdater("engine", 1.0, function()
  TG:CheckAdvance("tick")
end)
TG:AddUpdater("manualCheck", 0.1, function()
  TG:CheckManualCheckAdvance()
end)
TG:AddUpdater("hearthstoneCast", 0.1, function()
  TG:PollHearthstoneUse()
end)
TG:AddUpdater("stepCache", 0.5, function()
  if not TG.db or not TG.db.autoResume then
    return
  end
  if not TG.currentGuide then
    return
  end
  if TG.RefreshStepCompletionWindow then
    TG:RefreshStepCompletionWindow(TG.currentGuide, TG.currentStepIndex, 8)
  end
end)
TG:AddUpdater("resume", 0.1, function()
  local dirtyAt = TG._resumeDirtyAt
  if not dirtyAt then
    return
  end
  local now = GetTime and GetTime() or 0
  if now - dirtyAt < Shared.RESUME_DELAY then
    return
  end
  TG._resumeDirtyAt = nil
  if TG.MaybeResume then
    TG:MaybeResume()
  end
end)
