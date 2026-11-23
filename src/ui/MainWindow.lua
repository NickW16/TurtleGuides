-- main guide window and step row rendering
local TG = _G.TurtleGuides
local State = TG.UI.State
local Theme = TG.UI.Theme
local StepText = TG.UI.StepText

local ICON_DONE = "Interface\\Buttons\\UI-CheckBox-Check"
local ICON_PENDING = "Interface\\Buttons\\UI-CheckBox-Up"
local ICON_UNKNOWN = "Interface\\Buttons\\UI-CheckBox-Up"
local ICON_NOTE = "Interface\\Buttons\\WHITE8X8"
local ICON_HIGHLIGHT = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
local COLOR_DONE = { 0.45, 0.85, 0.50 }
local COLOR_UNKNOWN = { 0.58, 0.58, 0.58 }
local ICON_SIZE = 16
local ICON_Y_OFFSET = 1
local STEP_ROW_GAP = 8
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
  local palette = Theme.current()
  if state == "note" or state == "none" then
    row.icon:Show()
    setIconGeometry(row, 4, 4, 6, -6)
    row.icon:SetTexture(ICON_NOTE)
    row.icon:SetVertexColor(1.00, 1.00, 1.00, 0.90)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", STEP_TEXT_X, 0)
    row.text:SetWidth(STEP_TEXT_WIDTH)
    row.text:SetTextColor(unpack(palette.body))
    row.text:SetAlpha(1.00)
    row._tgTip = "Tip / note - not tracked"
  elseif state == true then
    row.icon:Show()
    setIconGeometry(row, ICON_SIZE, ICON_SIZE, 0, ICON_Y_OFFSET)
    row.icon:SetTexture(ICON_DONE)
    row.icon:SetVertexColor(0.40, 1.00, 0.40, 1.00)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", STEP_TEXT_X, 0)
    row.text:SetWidth(STEP_TEXT_WIDTH)
    row.text:SetTextColor(unpack(COLOR_DONE))
    row.text:SetAlpha(0.72)
    if row._tgElement and row._tgElement._tgManualDone then
      row._tgTip = "Completed manually - click to undo"
    else
      row._tgTip = "Completed" .. (row._tgSource and (" (" .. row._tgSource .. ")") or "")
    end
  elseif state == false then
    row.icon:Show()
    setIconGeometry(row, ICON_SIZE, ICON_SIZE, 0, ICON_Y_OFFSET)
    row.icon:SetTexture(ICON_PENDING)
    row.icon:SetVertexColor(1.00, 1.00, 1.00, 1.00)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", STEP_TEXT_X, 0)
    row.text:SetWidth(STEP_TEXT_WIDTH)
    row.text:SetTextColor(unpack(palette.body))
    row.text:SetAlpha(1.00)
    row._tgTip = clickable and "Not completed - click to mark complete" or "Not completed"
  else
    row.icon:Show()
    setIconGeometry(row, ICON_SIZE, ICON_SIZE, 0, ICON_Y_OFFSET)
    row.icon:SetTexture(ICON_UNKNOWN)
    row.icon:SetVertexColor(0.55, 0.55, 0.58, 0.75)
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", STEP_TEXT_X, 0)
    row.text:SetWidth(STEP_TEXT_WIDTH)
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

local function layoutStepRows(entries, limit)
  clearStepRows()
  local mainFrame = State.mainFrame
  if not mainFrame or not mainFrame.stepHeader then
    return 0
  end
  local y, total = -10, 0
  for i = 1, limit do
    local row, entry = State.stepRows[i], entries[i]
    if not row or not entry then
      break
    end
    row._tgElement = entry.el
    row._tgSource = entry.source
    row._tgTrackable = entry.el and TG.IsElementTrackable and TG:IsElementTrackable(entry.el) or false
    row.text:SetText(StepText.stepRowText(entry))
    setStepRowState(row, entry.state)
    row:Show()
    local h = 14
    if row.text.GetStringHeight then
      h = row.text:GetStringHeight() or 14
    end
    if h < 14 then
      h = 14
    end
    if row.icon:IsShown() and row.icon.GetHeight then
      local iconH = row.icon:GetHeight() or 14
      if iconH > h then
        h = iconH
      end
    end
    h = math.ceil(h)
    row:SetHeight(h)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", mainFrame.stepHeader, "BOTTOMLEFT", 0, y)
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
  mainFrame:SetWidth(300)
  mainFrame:SetHeight(250)
  local palette = Theme.current()
  local p = TG.db.frame or { point = "RIGHT", relPoint = "RIGHT", x = -40, y = 0 }
  mainFrame:SetPoint(p.point or "RIGHT", UIParent, p.relPoint or "RIGHT", p.x or -40, p.y or 0)
  mainFrame:SetMovable(true)
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
  end)
  Theme.createBackdrop(mainFrame)

  local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -8)
  title:SetText("TurtleGuides")
  mainFrame.title = title

  local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function()
    mainFrame:Hide()
    hideChildFrames()
  end)
  mainFrame.closeBtn = close

  local guideBtn = CreateFrame("Button", nil, mainFrame)
  guideBtn:SetWidth(22)
  guideBtn:SetHeight(22)
  guideBtn:SetPoint("RIGHT", close, "LEFT", -6, 0)
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
  guideName:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  guideName:SetPoint("RIGHT", mainFrame, "RIGHT", -10, 0)
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
  stepBox:SetHeight(140)
  Theme.createBackdrop(stepBox, palette.panel)
  mainFrame.stepBox = stepBox

  local stepHeader = stepBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  stepHeader:SetPoint("TOPLEFT", stepBox, "TOPLEFT", 12, -8)
  stepHeader:SetTextColor(unpack(palette.header))
  stepHeader:SetPoint("RIGHT", stepBox, "RIGHT", -8, 0)
  stepHeader:SetJustifyH("LEFT")
  stepHeader:SetText("Step")
  mainFrame.stepHeader = stepHeader

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
    local row = CreateFrame("Frame", nil, stepBox)
    row:SetWidth(STEP_ROW_WIDTH)
    row:SetHeight(14)
    row:SetPoint("TOPLEFT", stepHeader, "BOTTOMLEFT", 0, -10)
    local icon = row:CreateTexture(nil, "OVERLAY")
    icon:SetWidth(ICON_SIZE)
    icon:SetHeight(ICON_SIZE)
    icon:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.icon = icon
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", row, "TOPLEFT", STEP_TEXT_X, 0)
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
    checkBtn:SetPoint("TOPLEFT", row, "TOPLEFT", 0, ICON_Y_OFFSET)
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

  local upLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  upLabel:SetPoint("TOPLEFT", stepBox, "BOTTOMLEFT", 0, -2)
  upLabel:SetText("--- Next step ---")
  mainFrame.upLabel = upLabel

  local preview = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  preview:SetPoint("TOPLEFT", upLabel, "BOTTOMLEFT", 0, -1)
  preview:SetWidth(200)
  preview:SetJustifyH("LEFT")
  preview:SetJustifyV("TOP")
  preview:SetText("")
  State.upcomingLines[1] = preview
  for i = 2, 5 do
    State.upcomingLines[i] = preview
  end

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
    colorFont(mainFrame.upLabel, palette.body)
    if mainFrame.upLabel then
      mainFrame.upLabel:SetAlpha(0.50)
    end
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
    for _, fs in ipairs(State.upcomingLines) do
      Theme.applyStepFont(fs)
      colorFont(fs, palette.body)
      if fs then
        fs:SetAlpha(0.55)
      end
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
  if not mainFrame:IsShown() then
    hideChildFrames()
    return
  end
  local function resetStepSize()
    if mainFrame.stepBox then
      mainFrame.stepBox:SetHeight(140)
    end
    mainFrame:SetHeight(250)
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
    mainFrame.stepHeader:SetText("Step")
    State.stepLines[1]:SetText("")
    State.upcomingLines[1]:SetText("")
    resetStepSize()
    clearAux()
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
    mainFrame.stepHeader:SetText("No steps")
    State.stepLines[1]:SetText("")
    State.upcomingLines[1]:SetText("")
    resetStepSize()
    clearAux()
    return
  end
  if idx < 1 then
    idx = 1
  end
  if idx > total then
    idx = total
  end
  mainFrame.stepHeader:SetText("Step " .. idx .. " / " .. total)
  local step = guide.steps[idx]

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

  local nextStep = guide.steps[idx + 1]
  if nextStep then
    local first
    for _, el in ipairs(nextStep.elements or {}) do
      if not (el.t == "cmd" and el.tag == "goto") then
        local t = StepText.elToText(el)
        if t and t ~= "" then
          first = t
          break
        end
      end
    end
    State.upcomingLines[1]:SetText(first or "|cffaaaaaaFollow the arrow|r")
  else
    State.upcomingLines[1]:SetText("Guide complete!")
  end

  local markerLines = {}
  for i = 1, table.getn(entries) do
    markerLines[i] = StepText.markerText(entries[i])
  end
  State.stepLines[1]:SetText(table.concat(markerLines, "\n\n"))

  local BASE_HEIGHT, MIN_BOX = 110, 140
  local needed = layoutStepRows(entries, math.min(table.getn(entries), MAX_STEP_ROWS))
  if needed < 14 then
    needed = 14
  end
  local previewH = 14
  if State.upcomingLines[1].GetStringHeight then
    previewH = State.upcomingLines[1]:GetStringHeight() or 14
  end
  if previewH < 14 then
    previewH = 14
  end
  local previewExtra = math.max(0, math.ceil(previewH) - 28)
  local scale = (mainFrame.GetScale and mainFrame:GetScale()) or 1
  if not scale or scale <= 0 then
    scale = 1
  end
  local screenH = (GetScreenHeight and GetScreenHeight()) or 768
  local maxBox = math.max(MIN_BOX, math.floor((screenH * 0.7 / scale) - BASE_HEIGHT - previewExtra))
  local BOX_PADDING = 52
  local boxH = math.max(MIN_BOX, math.ceil(needed) + BOX_PADDING)
  local needsOverflow = table.getn(entries) > MAX_STEP_ROWS or boxH > maxBox
  local overflow = mainFrame.overflowFrame
  if not needsOverflow then
    mainFrame.stepBox:SetHeight(boxH)
    mainFrame:SetHeight(BASE_HEIGHT + boxH + previewExtra)
    if overflow then
      overflow:Hide()
    end
  elseif overflow then
    local mainCount = math.min(3, table.getn(entries))
    local mainNeeded = layoutStepRows(entries, mainCount)
    if mainNeeded < 14 then
      mainNeeded = 14
    end
    boxH = math.min(maxBox, math.max(MIN_BOX, math.ceil(mainNeeded) + BOX_PADDING))
    mainFrame.stepBox:SetHeight(boxH)
    mainFrame:SetHeight(BASE_HEIGHT + boxH + previewExtra)
    if table.getn(entries) > mainCount then
      local extraLines = {}
      for i = mainCount + 1, table.getn(entries) do
        table.insert(extraLines, markerLines[i])
      end
      overflow.text:SetText(table.concat(extraLines, "\n\n"))
      anchorChildFrame(overflow, mainFrame)
      local oh = overflow.text.GetStringHeight and overflow.text:GetStringHeight() or 14
      if oh < 14 then
        oh = 14
      end
      overflow:SetHeight(math.max(math.ceil(oh) + 32, 40))
      overflow:Show()
    else
      overflow:Hide()
    end
  else
    mainFrame.stepBox:SetHeight(maxBox)
    mainFrame:SetHeight(BASE_HEIGHT + maxBox + previewExtra)
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

  local anchor = (overflow and overflow:IsVisible()) and overflow or mainFrame
  for i = 1, 12 do
    local aux = mainFrame.auxFrames[i]
    local group = auxGroups[i]
    if group then
      local body = table.concat(group.texts, "\n\n")
      if group.label and group.label ~= "" then
        aux.label:SetText(group.label)
        aux.label:Show()
        aux.text:SetPoint("TOPLEFT", aux.label, "BOTTOMLEFT", 0, -4)
      else
        aux.label:SetText("")
        aux.label:Hide()
        aux.text:SetPoint("TOPLEFT", aux, "TOPLEFT", 12, -10)
      end
      aux.text:SetText("|cffffff00*|r " .. body)
      anchorChildFrame(aux, anchor)
      local h = aux.text.GetStringHeight and aux.text:GetStringHeight() or 14
      if h < 14 then
        h = 14
      end
      aux:SetHeight(math.ceil(h) + ((group.label and group.label ~= "") and 32 or 22))
      aux:Show()
      anchor = aux
    else
      aux:Hide()
    end
  end
end
