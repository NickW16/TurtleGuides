-- automation event registration
local TG = _G.TurtleGuides

function TG:InitAutomation()
  self:RegisterEvent("GOSSIP_SHOW", function()
    TG:OnGossipShow()
  end)
  self:RegisterEvent("QUEST_GREETING", function()
    TG:OnQuestGreeting()
  end)
  self:RegisterEvent("QUEST_DETAIL", function()
    TG:OnQuestDetail()
  end)
  self:RegisterEvent("QUEST_PROGRESS", function()
    TG:OnQuestProgress()
  end)
  self:RegisterEvent("QUEST_COMPLETE", function()
    TG:OnQuestComplete()
  end)
  self:RegisterEvent("TAXIMAP_OPENED", function()
    if TG.db and TG.db.autoTakeFlight then
      TG:AddUpdater("autoFlight", 0.5, function()
        TG:AutoTakeFlight()
        TG:RemoveUpdater("autoFlight")
      end)
    end
  end)
  self:RegisterEvent("MERCHANT_SHOW", function()
    if TG.db and TG.db.autoBuyVendor then
      TG:AddUpdater("autoBuy", 0.5, function()
        TG:AutoBuyVendor()
        TG:RemoveUpdater("autoBuy")
      end)
    end
  end)
  self:RegisterEvent("BAG_UPDATE", function()
    if TG.db and TG.db.autoUseQuestItems then
      TG:AutoUseQuestItems()
    end
  end)
end
