-- compact native settings window built from plain text rows
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local ROW_HEIGHT = 16
local BAR = "Interface\\AddOns\\TurtleGuides\\Media\\BarTexture"
local DOT = "Interface\\Buttons\\WHITE8X8"

local originalEscapeAction
local escapeBindingActive = false

local function restoreEscapeBinding()
  if not escapeBindingActive then
    return
  end
  if SetBinding then
    SetBinding("ESCAPE", originalEscapeAction or "")
  end
  originalEscapeAction = nil
  escapeBindingActive = false
end

local function captureEscapeBinding(button)
  if escapeBindingActive or not SetBinding or not GetBindingAction then
    return
  end
  originalEscapeAction = GetBindingAction("ESCAPE")
  local name = button and button.GetName and button:GetName()
  if not name then
    return
  end
  if SetBinding("ESCAPE", "CLICK " .. name .. ":LeftButton") ~= false then
    escapeBindingActive = true
  else
    originalEscapeAction = nil
  end
end

local function panel(frame)
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 4,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  frame:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
  frame:SetBackdropBorderColor(0.40, 0.36, 0.30, 0.90)
end

local function textButton(parent, label, width, onClick)
  local button = CreateFrame("Button", nil, parent)
  button:SetWidth(width)
  button:SetHeight(14)
  local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("CENTER", button, "CENTER", 0, 0)
  text:SetText(label)
  text:SetTextColor(0.85, 0.85, 0.88)
  Text.register(text, 10)
  button.text = text
  button:SetScript("OnClick", onClick)
  return button
end

function TG:AnchorSettings()
  local frame = State.settings
  if not frame then
    return
  end
  frame:ClearAllPoints()
  local picker = State.picker
  if picker and picker:IsShown() then
    frame:SetPoint("TOPRIGHT", picker, "TOPLEFT", -14, 0)
    return
  end
  local main = State.main
  if not main then
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    return
  end
  local point = main:GetPoint(1) or "RIGHT"
  if string.find(point, "LEFT", 1, true) then
    frame:SetPoint("TOPLEFT", main, "TOPRIGHT", 4, 0)
  else
    frame:SetPoint("TOPRIGHT", main, "TOPLEFT", -4, 0)
  end
end

function TG:ShowSettings()
  if not State.settings then
    self:CreateSettings()
  end
  self:RefreshSettings()
  self:AnchorSettings()
  captureEscapeBinding(State.settings.close)
  State.settings:Show()
  if self.RefreshPickerFlipper then
    self:RefreshPickerFlipper()
  end
end

function TG:ToggleSettingsDocked()
  if not State.settings then
    self:CreateSettings()
  end
  if State.settings:IsShown() then
    State.settings:Hide()
    return
  end
  self:ShowSettings()
end

function TG:ShowSuggestions()
  self:ShowGuidePicker()
end

function TG:CreateSettings()
  local frame = CreateFrame("Frame", "TurtleGuidesSettingsFrame", UIParent)
  State.settings = frame
  frame:SetWidth(240)
  frame:SetHeight(240)
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
  local baseHide = frame.Hide
  frame.Hide = function(hiddenFrame)
    restoreEscapeBinding()
    baseHide(hiddenFrame)
    if TG.RefreshPickerFlipper then
      TG:RefreshPickerFlipper()
    end
  end
  panel(frame)
  frame:Hide()

  local topbar = frame:CreateTexture(nil, "BORDER")
  topbar:SetTexture(BAR)
  topbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
  topbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
  topbar:SetHeight(24)
  topbar:SetVertexColor(0.92, 0.90, 0.86, 1.00)

  local topbarLine = frame:CreateTexture(nil, "ARTWORK")
  topbarLine:SetTexture(DOT)
  topbarLine:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -25)
  topbarLine:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -25)
  topbarLine:SetHeight(1)
  topbarLine:SetVertexColor(0.85, 0.85, 0.88, 0.08)

  local footer = frame:CreateTexture(nil, "BORDER")
  footer:SetTexture(BAR)
  footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
  footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
  footer:SetHeight(16)
  footer:SetVertexColor(0.92, 0.90, 0.86, 1.00)

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -7)
  title:SetText("Settings")
  title:SetTextColor(0.85, 0.75, 0.40)
  Text.register(title, 12)
  frame.title = title

  local close = CreateFrame("Button", "TurtleGuidesSettingsCloseButton", frame)
  frame.close = close
  close:SetWidth(12)
  close:SetHeight(12)
  close:SetNormalTexture("Interface\\AddOns\\TurtleGuides\\Media\\Close")
  close:SetPushedTexture("Interface\\AddOns\\TurtleGuides\\Media\\Close")
  local closeIcon = close.GetNormalTexture and close:GetNormalTexture() or nil
  if closeIcon and closeIcon.SetVertexColor then
    closeIcon:SetVertexColor(0.85, 0.85, 0.88)
  end
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -6)
  close:SetScript("OnClick", function()
    frame:Hide()
  end)

  local definitions = {
    { "showArrow", "Show arrow" },
    { "locked", "Lock frames" },
    { "showMinimap", "Show minimap button" },
    { "disableAutoSkip", "Disable auto-skip" },
    { "autoTurnIn", "Auto accept / turn-in" },
    { "autoSellJunk", "Auto sell junk" },
    { "autoUseQuestItems", "Auto use quest items" },
    { "autoTakeFlight", "Auto flight paths" },
    { "autoBuyVendor", "Auto buy vendor items" },
    {
      "hardcoreMode",
      "Hardcore mode",
      function()
        if TG.currentGuide then
          TG:SetGuide(TG.currentGuide.key, TG.currentStepIndex, true)
        end
      end,
    },
  }
  frame.rows = {}
  for i, def in ipairs(definitions) do
    local row = CreateFrame("Button", nil, frame)
    row:SetWidth(228)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -34 - (i - 1) * ROW_HEIGHT)
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", row, "LEFT", 2, 0)
    Text.register(text, 10)
    row.text = text
    row.key = def[1]
    row.label = def[2]
    row.after = def[3]
    row:SetScript("OnClick", function()
      TG.db[row.key] = not TG.db[row.key]
      if row.after then
        row.after()
      end
      TG:RefreshSettings()
    end)
    table.insert(frame.rows, row)
  end

  local fontY = -34 - table.getn(definitions) * ROW_HEIGHT - 4
  local fontLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  fontLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, fontY)
  fontLabel:SetText("Font size")
  fontLabel:SetTextColor(0.90, 0.90, 0.90)
  Text.register(fontLabel, 10)
  frame.fontLabel = fontLabel

  local minus = textButton(frame, "-", 14, function()
    TG.db.fontScale = math.max(0.8, (tonumber(TG.db.fontScale) or 1.0) - 0.1)
    if TG.RefreshFonts then
      TG:RefreshFonts()
    end
    TG:RefreshSettings()
  end)
  minus:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -38, fontY + 2)
  local plus = textButton(frame, "+", 14, function()
    TG.db.fontScale = math.min(1.4, (tonumber(TG.db.fontScale) or 1.0) + 0.1)
    if TG.RefreshFonts then
      TG:RefreshFonts()
    end
    TG:RefreshSettings()
  end)
  plus:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, fontY + 2)
  frame.fontValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.fontValue:SetPoint("RIGHT", minus, "LEFT", -4, 0)
  frame.fontValue:SetTextColor(0.85, 0.85, 0.88)
  Text.register(frame.fontValue, 10)
end

function TG:RefreshSettings()
  local frame = State.settings
  if not frame then
    return
  end
  for _, row in ipairs(frame.rows or {}) do
    local enabled = TG.db[row.key] and true or false
    row.text:SetText((enabled and "[x] " or "[ ] ") .. row.label)
    row.text:SetTextColor(enabled and 0.55 or 0.90, enabled and 0.90 or 0.90, enabled and 0.55 or 0.90)
  end
  if frame.fontValue then
    frame.fontValue:SetText(string.format("%.1f", tonumber(TG.db.fontScale) or 1.0))
  end
end
