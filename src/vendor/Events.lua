-- vendor event and updater registration
local TG = _G.TurtleGuides

function TG:InitVendor()
  self:RegisterEvent("MERCHANT_SHOW", function()
    TG:SellJunk()
  end)
  self:RegisterEvent("MERCHANT_CLOSED", function()
    TG.Vendor.Junk.endVisit()
  end)
  self:HookBagClicks()
  self:RegisterEvent("BAG_UPDATE", function()
    TG:RefreshJunkIcons()
  end)
  self:AddUpdater("sellJunk", TG.Vendor.Junk.sellInterval, function()
    TG.Vendor.Junk.tick()
  end)
  self:AddUpdater("junkIcons", 2.0, function()
    TG:RefreshJunkIcons()
  end)
  self:AddUpdater("junkIconsInit", 0.5, function()
    TG:RefreshJunkIcons()
  end)
end
