-- main guide window and step row rendering
local TG = _G.TurtleGuides
local State = TG.UI.State
local Theme = TG.UI.Theme
local StepText = TG.UI.StepText
local TextWrap = TG.UI.TextWrap

local ICON_NOTE = "Interface\\Buttons\\WHITE8X8"
local ICON_HIGHLIGHT = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
local COLOR_DONE = { 0.45, 0.85, 0.50 }
local COLOR_UNKNOWN = { 0.58, 0.58, 0.58 }
local ICON_SIZE = 16
local STEP_ROW_GAP = 0
local BOX_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Up"
local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local STEP_ROW_WIDTH = 246
local STEP_TEXT_X = 20
local STEP_TEXT_WIDTH = STEP_ROW_WIDTH - STEP_TEXT_X - 4
local MAX_STEP_ROWS = 32

local function hideChildFrames()
  local mainFrame = State.mainFrame
  if not mainFrame then
    return
  end
  if mainFrame.overflowFrame then
    mainFrame.overflowFrame:Hide()
  end
  for i = 1, 12 do
    if mainFrame.auxFrames and mainFrame.auxFrames[i] then
      mainFrame.auxFrames[i]:Hide()
    end
  end
  if TG.HideStepWindows then
    TG:HideStepWindows()
  end
end

local function childAnchorSpec()
  if TG.db and TG.db.frameOrientation == "above" then
    return "BOTTOM", "TOP", 4
  end
  return "TOP", "BOTTOM", -4
end

local function anchorChildFrame(child, anchor)
  if not child or not anchor then
    return
  end
  local point, relPoint, gap = childAnchorSpec()
  child:ClearAllPoints()
  child:SetPoint(point, anchor, relPoint, 0, gap)
end

local function setIconGeometry(row, w, h, x, y)
  row.icon:ClearAllPoints()
  row.icon:SetWidth(w)
  row.icon:SetHeight(h)
  row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", x, y)
end

local function setStepRowState(row, state)
  if not row or not row.text or not row.icon then
    return
  end
  row._tgState = state
  local clickable = row._tgTrackable == true
  if row.checkBtn then
    if clickable then
      row.checkBtn:Show()
    else
      row.checkBtn:Hide()
    end
  end
  if row.highlight and not clickable then
    row.highlight:Hide()
  end
  row.text:ClearAllPoints()
  if state ~= "note" and state ~= "none" then
    if state == true then
      row.icon:SetTexture(CHECK_TEXTURE)
    else
      row.icon:SetTexture(BOX_TEXTURE)
    end
  end
  local palette = Theme.current()
  if state == "note" or state == "none" then
    row.icon:Show()
    setIconGeometry(row, 4, 4, 10, -10)
    row.icon:SetTexture(ICON_NOTE)
    row.icon:SetVertexColor(1.00, 1.00, 1.00, 0.90)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 28, -6)
    row.text:SetTextColor(unpack(palette.body))
    row.text:SetAlpha(1.00)
    row._tgTip = "Tip / note - not tracked"
  elseif state == true then
    row.icon:Show()
    setIconGeometry(row, ICON_SIZE, ICON_SIZE, 8, -6)
    row.icon:SetVertexColor(0.40, 1.00, 0.40, 1.00)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 28, -6)
    row.text:SetTextColor(unpack(COLOR_DONE))
    row.text:SetAlpha(0.72)
    if row._tgElement and row._tgElement._tgManualDone then
      row._tgTip = "Completed manually - click to undo"
    else
      row._tgTip = "Completed" .. (row._tgSource and (" (" .. row._tgSource .. ")") or "")
    end
  elseif state == false then
    row.icon:Show()
    setIconGeometry(row, ICON_SIZE, ICON_SIZE, 8, -6)
    row.icon:SetVertexColor(1.00, 1.00, 1.00, 1.00)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 28, -6)
    row.text:SetTextColor(unpack(palette.body))
    row.text:SetAlpha(1.00)
    row._tgTip = clickable and "Not completed - click to mark complete" or "Not completed"
  else
    row.icon:Show()
    setIconGeometry(row, ICON_SIZE, ICON_SIZE, 8, -6)
    row.icon:SetVertexColor(0.55, 0.55, 0.58, 0.75)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 28, -6)
    row.text:SetTextColor(unpack(COLOR_UNKNOWN))
    row.text:SetAlpha(0.78)
    row._tgTip = clickable and "Unknown - click to mark complete" or "Unknown - check your quest log or bags"
  end
end

local function clearStepRows()
  for _, row in ipairs(State.stepRows) do
    row:Hide()
  end
end

local function fontOf(fs)
  local _, size = fs:GetFont()
  return size or 10
end

-- derive width from the main frame because anchor based GetWidth can be stale
local function stepContentWidth(mainFrame)
  return math.max(120, (mainFrame:GetWidth() or 320) - 70)
end

function TG:RefreshMainWindowLayout()
  if not State.mainFrame or not State.mainFrame.scrollContent then
    return
  end
  local width = stepContentWidth(State.mainFrame)
  State.mainFrame.scrollContent:SetWidth(width)
  for _, row in ipairs(State.stepRows) do
    row:SetWidth(width)
  end
  if State.mainFrame:IsShown() then
    self:UpdateUI()
  end
end

local function layoutStepRows(entries, limit)
  clearStepRows()
  local mainFrame = State.mainFrame
  if not mainFrame or not mainFrame.stepHeader then
    return 0
  end
  local y, total = -2, 0
  local width = stepContentWidth(mainFrame)
  local textWidth = math.max(60, width - 34)
  for i = 1, limit do
    local row, entry = State.stepRows[i], entries[i]
    if not row or not entry then
      break
    end
    row._tgElement = entry.el
    row._tgSource = entry.source
    row._tgTrackable = entry.el and TG.IsElementTrackable and TG:IsElementTrackable(entry.el) or false
    row:SetWidth(width)
    row.text:SetWidth(textWidth)
    local fontSize = fontOf(row.text)
    local wrapped, lineCount = TextWrap.wrap(StepText.stepRowText(entry), textWidth - 4, fontSize)
    row.text:SetText(wrapped)
    setStepRowState(row, entry.state)
    row:Show()
    local h = math.ceil(lineCount * TextWrap.lineHeight(fontSize)) + 4
    if row.icon:IsShown() and row.icon.GetHeight then
      local iconH = row.icon:GetHeight() or 14
      if iconH > h then
        h = iconH
      end
    end
    row:SetHeight(h)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", mainFrame.scrollContent, "TOPLEFT", 0, y)
    total = total + h
    if i < limit then
      total = total + STEP_ROW_GAP
      y = y - h - STEP_ROW_GAP
    else
      y = y - h
    end
  end
  return total
end

function TG:InitUI()
  if State.mainFrame then
    return
  end
  local mainFrame = CreateFrame("Frame", "TurtleGuidesMainFrame", UIParent)
  State.mainFrame = mainFrame
  local palette = Theme.current()
  local p = TG.db.frame or { point = "RIGHT", relPoint = "RIGHT", x = -40, y = 0, w = 320, h = 420 }
  mainFrame:SetWidth(p.w or 320)
  mainFrame:SetHeight(p.h or 420)
  mainFrame:SetPoint(p.point or "RIGHT", UIParent, p.relPoint or "RIGHT", p.x or -40, p.y or 0)
  mainFrame:SetMovable(true)
  if mainFrame.SetResizable then
    mainFrame:SetResizable(true)
  end
  if mainFrame.SetMinResize then
    mainFrame:SetMinResize(260, 300)
  end
  mainFrame:EnableMouse(true)
  mainFrame:RegisterForDrag("LeftButton")
  mainFrame:SetScript("OnDragStart", function()
    if not TG.db.locked then
      this:StartMoving()
    end
  end)
  mainFrame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
    local point, _, rel, x, y = this:GetPoint(1)
    TG.db.frame.point, TG.db.frame.relPoint, TG.db.frame.x, TG.db.frame.y = point, rel, x, y
    TG.db.frame.w, TG.db.frame.h = this:GetWidth(), this:GetHeight()
    if TG.RefreshMainWindowLayout then
      TG:RefreshMainWindowLayout()
    end
  end)
  mainFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 8,
    edgeSize = 2,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  mainFrame:SetBackdropColor(unpack(palette.bg))
  mainFrame:SetBackdropBorderColor(unpack(palette.border))

  local accentBar = mainFrame:CreateTexture(nil, "ARTWORK")
  accentBar:SetTexture("Interface\\Buttons\\WHITE8X8")
  accentBar:SetVertexColor(unpack(Theme.accent()))
  accentBar:SetHeight(2)
  accentBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 2, -2)
  accentBar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
  mainFrame.accentBar = accentBar

  local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -10)
  title:SetText("TurtleGuides")
  title:SetTextColor(unpack(Theme.accent()))
  mainFrame.title = title

  local close = CreateFrame("Button", nil, mainFrame)
  close:SetWidth(18)
  close:SetHeight(18)
  close:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -8, -8)
  local closeText = close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  closeText:SetPoint("CENTER", close, "CENTER", 0, 0)
  closeText:SetText("X")
  closeText:SetTextColor(unpack(palette.body))
  close:SetScript("OnEnter", function()
    closeText:SetTextColor(unpack(Theme.accent()))
  end)
  close:SetScript("OnLeave", function()
    closeText:SetTextColor(unpack(palette.body))
  end)
  close:SetScript("OnClick", function()
    mainFrame:Hide()
    hideChildFrames()
  end)
  mainFrame.closeBtn = close

  local guideBtn = CreateFrame("Button", nil, mainFrame)
  guideBtn:SetWidth(22)
  guideBtn:SetHeight(22)
  guideBtn:SetPoint("RIGHT", close or mainFrame, "LEFT", -6, 0)
  guideBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Book_09")
  guideBtn:SetPushedTexture("Interface\\Icons\\INV_Misc_Book_09")
  guideBtn:SetScript("OnClick", function()
    TG:ShowGuidePicker()
  end)
  mainFrame.guideBtn = guideBtn

  local settingsBtn = CreateFrame("Button", nil, mainFrame)
  settingsBtn:SetWidth(22)
  settingsBtn:SetHeight(22)
  settingsBtn:SetPoint("RIGHT", guideBtn, "LEFT", -4, 0)
  settingsBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01")
  settingsBtn:SetPushedTexture("Interface\\Icons\\INV_Misc_Gear_01")
  settingsBtn:SetScript("OnClick", function()
    TG:ShowSettings()
  end)
  mainFrame.settingsBtn = settingsBtn

  local guideName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  guideName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 14, -44)
  guideName:SetPoint("RIGHT", mainFrame, "RIGHT", -44, 0)
  guideName:SetJustifyH("LEFT")
  guideName:SetText("No guide selected. Click Guides.")
  mainFrame.guideName = guideName

  local progressFrame = CreateFrame("Frame", nil, mainFrame)
  progressFrame:SetPoint("TOPLEFT", guideName, "BOTTOMLEFT", 0, -8)
  progressFrame:SetPoint("RIGHT", mainFrame, "RIGHT", -10, 0)
  progressFrame:SetHeight(10)
  Theme.createBackdrop(progressFrame, palette.progress)
  mainFrame.progressFrame = progressFrame

  local progressBar = progressFrame:CreateTexture(nil, "ARTWORK")
  progressBar:SetPoint("TOPLEFT", progressFrame, "TOPLEFT", 2, -2)
  progressBar:SetHeight(6)
  progressBar:SetWidth(1)
  progressBar:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
  progressBar:SetVertexColor(unpack(palette.bar))
  mainFrame.progressBar = progressBar

  local progressText = progressFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  progressText:SetPoint("CENTER", progressFrame, "CENTER", 0, 0)
  progressText:SetText("")
  mainFrame.progressText = progressText

  local stepBox = CreateFrame("Frame", nil, mainFrame)
  stepBox:SetPoint("TOPLEFT", progressFrame, "BOTTOMLEFT", -2, -4)
  stepBox:SetPoint("RIGHT", mainFrame, "RIGHT", -10, 0)
  stepBox:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 10, 52)
  Theme.createBackdrop(stepBox, palette.panel)
  mainFrame.stepBox = stepBox

  local stepHeader = stepBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  stepHeader:SetPoint("TOPLEFT", stepBox, "TOPLEFT", 12, -8)
  stepHeader:SetTextColor(unpack(palette.header))
  stepHeader:SetPoint("RIGHT", stepBox, "RIGHT", -8, 0)
  stepHeader:SetJustifyH("LEFT")
  stepHeader:SetText("Step")
  mainFrame.stepHeader = stepHeader

  local scrollFrame = CreateFrame("ScrollFrame", "TurtleGuidesStepScroll", stepBox, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", stepHeader, "BOTTOMLEFT", 0, -4)
  scrollFrame:SetPoint("BOTTOMRIGHT", stepBox, "BOTTOMRIGHT", -18, 4)
  scrollFrame:EnableMouseWheel(true)
  local scrollBar = scrollFrame.ScrollBar
  if scrollBar then
    scrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    scrollBar:Show()
  end
  local content = CreateFrame("Frame", nil, scrollFrame)
  content:SetWidth(stepContentWidth(mainFrame))
  content:SetHeight(20)
  scrollFrame:SetScrollChild(content)
  mainFrame.scrollFrame = scrollFrame
  mainFrame.scrollContent = content

  local legacy = stepBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  legacy:SetPoint("TOPLEFT", stepHeader, "BOTTOMLEFT", 12, -10)
  legacy:SetJustifyH("LEFT")
  legacy:SetJustifyV("TOP")
  legacy:SetWidth(STEP_ROW_WIDTH)
  if legacy.SetNonSpaceWrap then
    legacy:SetNonSpaceWrap(true)
  end
  legacy:SetText("")
  legacy:Hide()
  State.stepLines[1] = legacy
  for i = 2, 8 do
    State.stepLines[i] = legacy
  end

  State.stepRows = {}
  for _ = 1, MAX_STEP_ROWS do
    local row = CreateFrame("Frame", nil, content)
    row:SetWidth(STEP_ROW_WIDTH)
    row:SetHeight(14)
    row:SetPoint("TOPLEFT", stepHeader, "BOTTOMLEFT", 0, -10)
    local icon = row:CreateTexture(nil, "OVERLAY")
    icon:SetWidth(ICON_SIZE)
    icon:SetHeight(ICON_SIZE)
    icon:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -8)
    row.icon = icon
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetFont(STANDARD_TEXT_FONT, 10)
    text:SetPoint("TOPLEFT", row, "TOPLEFT", 28, -6)
    text:SetWidth(STEP_TEXT_WIDTH)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if text.SetNonSpaceWrap then
      text:SetNonSpaceWrap(true)
    end
    text:SetText("")
    row.text = text
    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture(ICON_HIGHLIGHT)
    highlight:SetAllPoints(text)
    if highlight.SetBlendMode then
      highlight:SetBlendMode("ADD")
    end
    highlight:SetAlpha(0.20)
    highlight:Hide()
    row.highlight = highlight
    local checkBtn = CreateFrame("Button", nil, row)
    checkBtn:SetWidth(ICON_SIZE)
    checkBtn:SetHeight(ICON_SIZE)
    checkBtn:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -6)
    if checkBtn.EnableMouse then
      checkBtn:EnableMouse(true)
    end
    checkBtn:SetScript("OnClick", function()
      local el = row._tgElement
      if not el or not row._tgTrackable then
        return
      end
      local value = not el._tgManualDone
      if TG.SetElementManualDone then
        TG:SetElementManualDone(el, value)
      else
        el._tgManualDone = value and true or nil
      end
      if TG.UpdateUI then
        TG:UpdateUI()
      end
      if TG.CheckAdvance then
        TG:CheckAdvance("manual")
      end
    end)
    row.checkBtn = checkBtn
    row:Hide()
    table.insert(State.stepRows, row)
  end
  mainFrame.stepRows = State.stepRows

  local nextBtn = CreateFrame("Button", nil, mainFrame)
  nextBtn:SetWidth(28)
  nextBtn:SetHeight(28)
  nextBtn:SetPoint("RIGHT", stepBox, "BOTTOMRIGHT", -10, -16)
  nextBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
  nextBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
  nextBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
  nextBtn:SetHighlightTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
  nextBtn:SetScript("OnClick", function()
    TG:NextStep(true)
  end)
  mainFrame.nextBtn = nextBtn

  local prevBtn = CreateFrame("Button", nil, mainFrame)
  prevBtn:SetWidth(28)
  prevBtn:SetHeight(28)
  prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -4, 0)
  prevBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
  prevBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
  prevBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
  prevBtn:SetHighlightTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
  prevBtn:SetScript("OnClick", function()
    TG:PrevStep()
  end)
  mainFrame.prevBtn = prevBtn

  local overflow = CreateFrame("Frame", "TurtleGuidesOverflowFrame", UIParent)
  overflow:SetWidth(300)
  overflow:SetHeight(60)
  anchorChildFrame(overflow, mainFrame)
  overflow:SetMovable(true)
  overflow:EnableMouse(true)
  overflow:RegisterForDrag("LeftButton")
  overflow:SetScript("OnDragStart", function()
    if not TG.db.locked then
      this:StartMoving()
    end
  end)
  overflow:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
  end)
  Theme.createBackdrop(overflow, palette.panel)
  overflow:Hide()
  mainFrame.overflowFrame = overflow
  local overflowLabel = overflow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  overflowLabel:SetPoint("TOPLEFT", overflow, "TOPLEFT", 12, -8)
  overflowLabel:SetTextColor(unpack(palette.header))
  overflowLabel:SetText("More:")
  overflow.label = overflowLabel
  local overflowText = overflow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  overflowText:SetPoint("TOPLEFT", overflowLabel, "BOTTOMLEFT", 0, -4)
  overflowText:SetWidth(276)
  overflowText:SetJustifyH("LEFT")
  overflowText:SetJustifyV("TOP")
  if overflowText.SetNonSpaceWrap then
    overflowText:SetNonSpaceWrap(true)
  end
  overflow.text = overflowText

  mainFrame.auxFrames = {}
  for i = 1, 12 do
    local aux = CreateFrame("Frame", "TurtleGuidesAuxFrame" .. i, UIParent)
    aux:SetWidth(300)
    aux:SetHeight(40)
    anchorChildFrame(aux, mainFrame)
    aux:SetMovable(true)
    aux:EnableMouse(true)
    aux:RegisterForDrag("LeftButton")
    aux:SetScript("OnDragStart", function()
      if not TG.db.locked then
        this:StartMoving()
      end
    end)
    aux:SetScript("OnDragStop", function()
      this:StopMovingOrSizing()
    end)
    Theme.createBackdrop(aux, palette.panel)
    aux:Hide()
    local label = aux:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", aux, "TOPLEFT", 12, -6)
    label:SetTextColor(unpack(palette.header))
    label:SetText("")
    aux.label = label
    local text = aux:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", aux, "TOPLEFT", 12, -10)
    text:SetWidth(276)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if text.SetNonSpaceWrap then
      text:SetNonSpaceWrap(true)
    end
    aux.text = text
    mainFrame.auxFrames[i] = aux
  end

  local resizer = CreateFrame("Frame", "TurtleGuidesResizeGrip", mainFrame)
  resizer:SetWidth(16)
  resizer:SetHeight(16)
  resizer:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -2, 2)
  resizer:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  resizer:SetBackdropColor(0.7, 0.7, 0.7, 0.35)
  resizer:SetAlpha(0.35)
  resizer:EnableMouse(true)
  resizer:RegisterForDrag("LeftButton")
  resizer:SetScript("OnDragStart", function()
    if not TG.db.locked then
      mainFrame:StartSizing("BOTTOMRIGHT")
    end
  end)
  resizer:SetScript("OnDragStop", function()
    mainFrame:StopMovingOrSizing()
    TG.db.frame.w, TG.db.frame.h = mainFrame:GetWidth(), mainFrame:GetHeight()
    if TG.RefreshMainWindowLayout then
      TG:RefreshMainWindowLayout()
    end
  end)
  mainFrame.resizeGrip = resizer

  if TG.InitStepWindows then
    TG:InitStepWindows()
  end
  mainFrame:Show()
  TG.mainFrame = mainFrame
  self:ApplyFrameOrientation()
  self:ApplyTheme()
  self:UpdateUI()
end

function TG:ApplyTheme()
  if not TG.db then
    return
  end
  local palette = Theme.current()
  local scale = Theme.scale()
  local function scaleFrame(f)
    if f and f.SetScale then
      f:SetScale(scale)
    end
  end
  local mainFrame = State.mainFrame
  scaleFrame(mainFrame)
  if mainFrame then
    scaleFrame(mainFrame.overflowFrame)
    for _, aux in ipairs(mainFrame.auxFrames or {}) do
      scaleFrame(aux)
    end
  end
  scaleFrame(State.pickerFrame)
  scaleFrame(State.settingsFrame)

  local function colorFont(fs, color)
    if fs and fs.SetTextColor then
      fs:SetTextColor(unpack(color))
    end
  end
  local function themePanel(f, color)
    if not f or not f.SetBackdropColor then
      return
    end
    f:SetBackdropColor(unpack(color))
    f:SetBackdropBorderColor(unpack(palette.border))
  end

  if mainFrame then
    themePanel(mainFrame, palette.bg)
    themePanel(mainFrame.progressFrame, palette.progress)
    themePanel(mainFrame.stepBox, palette.panel)
    if mainFrame.progressBar then
      mainFrame.progressBar:SetVertexColor(unpack(palette.bar))
    end
    colorFont(mainFrame.title, palette.header)
    colorFont(mainFrame.stepHeader, palette.header)
    colorFont(mainFrame.guideName, palette.body)
    colorFont(mainFrame.progressText, palette.body)
    for _, fs in ipairs(State.stepLines) do
      Theme.applyStepFont(fs)
      colorFont(fs, palette.body)
      if fs then
        fs:SetAlpha(1)
      end
    end
    for _, row in ipairs(State.stepRows) do
      Theme.applyStepFont(row.text)
      setStepRowState(row, row._tgState)
    end
    local overflow = mainFrame.overflowFrame
    if overflow then
      themePanel(overflow, palette.panel)
      colorFont(overflow.label, palette.header)
      colorFont(overflow.text, palette.body)
      Theme.applyStepFont(overflow.text)
    end
    for _, aux in ipairs(mainFrame.auxFrames or {}) do
      themePanel(aux, palette.panel)
      colorFont(aux.label, palette.header)
      colorFont(aux.text, palette.body)
      Theme.applyStepFont(aux.text)
    end
    if mainFrame:IsShown() then
      self:RefreshMainWindowLayout()
    end
  end
end

function TG:ToggleUI()
  local mainFrame = State.mainFrame
  if not mainFrame then
    self:InitUI()
    return
  end
  if mainFrame:IsShown() then
    mainFrame:Hide()
    hideChildFrames()
  else
    mainFrame:Show()
    self:UpdateUI()
  end
end

function TG:UpdateUI()
  local mainFrame = State.mainFrame
  if not mainFrame then
    return
  end
  if not State.stepLines[1] then
    State.stepLines[1] = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  end
  if not mainFrame:IsShown() then
    hideChildFrames()
    return
  end
  local function resetStepSize()
    if mainFrame.overflowFrame then
      mainFrame.overflowFrame:Hide()
    end
    clearStepRows()
  end
  local function clearAux()
    if not mainFrame.auxFrames then
      return
    end
    for i = 1, 12 do
      mainFrame.auxFrames[i]:Hide()
      mainFrame.auxFrames[i].text:SetText("")
    end
  end
  local guide = self.currentGuide
  if not guide then
    mainFrame.guideName:SetText("No guide selected. Click Guides.")
    mainFrame.stepHeader:SetText("Current step")
    State.stepLines[1]:SetText("")
    resetStepSize()
    clearAux()
    if TG.HideStepWindows then
      TG:HideStepWindows()
    end
    return
  end
  mainFrame.guideName:SetText((guide.category or "Speedrun") .. " - " .. (guide.name or ""))
  local idx = self.currentStepIndex or 1
  local total = table.getn(guide.steps or {})
  local pct = total > 0 and (idx / total) or 0
  local barWidth = (mainFrame.progressFrame:GetWidth() or 320) - 4
  if barWidth < 1 then
    barWidth = 320
  end
  mainFrame.progressBar:SetWidth(math.max(1, math.floor(barWidth * pct)))
  mainFrame.progressText:SetText(string.format("%d%%", math.floor(pct * 100)))
  if total == 0 then
    mainFrame.stepHeader:SetText("Current step")
    State.stepLines[1]:SetText("")
    resetStepSize()
    clearAux()
    if TG.HideStepWindows then
      TG:HideStepWindows()
    end
    return
  end
  if idx < 1 then
    idx = 1
  end
  if idx > total then
    idx = total
  end
  local currentStep = guide.steps[idx]
  local step = currentStep
  mainFrame.stepHeader:SetText("Current step " .. idx .. " / " .. total)

  local totalGotos, gotoIdx, gotoCounter = 0, 1, 0
  if step then
    local allGotos, descriptiveGotos = 0, 0
    for _, el in ipairs(step.elements or {}) do
      if el.t == "cmd" and el.tag == "goto" then
        allGotos = allGotos + 1
        if el.text and TG.Util.strtrim(el.text) ~= "" then
          descriptiveGotos = descriptiveGotos + 1
        end
      end
    end
    totalGotos = (descriptiveGotos > 0) and descriptiveGotos or allGotos
  end
  if totalGotos > 1 and TG._gotoIndex and step then
    gotoIdx = TG._gotoIndex[tostring(step)] or 1
    if gotoIdx > totalGotos then
      gotoIdx = totalGotos
    end
  end

  local stepIsAux = StepText.isAuxStep(step)
  local entries = {}
  local function addEntry(text, state, el, source)
    if text and text ~= "" then
      table.insert(entries, { text = text, state = state, el = el, source = source })
    end
  end
  if stepIsAux then
    for _, t in ipairs(StepText.auxTextsOfStep(step, true)) do
      addEntry(t, "note")
    end
  elseif step and step.elements then
    local hasNonGoto, hasDescriptiveGoto = false, false
    for _, el in ipairs(step.elements) do
      if el.t == "cmd" and el.tag == "goto" then
        if el.text and TG.Util.strtrim(el.text) ~= "" then
          hasDescriptiveGoto = true
        end
      else
        local t = (el.t == "text" and StepText.hasWarn(el)) and "" or StepText.elToTextNoWarn(el)
        if t and t ~= "" then
          hasNonGoto = true
        end
      end
    end
    for _, el in ipairs(step.elements) do
      if el.t == "cmd" and el.tag == "goto" then
        local descriptive = el.text and TG.Util.strtrim(el.text) ~= ""
        if not ((hasNonGoto or hasDescriptiveGoto) and not descriptive) then
          local txt = StepText.elToText(el)
          if txt and txt ~= "" then
            if totalGotos > 1 then
              gotoCounter = gotoCounter + 1
              if gotoCounter == gotoIdx then
                addEntry(txt .. " |cff888888(" .. gotoIdx .. "/" .. totalGotos .. ")|r", "note")
              end
            else
              addEntry(txt, "note")
            end
          end
        end
      elseif not (el.t == "text" and StepText.hasWarn(el)) then
        local txt = StepText.elToTextNoWarn(el)
        if txt and txt ~= "" then
          local state, source = "note", nil
          if el.t == "cmd" and TG.IsElementTrackable and TG:IsElementTrackable(el) then
            state = self:IsElementDone(el)
            source = TG._tgDoneSource
          end
          addEntry(txt, state, el, source)
        end
      end
    end
  end
  local usedNotesInMain = false
  if table.getn(entries) == 0 and step and step.elements then
    for _, el in ipairs(step.elements) do
      local txt = StepText.elToText(el)
      if txt and txt ~= "" then
        addEntry(txt, "note")
        if StepText.hasWarn(el) then
          usedNotesInMain = true
        end
      end
    end
  end
  if table.getn(entries) == 0 and step then
    addEntry("|cffaaaaaaContinue|r", "note")
  end

  local markerLines = {}
  for i = 1, table.getn(entries) do
    markerLines[i] = StepText.markerText(entries[i])
  end
  State.stepLines[1]:SetText(table.concat(markerLines, "\n\n"))

  local needed = layoutStepRows(entries, math.min(table.getn(entries), MAX_STEP_ROWS))
  if needed < 14 then
    needed = 14
  end
  if mainFrame.scrollContent then
    mainFrame.scrollContent:SetHeight(needed + 8)
  end
  if mainFrame.overflowFrame then
    mainFrame.overflowFrame:Hide()
  end

  local auxGroups, seenAuxBodies, seenSignatures = {}, {}, {}
  local function addAuxGroup(texts, label, signature)
    if not texts or table.getn(texts) == 0 then
      return
    end
    local body = table.concat(texts, "\n\n")
    if seenAuxBodies[body] then
      return
    end
    if signature and seenSignatures[signature] then
      return
    end
    if signature then
      seenSignatures[signature] = true
    end
    seenAuxBodies[body] = true
    table.insert(auxGroups, { label = label or "", texts = texts })
  end
  local auxSteps = TG.GetActiveAuxSteps and TG:GetActiveAuxSteps() or {}
  for _, aux in ipairs(auxSteps) do
    if aux ~= step then
      addAuxGroup(StepText.auxTextsOfStep(aux, true), "", StepText.auxStepSignature(aux))
    end
  end
  if step and not stepIsAux and not usedNotesInMain then
    addAuxGroup(StepText.auxTextsOfStep(step, false), "Notes")
  end

  local overflowFrame = mainFrame.overflowFrame
  local anchor = (overflowFrame and overflowFrame:IsVisible()) and overflowFrame or mainFrame
  for i = 1, 12 do
    local aux = mainFrame.auxFrames[i]
    local group = auxGroups[i]
    if group then
      local body = table.concat(group.texts, "\n\n")
      local labeled = group.label and group.label ~= ""
      aux.text:ClearAllPoints()
      if labeled then
        aux.label:SetText(group.label)
        aux.label:Show()
        aux.text:SetPoint("TOPLEFT", aux.label, "BOTTOMLEFT", 0, -4)
      else
        aux.label:SetText("")
        aux.label:Hide()
        aux.text:SetPoint("TOPLEFT", aux, "TOPLEFT", 12, -10)
      end
      local textWidth = math.max(80, aux:GetWidth() - 24)
      local fontSize = fontOf(aux.text)
      local wrapped, lineCount = TextWrap.wrap("|cffffff00*|r " .. body, textWidth, fontSize)
      aux.text:SetWidth(textWidth)
      aux.text:SetText(wrapped)
      anchorChildFrame(aux, anchor)
      local h = math.max(14, math.ceil(lineCount * TextWrap.lineHeight(fontSize)))
      aux:SetHeight(h + (labeled and 32 or 22))
      aux:Show()
      anchor = aux
    else
      aux:Hide()
    end
  end
  if TG.UpdateStepWindows then
    TG:UpdateStepWindows()
  end
end
