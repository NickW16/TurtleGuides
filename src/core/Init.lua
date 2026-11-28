-- startup orchestration
local TG = _G.TurtleGuides

function TG:OnInitialize()
  self:InitDB()
  if self.InitCompat then
    self:InitCompat()
  end
  if self.LoadAllGuides then
    self:LoadAllGuides()
  end
  if self.InitArrow then
    self:InitArrow()
  end
  if self.InitUI then
    self:InitUI()
  end
  if self.InitAutomation then
    self:InitAutomation()
  end
  if self.InitVendor then
    self:InitVendor()
  end
  if self.InitMinimap then
    self:InitMinimap()
  end
  self:Print("loaded. /tg to toggle, /tg guides to pick a guide.")
end

TG:RegisterEvent("PLAYER_LOGIN", function()
  TG:OnInitialize()
end)

TG:RegisterEvent("PLAYER_ENTERING_WORLD", function()
  local key = TG.cdb and TG.cdb.currentGuideKey
  if not key or not TG.guideByKey or not TG.guideByKey[key] then
    return
  end
  TG._pendingGuideLoadAt = (GetTime and GetTime() or 0) + 3
end)

if TG.AddUpdater then
  TG:AddUpdater("delayedGuideLoad", 0.2, function()
    local due = TG._pendingGuideLoadAt
    if not due then
      return
    end
    if GetTime and GetTime() < due then
      return
    end
    TG._pendingGuideLoadAt = nil
    local key = TG.cdb and TG.cdb.currentGuideKey
    if key and TG.guideByKey and TG.guideByKey[key] then
      local step = TG.cdb.stepIndex or 1
      TG:SetGuide(key, step, true, true)
      TG:Print(
        "Restored step " .. tostring(TG.currentStepIndex) .. " of " .. tostring(table.getn(TG.currentGuide.steps or {}))
      )
    end
  end)
end
