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
  if self.cdb.currentGuideKey and self.guideByKey[self.cdb.currentGuideKey] then
    self:SetGuide(self.cdb.currentGuideKey, self.cdb.stepIndex or 1, true)
  end
  self:Print("loaded. /tg to toggle, /tg guides to pick a guide.")
  if self.CollectGarbage then
    self:CollectGarbage()
  end
end

TG:RegisterEvent("PLAYER_LOGIN", function()
  TG:OnInitialize()
end)
