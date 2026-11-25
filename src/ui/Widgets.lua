-- shared frame widget builders
local TG = _G.TurtleGuides
local Widgets = {}
TG.UI = TG.UI or {}
TG.UI.Widgets = Widgets

function Widgets.makeCheck(parent, label, x, y, get, set)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  cb.text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
  cb.text:SetText(label)
  cb:SetScript("OnClick", function()
    set(cb:GetChecked() and true or false)
  end)
  cb._get = get
  return cb
end

function Widgets.makeButton(parent, label, x, y, onClick)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetWidth(150)
  button:SetHeight(20)
  button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  button:SetText(label)
  button:SetScript("OnClick", onClick)
  return button
end

function Widgets.makeSlider(parent, label, x, y, minVal, maxVal, step, get, set)
  local minus = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  minus:SetWidth(22)
  minus:SetHeight(22)
  minus:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  minus:SetText("-")

  local slider = CreateFrame("Slider", nil, parent)
  slider:SetWidth(180)
  slider:SetHeight(22)
  slider:SetOrientation("HORIZONTAL")
  slider:SetPoint("LEFT", minus, "RIGHT", 4, 0)
  slider:SetMinMaxValues(minVal, maxVal)
  slider:SetValueStep(step)
  slider:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  slider:SetBackdropColor(0.12, 0.14, 0.18, 0.90)
  local thumb = slider:CreateTexture(nil, "OVERLAY")
  thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  thumb:SetWidth(22)
  thumb:SetHeight(22)
  slider:SetThumbTexture(thumb)

  local plus = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  plus:SetWidth(22)
  plus:SetHeight(22)
  plus:SetPoint("LEFT", slider, "RIGHT", 4, 0)
  plus:SetText("+")

  local labelText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  labelText:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 2)
  slider.labelText = labelText

  local function clamp(v)
    if v < minVal then
      return minVal
    end
    if v > maxVal then
      return maxVal
    end
    return v
  end
  minus:SetScript("OnClick", function()
    slider:SetValue(clamp(slider:GetValue() - step))
  end)
  plus:SetScript("OnClick", function()
    slider:SetValue(clamp(slider:GetValue() + step))
  end)
  slider:SetScript("OnValueChanged", function()
    local v = this:GetValue()
    labelText:SetText(label .. ": " .. string.format("%.1f", v))
    set(v)
  end)
  slider._refresh = function()
    local v = clamp(get())
    slider:SetValue(v)
    labelText:SetText(label .. ": " .. string.format("%.1f", v))
  end
  slider.buttons = { minus, plus }
  return slider
end

function Widgets.addTooltip(button, title, lines)
  button:SetScript("OnEnter", function()
    if not GameTooltip then
      return
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetText(title)
    for _, line in ipairs(lines or {}) do
      GameTooltip:AddLine(line, 1, 1, 1, 1)
    end
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
end

function Widgets.makeNote(parent, y, text)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
  fs:SetWidth(420)
  fs:SetJustifyH("LEFT")
  fs:SetJustifyV("TOP")
  if fs.SetNonSpaceWrap then
    fs:SetNonSpaceWrap(true)
  end
  fs:SetText(text)
  return fs
end

function Widgets.shortText(s, maxLen)
  s = tostring(s or "")
  if string.len(s) <= maxLen then
    return s
  end
  return string.sub(s, 1, maxLen - 3) .. "..."
end

Widgets.SETTINGS_TABS = { "General", "Automation", "Guides" }
