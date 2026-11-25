-- engine event and updater registration
local TG = _G.TurtleGuides

TG:RegisterEvent("PLAYER_LOGIN", function()
  TG:OnQuestLogUpdate()
end)
TG:RegisterEvent("QUEST_LOG_UPDATE", function()
  TG:OnQuestLogUpdate()
end)
TG:RegisterEvent("QUEST_ACCEPTED", function(index)
  TG:OnQuestAccepted(index)
end)
TG:RegisterEvent("QUEST_COMPLETE", function()
  TG:OnQuestTurninDialog()
end)
TG:RegisterEvent("MERCHANT_SHOW", function()
  TG:SignalManualAction("vendor")
  TG:SignalManualAction("repair")
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
  TG:CheckAdvance("event")
  if TG.UpdateUI then
    TG:UpdateUI()
  end
end)
TG:RegisterEvent("PLAYER_LEVEL_UP", function()
  TG:CheckAdvance("event")
  if TG.UpdateUI then
    TG:UpdateUI()
  end
end)
TG:RegisterEvent("PLAYER_XP_UPDATE", function()
  if TG.UpdateUI then
    TG:UpdateUI()
  end
end)
TG:RegisterEvent("UI_INFO_MESSAGE", function() end)
TG:AddUpdater("engine", 1.0, function()
  TG:CheckAdvance("tick")
end)
TG:AddUpdater("manualCheck", 0.1, function()
  TG:CheckManualCheckAdvance()
end)
