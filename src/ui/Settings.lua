-- compact native settings window
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text
local Widgets = TG.UI.Widgets

local function panel(frame)
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 4,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  frame:SetBackdropColor(0.04, 0.04, 0.05, 0.95)
  frame:SetBackdropBorderColor(0.28, 0.28, 0.30, 0.90)
end

function TG:ShowSettings()
  if State.picker then
    State.picker:Hide()
  end
  if not State.settings then
    self:CreateSettings()
  end
  self:RefreshSettings()
  State.settings:Show()
end

function TG:ShowSuggestions()
  self:ShowGuidePicker()
end

function TG:CreateSettings()
  local frame = CreateFrame("Frame", "TurtleGuidesSettingsFrame", UIParent)
  State.settings = frame
  frame:SetWidth(300)
  frame:SetHeight(290)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function()
    if not TG.db.locked then
      this:StartMoving()
    end
  end)
  frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
  end)
  panel(frame)
  frame:Hide()

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
  title:SetText("TurtleGuides")
  title:SetTextColor(1.00, 0.82, 0.35)
  Text.register(title, 10)

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetWidth(18)
  close:SetHeight(18)
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame.checks = {}
  local y = -22
  local function add(label, key, after)
    local check = Widgets.makeCheck(frame, label, 8, y, function()
      return TG.db[key]
    end, function(value)
      TG.db[key] = value
      if after then
        after(value)
      end
    end)
    Text.register(check.text, 10)
    check:SetScript("OnClick", function()
      TG.db[key] = check:GetChecked() and true or false
      if after then
        after(TG.db[key])
      end
    end)
    table.insert(frame.checks, check)
    y = y - 20
  end
  add("Show arrow", "showArrow", function()
    if TG.UpdateArrowVisibility then
      TG:UpdateArrowVisibility()
    end
  end)
  add("Lock frames", "locked")
  add("Show minimap button", "showMinimap", function()
    if TG.UpdateMinimap then
      TG:UpdateMinimap()
    end
  end)
  add("Disable auto-skip", "disableAutoSkip")
  add("Auto accept / turn-in", "autoTurnIn")
  add("Auto sell junk", "autoSellJunk")
  add("Auto use quest items", "autoUseQuestItems")
  add("Auto flight paths", "autoTakeFlight")
  add("Auto buy vendor items", "autoBuyVendor")
  add("Hardcore mode", "hardcoreMode", function()
    if TG.currentGuide then
      TG:SetGuide(TG.currentGuide.key, TG.currentStepIndex, true)
    end
  end)

  local find = Widgets.makeButton(frame, "Find my place", 8, y - 4, function()
    if TG.FindMyPlace then
      TG:FindMyPlace()
    end
  end)
  find:SetWidth(130)
  find:SetHeight(18)
  local guides = Widgets.makeButton(frame, "Guides", 146, y - 4, function()
    TG:ShowGuidePicker()
  end)
  guides:SetWidth(130)
  guides:SetHeight(18)

  frame.fontSlider = Widgets.makeSlider(frame, "Font size", 8, y - 32, 0.8, 1.4, 0.1, function()
    return tonumber(TG.db.fontScale) or 1.0
  end, function(value)
    TG.db.fontScale = value
    if TG.RefreshFonts then
      TG:RefreshFonts()
    end
  end)
  Text.register(frame.fontSlider.labelText, 10)
end

function TG:RefreshSettings()
  local frame = State.settings
  if not frame then
    return
  end
  for _, check in ipairs(frame.checks or {}) do
    if check._get then
      check:SetChecked(check._get() and 1 or 0)
    end
  end
  if frame.fontSlider and frame.fontSlider._refresh then
    frame.fontSlider._refresh()
  end
end
