-- junk classification and paced selling
local TG = _G.TurtleGuides
local Junk = {}
TG.Vendor = TG.Vendor or {}
TG.Vendor.Junk = Junk

local SELL_EVERY = 0.2
local sale = nil

local function isGrey(link)
  if not link then
    return false
  end
  local _, _, q = string.find(link, "|c(%x%x%x%x%x%x%x%x)")
  return q == "ff9d9d9d"
end

local function endSale()
  if not sale then
    return
  end
  local sold = 0
  for _, spot in ipairs(sale.sent) do
    local now = GetContainerItemLink(spot[1], spot[2])
    if now ~= spot.link then
      sold = sold + 1
    end
  end
  if sold > 0 then
    TG:Print("Sold " .. sold .. " junk item(s).")
  end
  sale = nil
end

local function nextJunkSlot()
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = slots, 1, -1 do
      local key = bag .. "x" .. slot
      if not sale.done[key] and TG:IsItemJunk(bag, slot) then
        local _, _, locked = GetContainerItemInfo(bag, slot)
        if not locked then
          return bag, slot
        end
      end
    end
  end
  return nil
end

local function canSellNow()
  if not MerchantFrame or not MerchantFrame:IsVisible() then
    return false
  end
  if MerchantFrame.selectedTab and MerchantFrame.selectedTab ~= 1 then
    return false
  end
  return true
end

local function sellJunkTick()
  if not sale then
    return
  end
  if not canSellNow() then
    return
  end
  if GetCursorInfo and GetCursorInfo() then
    if ClearCursor then
      ClearCursor()
    end
    return
  end
  local bag, slot = nextJunkSlot()
  if not bag then
    endSale()
    return
  end
  sale.done[bag .. "x" .. slot] = true
  table.insert(sale.sent, { bag, slot, GetContainerItemLink(bag, slot) })
  if ClearCursor then
    ClearCursor()
  end
  UseContainerItem(bag, slot)
end

function TG:IsItemJunk(bag, slot)
  local link = GetContainerItemLink(bag, slot)
  if not link then
    return false
  end
  local id = TG:GetItemIdFromLink(link)
  local marked = id and self.cdb and self.cdb.junk and self.cdb.junk[id]
  if marked == false then
    return false
  end
  if marked == true then
    return true
  end
  return isGrey(link)
end

function TG:ToggleJunkItem(bag, slot)
  bag = tonumber(bag)
  slot = tonumber(slot)
  if not bag or not slot then
    return
  end
  local link = GetContainerItemLink(bag, slot)
  if not link then
    return
  end
  local id = self:GetItemIdFromLink(link)
  if not id then
    return
  end
  self.cdb.junk = self.cdb.junk or {}
  local cur = self.cdb.junk[id]
  if cur == true then
    self.cdb.junk[id] = nil
    self:Print("Unmarked as junk: " .. link)
  elseif cur == false then
    self.cdb.junk[id] = nil
    self:Print("Unprotected: " .. link)
  elseif isGrey(link) then
    self.cdb.junk[id] = false
    self:Print("Protected from auto-sell: " .. link)
  else
    self.cdb.junk[id] = true
    self:Print("Marked as junk: " .. link)
  end
  if self.RefreshJunkIcons then
    self:RefreshJunkIcons()
  end
end

function TG:SellJunk()
  if not (self.db and self.db.autoSellJunk) then
    return
  end
  if not MerchantFrame or not MerchantFrame:IsVisible() then
    return
  end
  endSale()
  sale = { done = {}, sent = {} }
end

function TG:GetJunkCount()
  local count = 0
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      if self:IsItemJunk(bag, slot) then
        count = count + 1
      end
    end
  end
  return count
end

function TG:MarkJunkUnderCursor()
  local bag, slot
  for b = 0, 4 do
    local slots = GetContainerNumSlots(b) or 0
    for sl = 1, slots do
      local frame = _G["ContainerFrame" .. (b + 1) .. "Item" .. sl]
      if frame and frame:IsMouseOver() then
        bag, slot = b, sl
        break
      end
    end
    if bag then
      break
    end
  end
  if bag and slot then
    self:ToggleJunkItem(bag, slot)
  else
    self:Print("Hover over a bag item and type /tg junk")
  end
end

Junk.tick = sellJunkTick
Junk.endVisit = endSale
Junk.isGrey = isGrey
Junk.sellInterval = SELL_EVERY
