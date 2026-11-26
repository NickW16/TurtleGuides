-- compact native settings window built from plain text rows
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local ROW_HEIGHT = 16

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

function TG:ShowSuggestions()
  self:ShowGuidePicker()
end

function TG:CreateSettings()
  local picker = State.picker
  local frame = CreateFrame("Frame", "TurtleGuidesSettingsFrame", picker)
  State.settings = frame
  frame:SetPoint("TOPLEFT", picker, "TOPLEFT", 14, -32)
  frame:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -8, 8)
  frame:Hide()

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
