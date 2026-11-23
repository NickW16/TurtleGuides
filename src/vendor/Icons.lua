-- junk coin icons on bag buttons
local TG = _G.TurtleGuides
local Icons = {}
TG.Vendor.Icons = Icons

local function showJunkIcon(button)
  if not button then
    return
  end
  if not button.TGJunkIcon then
    local texture = button:CreateTexture(nil, "OVERLAY")
    texture:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
    texture:SetWidth(14)
    texture:SetHeight(14)
    texture:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    button.TGJunkIcon = texture
  end
  button.TGJunkIcon:Show()
end

local function hideJunkIcon(button)
  if button and button.TGJunkIcon then
    button.TGJunkIcon:Hide()
  end
end

local function updateBagButton(button, bag, slot)
  if not button then
    return
  end
  if TG:IsItemJunk(bag, slot) then
    showJunkIcon(button)
  else
    hideJunkIcon(button)
  end
end

local function updateAllBags()
  for frameIdx = 1, 5 do
    local frame = _G["ContainerFrame" .. frameIdx]
    if frame then
      local bag
      if ContainerFrame_GetFrameID then
        bag = ContainerFrame_GetFrameID(frame)
      else
        bag = frameIdx - 1
      end
      if bag ~= nil then
        local slots = GetContainerNumSlots(bag) or 0
        for slot = 1, slots do
          local button = _G["ContainerFrame" .. frameIdx .. "Item" .. slot]
          if button then
            updateBagButton(button, bag, slot)
          end
        end
        local children = { frame:GetChildren() }
        for _, child in ipairs(children) do
          if child and child:GetObjectType() == "Button" and child.GetID then
            local slot = child:GetID()
            if slot and slot > 0 and slot <= slots then
              updateBagButton(child, bag, slot)
            end
          end
        end
      end
    end
  end
end

function TG:RefreshJunkIcons()
  updateAllBags()
end

Icons.updateAllBags = updateAllBags
