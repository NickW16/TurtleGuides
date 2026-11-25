-- vendor event and updater registration
local TG = _G.TurtleGuides
local bagsDirty = false

local function markBagsDirty()
  bagsDirty = true
end
TG.MarkBagsDirty = markBagsDirty

TG:AddUpdater("junkIconsFlush", 0, function()
  if not bagsDirty then
    return
  end
  bagsDirty = false
  TG:RefreshJunkIcons()
end)

function TG:InitVendor()
  self:RegisterEvent("MERCHANT_SHOW", function()
    TG:SellJunk()
  end)
  self:RegisterEvent("MERCHANT_CLOSED", function()
    TG.Vendor.Junk.endVisit()
  end)
  self:HookBagClicks()
  self:RegisterEvent("BAG_UPDATE", function()
    TG:MarkBagsDirty()
  end)
  self:AddUpdater("sellJunk", TG.Vendor.Junk.sellInterval, function()
    TG.Vendor.Junk.tick()
  end)
  self:AddUpdater("junkIcons", 2.0, function()
    local bagFrame = _G["ContainerFrame1"]
    if bagFrame and bagFrame.IsVisible and bagFrame:IsVisible() then
      TG:RefreshJunkIcons()
    end
  end)
end
