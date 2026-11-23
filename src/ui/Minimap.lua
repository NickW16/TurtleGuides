-- minimap button
local TG = _G.TurtleGuides
local button

function TG:InitMinimap()
  if button then
    return
  end
  button = CreateFrame("Button", "TurtleGuidesMinimapButton", Minimap)
  button:SetWidth(31)
  button:SetHeight(31)
  button:SetFrameStrata("MEDIUM")
  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local overlay = button:CreateTexture(nil, "OVERLAY")
  overlay:SetWidth(53)
  overlay:SetHeight(53)
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  overlay:SetPoint("TOPLEFT", 0, 0)

  local icon = button:CreateTexture(nil, "BACKGROUND")
  icon:SetWidth(20)
  icon:SetHeight(20)
  icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
  icon:SetPoint("TOPLEFT", 7, -5)
  button.icon = icon

  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:SetScript("OnClick", function()
    if arg1 == "RightButton" then
      TG:ShowSettings()
    else
      TG:ToggleUI()
    end
  end)
  button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:AddLine("|cffffd100TurtleGuides|r")
    if TG.currentGuide then
      GameTooltip:AddLine((TG.currentGuide.group or "") .. " - " .. (TG.currentGuide.name or ""), 1, 1, 1)
      GameTooltip:AddLine(
        "Step " .. (TG.currentStepIndex or 1) .. " / " .. table.getn(TG.currentGuide.steps or {}),
        0.7,
        0.7,
        0.7
      )
    else
      GameTooltip:AddLine("No guide selected", 0.7, 0.7, 0.7)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffffffffLeft-click:|r Toggle window", 1, 1, 1)
    GameTooltip:AddLine("|cffffffffRight-click:|r Settings", 1, 1, 1)
    GameTooltip:AddLine("|cffffffffDrag:|r Move button", 1, 1, 1)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  button:RegisterForDrag("LeftButton")
  button:SetScript("OnDragStart", function()
    this.dragging = true
  end)
  button:SetScript("OnDragStop", function()
    this.dragging = false
  end)
  button:SetScript("OnUpdate", function()
    if not this.dragging then
      return
    end
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    cx, cy = cx / scale, cy / scale
    local atan2 = TG.math_atan2 or math.atan2
    local angle = atan2(cy - my, cx - mx)
    TG.db.minimapPos = math.deg(angle)
    TG:UpdateMinimap()
  end)

  TG.minimapButton = button
  TG:UpdateMinimap()
end

function TG:UpdateMinimap()
  if not button then
    return
  end
  if not (TG.db and TG.db.showMinimap) then
    button:Hide()
    return
  end
  local angle = math.rad(TG.db.minimapPos or 220)
  local x = math.cos(angle) * 80
  local y = math.sin(angle) * 80
  button:SetPoint("CENTER", Minimap, "CENTER", x, y)
  button:Show()
end
