-- floating windows for the current steps, stacked above the main window
local TG = _G.TurtleGuides
local State = TG.UI.State
local Theme = TG.UI.Theme
local TextWrap = TG.UI.TextWrap

local MAX_WINDOWS = 3
local BOX_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Up"
local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local windows = {}

local function setCheckState(button, state)
  if not button or not button.texture then
    return
  end
  if state == true then
    button.texture:SetTexture(CHECK_TEXTURE)
    button.texture:SetVertexColor(0.40, 1.00, 0.40, 1.00)
  elseif state == false then
    button.texture:SetTexture(BOX_TEXTURE)
    button.texture:SetVertexColor(1.00, 1.00, 1.00, 1.00)
  else
    button.texture:SetTexture(BOX_TEXTURE)
    button.texture:SetVertexColor(0.55, 0.55, 0.58, 0.75)
  end
end

local function makeCheck(parent, index)
  local button = CreateFrame("Button", nil, parent)
  button:SetWidth(14)
  button:SetHeight(14)
  button:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -20 - (index - 1) * 14)
  local texture = button:CreateTexture(nil, "ARTWORK")
  texture:SetTexture(BOX_TEXTURE)
  texture:SetAllPoints(button)
  button.texture = texture
  button:SetScript("OnClick", function()
    local el = button.element
    if not el or not TG.IsElementTrackable or not TG:IsElementTrackable(el) then
      return
    end
    if TG.SetElementManualDone then
      TG:SetElementManualDone(el, not el._tgManualDone)
    end
    if TG.UpdateUI then
      TG:UpdateUI()
    end
    if TG.CheckAdvance then
      TG:CheckAdvance("manual")
    end
  end)
  return button
end

local function makeWindow(index)
  local frame = CreateFrame("Frame", "TurtleGuidesStepWindow" .. index, UIParent)
  frame:SetWidth(280)
  frame:SetHeight(60)
  frame:EnableMouse(true)
  Theme.createBackdrop(frame)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -8)
  title:SetTextColor(unpack(Theme.accent()))
  frame.title = title
  frame.lines = {}
  frame.checks = {}
  for i = 1, 4 do
    local line = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line:SetFont(STANDARD_TEXT_FONT, 10)
    line:SetPoint("TOPLEFT", frame, "TOPLEFT", 28, -20)
    line:SetWidth(242)
    line:SetJustifyH("LEFT")
    line:SetJustifyV("TOP")
    if line.SetNonSpaceWrap then
      line:SetNonSpaceWrap(true)
    end
    frame.lines[i] = line
    frame.checks[i] = makeCheck(frame, i)
  end
  return frame
end

function TG:InitStepWindows()
  if table.getn(windows) > 0 then
    return
  end
  for i = 1, MAX_WINDOWS do
    local frame = makeWindow(i)
    frame:Hide()
    table.insert(windows, frame)
  end
end

local function stepLines(step)
  local out = {}
  if not step then
    return out
  end
  for _, el in ipairs(step.elements or {}) do
    if not (el.t == "cmd" and el.tag == "goto") then
      local text = TG.UI.StepText.elToTextNoWarn(el)
      if text and text ~= "" then
        local state = nil
        local color = "|cffffffff"
        if el.t == "cmd" and TG.IsElementTrackable and TG:IsElementTrackable(el) then
          state = TG:IsElementDone(el)
          if state == true then
            color = "|cff66ff66"
          elseif state == false then
            color = "|cffffff80"
          else
            color = "|cffaaaaaa"
          end
        end
        table.insert(out, { text = color .. text .. "|r", el = el, state = state })
        if table.getn(out) >= 4 then
          break
        end
      end
    end
  end
  return out
end

function TG:UpdateStepWindows()
  if table.getn(windows) == 0 then
    return
  end
  local mainFrame = State.mainFrame
  if not mainFrame or not mainFrame:IsShown() then
    for _, frame in ipairs(windows) do
      frame:Hide()
    end
    return
  end
  local guide = self.currentGuide
  local steps = {}
  if guide then
    table.insert(steps, { index = self.currentStepIndex or 1, step = self:CurrentStep() })
    for _, aux in ipairs(self.GetActiveAuxSteps and self:GetActiveAuxSteps() or {}) do
      if table.getn(steps) < MAX_WINDOWS then
        table.insert(steps, { index = 0, step = aux })
      end
    end
  end

  local above = mainFrame
  for i, window in ipairs(windows) do
    local data = steps[i]
    if data and data.step then
      local lines = stepLines(data.step)
      window.title:SetText(data.index > 0 and ("Step " .. data.index) or "Additional")
      window:ClearAllPoints()
      window:SetPoint("BOTTOMLEFT", above, "TOPLEFT", 0, 6)
      window:SetPoint("BOTTOMRIGHT", above, "TOPRIGHT", 0, 6)
      local lineWidth = math.max(80, (mainFrame:GetWidth() or 320) - 38)
      local y = -20
      for j = 1, 4 do
        local entry = lines[j]
        local line = window.lines[j]
        local check = window.checks[j]
        local _, fontSize = line:GetFont()
        local wrapped, lineCount = TextWrap.wrap(entry and entry.text or "", lineWidth - 4, fontSize or 10)
        line:SetWidth(lineWidth)
        line:SetText(wrapped)
        line:ClearAllPoints()
        line:SetPoint("TOPLEFT", window, "TOPLEFT", 28, y)
        check:ClearAllPoints()
        check:SetPoint("TOPLEFT", window, "TOPLEFT", 8, y)
        check:Show()
        check.element = entry and entry.el or nil
        setCheckState(check, entry and entry.state or nil)
        y = y - math.ceil(lineCount * TextWrap.lineHeight(fontSize or 10))
      end
      window:SetHeight(math.abs(y) + 10)
      window:Show()
      above = window
    else
      window:Hide()
    end
  end
end

function TG:HideStepWindows()
  for _, window in ipairs(windows) do
    window:Hide()
  end
end

TG.UI.StepWindows = {
  windows = function()
    return windows
  end,
}
