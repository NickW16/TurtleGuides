-- compact native guide windows: small windows hold the current step, the main window holds upcoming steps
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local BOX = "Interface\\Buttons\\UI-CheckBox-Up"
local CHECK = "Interface\\Buttons\\UI-CheckBox-Check"
local DOT = "Interface\\Buttons\\WHITE8X8"
local BODY_SIZE = 10
local MAX_SMALL = 3
local MAX_SMALL_LINES = 5
local MAX_STEPS = 24
local MAX_TASKS = 6
local MAX_ROWS = 168
local ROW_GAP = 1
local GROUP_GAP = 4

local rows = {}

local function panel(frame, alpha)
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 4,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  frame:SetBackdropColor(0.04, 0.04, 0.05, alpha or 0.85)
  frame:SetBackdropBorderColor(0.28, 0.28, 0.30, 0.90)
end

local function stepContentWidth(main)
  return math.max(120, (main:GetWidth() or 225) - 16)
end

local function makeRow(parent)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(Text.size(BODY_SIZE) + 4)
  local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  Text.register(text, BODY_SIZE)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("TOP")
  if text.SetNonSpaceWrap then
    text:SetNonSpaceWrap(true)
  end
  row.text = text
  local icon = row:CreateTexture(nil, "OVERLAY")
  icon:SetWidth(10)
  icon:SetHeight(10)
  row.icon = icon
  local check = CreateFrame("Button", nil, row)
  check:SetWidth(10)
  check:SetHeight(10)
  check:SetScript("OnClick", function()
    local el = row.el
    if not el or not row.trackable then
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
  row.check = check
  return row
end

local function renderRow(row, text, state, el, isHeader, width)
  row.el = el
  row.kind = isHeader and "header" or "task"
  row.trackable = (el and TG.IsElementTrackable and TG:IsElementTrackable(el)) or false
  local x = isHeader and 2 or 14
  local textWidth = math.max(20, width - x - 3)
  local wrapped, lines = Text.wrap(text or "", textWidth, BODY_SIZE)
  row.text:SetWidth(textWidth)
  row.text:SetText(wrapped)
  row.text:ClearAllPoints()
  row.text:SetPoint("TOPLEFT", row, "TOPLEFT", x, -1)
  local height = lines * Text.lineHeight(BODY_SIZE) + 1
  if isHeader then
    row.icon:Hide()
    row.check:Hide()
    row.text:SetTextColor(1.00, 0.82, 0.35)
    row.text:SetAlpha(1.00)
    return height
  end
  row.text:SetTextColor(0.90, 0.90, 0.90)
  row.text:SetAlpha(1.00)
  if row.trackable then
    row.icon:Show()
    row.icon:SetWidth(10)
    row.icon:SetHeight(10)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 3, -2)
    row.check:Show()
    row.check:SetWidth(10)
    row.check:SetHeight(10)
    row.check:ClearAllPoints()
    row.check:SetPoint("TOPLEFT", row, "TOPLEFT", 3, -2)
    if state == true then
      row.icon:SetTexture(CHECK)
      row.icon:SetVertexColor(0.40, 1.00, 0.40, 1.00)
      row.text:SetTextColor(0.55, 0.90, 0.55)
    elseif state == false then
      row.icon:SetTexture(BOX)
      row.icon:SetVertexColor(1.00, 1.00, 1.00, 1.00)
    else
      row.icon:SetTexture(BOX)
      row.icon:SetVertexColor(0.55, 0.55, 0.58, 0.75)
      row.text:SetTextColor(0.65, 0.65, 0.65)
    end
  else
    row.check:Hide()
    row.icon:Show()
    row.icon:SetWidth(3)
    row.icon:SetHeight(3)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 7, -5)
    row.icon:SetTexture(DOT)
    row.icon:SetVertexColor(0.60, 0.60, 0.60, 0.80)
  end
  return height
end

local function makeSmallWindow(index)
  local frame = CreateFrame("Frame", "TurtleGuidesStep" .. index, UIParent)
  panel(frame, 0.90)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -4)
  title:SetTextColor(1.00, 0.82, 0.35)
  Text.register(title, BODY_SIZE)
  frame.title = title
  local body = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  body:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -15)
  Text.register(body, BODY_SIZE)
  body:SetJustifyH("LEFT")
  body:SetJustifyV("TOP")
  if body.SetNonSpaceWrap then
    body:SetNonSpaceWrap(true)
  end
  body:SetTextColor(0.90, 0.90, 0.90)
  frame.body = body
  frame:Hide()
  return frame
end

local function updateSmallWindow(frame, title, entries, width)
  frame.title:SetText(title)
  local lines, total = {}, 0
  for _, entry in ipairs(entries) do
    if table.getn(lines) >= MAX_SMALL_LINES then
      break
    end
    local marker = entry.state == true and "- [x] " or "- "
    local wrapped, count = Text.wrap(marker .. (entry.text or ""), width - 14, BODY_SIZE)
    table.insert(lines, wrapped)
    total = total + count
  end
  frame.body:SetWidth(width - 10)
  if table.getn(lines) == 0 then
    table.insert(lines, "- Continue")
    total = 1
  end
  frame.body:SetText(table.concat(lines, "\n"))
  frame:SetWidth(width)
  frame:SetHeight(19 + total * Text.lineHeight(BODY_SIZE))
end

local function textButton(parent, label, width, onClick)
  local button = CreateFrame("Button", nil, parent)
  button:SetWidth(width)
  button:SetHeight(14)
  local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("CENTER", button, "CENTER", 0, 0)
  text:SetText(label)
  text:SetTextColor(1.00, 0.82, 0.35)
  Text.register(text, BODY_SIZE)
  button.text = text
  button:SetScript("OnEnter", function()
    text:SetTextColor(1.00, 1.00, 1.00)
  end)
  button:SetScript("OnLeave", function()
    text:SetTextColor(1.00, 0.82, 0.35)
  end)
  button:SetScript("OnClick", onClick)
  return button
end

local function getScrollOffset(scroll)
  return (scroll.GetVerticalScroll and scroll:GetVerticalScroll()) or 0
end

local function setScrollOffset(scroll, value)
  if scroll.SetVerticalScroll then
    scroll:SetVerticalScroll(value)
  end
end

local function scrollRange(scroll, content)
  return math.max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
end

local function updateThumb(main)
  local scroll, content, thumb = main.scroll, main.content, main.thumb
  if not scroll or not content or not thumb then
    return
  end
  local viewH = scroll:GetHeight() or 1
  local contentH = content:GetHeight() or viewH
  local thumbH = math.max(22, math.floor(viewH * viewH / math.max(contentH, 1)))
  if thumbH > viewH then
    thumbH = viewH
  end
  thumb:SetHeight(thumbH)
  local range = math.max(0, contentH - viewH)
  local y = (range > 0) and -(getScrollOffset(scroll) / range) * (viewH - thumbH) or 0
  thumb:ClearAllPoints()
  thumb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -6, y)
end

function TG:InitUI()
  if State.main then
    return
  end
  local main = CreateFrame("Frame", "TurtleGuidesMainFrame", UIParent)
  State.main = main
  panel(main, 0.92)
  local p = TG.db.frame or { point = "RIGHT", relPoint = "RIGHT", x = -40, y = 0, w = 200, h = 230 }
  main:SetWidth(math.min(p.w or 200, 210))
  main:SetHeight(math.min(p.h or 230, 240))
  main:SetPoint(p.point or "RIGHT", UIParent, p.relPoint or "RIGHT", p.x or -40, p.y or 0)
  main:SetMovable(true)
  main:SetResizable(true)
  main:SetMinResize(170, 190)
  main:EnableMouse(true)
  main:RegisterForDrag("LeftButton")
  main:SetScript("OnDragStart", function()
    if not TG.db.locked then
      this:StartMoving()
    end
  end)
  main:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
    local point, _, rel, x, y = this:GetPoint(1)
    TG.db.frame.point, TG.db.frame.relPoint, TG.db.frame.x, TG.db.frame.y = point, rel, x, y
    TG.db.frame.w, TG.db.frame.h = this:GetWidth(), this:GetHeight()
    if TG.RefreshMainWindowLayout then
      TG:RefreshMainWindowLayout()
    end
    if TG.AnchorSettings and State.settings and State.settings:IsShown() then
      TG:AnchorSettings()
    end
  end)

  local title = main:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", main, "TOPLEFT", 6, -4)
  title:SetText("TurtleGuide")
  title:SetTextColor(1.00, 0.82, 0.35)
  Text.register(title, BODY_SIZE)
  main.title = title

  local guidesBtn = textButton(main, "Guides", 34, function()
    if TG.ShowGuidePicker then
      TG:ShowGuidePicker()
    end
  end)
  guidesBtn:SetPoint("TOPRIGHT", main, "TOPRIGHT", -6, -3)
  local settingsBtn = textButton(main, "Settings", 42, function()
    if TG.ShowSettings then
      TG:ShowSettings()
    end
  end)
  settingsBtn:SetPoint("RIGHT", guidesBtn, "LEFT", -8, 0)

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesStepScroll", main)
  scroll:SetPoint("TOPLEFT", main, "TOPLEFT", 5, -19)
  scroll:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -10, 16)
  scroll:EnableMouseWheel(true)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(stepContentWidth(main))
  content:SetHeight(20)
  scroll:SetScrollChild(content)
  scroll:SetScript("OnMouseWheel", function()
    local delta = tonumber(arg1) or 0
    local range = scrollRange(scroll, content)
    local offset = math.max(0, math.min(range, getScrollOffset(scroll) - delta * 24))
    setScrollOffset(scroll, offset)
    updateThumb(main)
  end)
  main.scroll = scroll
  main.content = content

  local track = CreateFrame("Frame", nil, scroll)
  track:SetWidth(6)
  track:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
  track:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
  track:SetBackdrop({ bgFile = DOT })
  track:SetBackdropColor(0.08, 0.08, 0.09, 0.75)
  main.track = track

  local thumb = CreateFrame("Frame", nil, scroll)
  thumb:SetWidth(6)
  thumb:SetHeight(22)
  thumb:SetBackdrop({ bgFile = DOT })
  thumb:SetBackdropColor(0.55, 0.56, 0.60, 0.95)
  thumb:SetMovable(true)
  thumb:RegisterForDrag("LeftButton")
  thumb:SetScript("OnDragStart", function()
    thumb:StartMoving()
    thumb:SetScript("OnUpdate", function()
      local _, _, _, _, y = thumb:GetPoint(1)
      local viewH = scroll:GetHeight() or 1
      local travel = math.max(1, viewH - (thumb:GetHeight() or 22))
      local range = scrollRange(scroll, content)
      if y > 0 then
        thumb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -6, 0)
        setScrollOffset(scroll, 0)
      elseif y < -travel then
        thumb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -6, -travel)
        setScrollOffset(scroll, range)
      else
        setScrollOffset(scroll, (-y / travel) * range)
      end
    end)
  end)
  thumb:SetScript("OnDragStop", function()
    thumb:StopMovingOrSizing()
    thumb:SetScript("OnUpdate", nil)
  end)
  main.thumb = thumb
  for _ = 1, MAX_ROWS do
    table.insert(rows, makeRow(content))
  end

  local progress = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  progress:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 6, 3)
  progress:SetText("")
  progress:SetTextColor(0.75, 0.75, 0.75)
  Text.register(progress, BODY_SIZE)
  main.progress = progress

  local guideName = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  guideName:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 42, 3)
  guideName:SetPoint("RIGHT", main, "RIGHT", -52, 0)
  guideName:SetJustifyH("LEFT")
  guideName:SetText("")
  guideName:SetTextColor(0.75, 0.75, 0.75)
  Text.register(guideName, BODY_SIZE)
  main.guideName = guideName

  local nextBtn = textButton(main, ">", 14, function()
    if TG.NextStep then
      TG:NextStep(true)
    end
  end)
  nextBtn:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -18, 1)
  local prevBtn = textButton(main, "<", 14, function()
    if TG.PrevStep then
      TG:PrevStep()
    end
  end)
  prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -2, 0)

  local resizer = CreateFrame("Button", nil, main)
  resizer:SetWidth(12)
  resizer:SetHeight(12)
  resizer:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -1, 1)
  resizer.pixels = {}
  for line = 0, 1 do
    for i = 0, 3 do
      local pixel = resizer:CreateTexture(nil, "OVERLAY")
      pixel:SetTexture(DOT)
      pixel:SetWidth(2)
      pixel:SetHeight(2)
      pixel:SetPoint("TOPLEFT", resizer, "TOPLEFT", 1 + i * 2 + line * 3, -(11 - i * 2))
      pixel:SetVertexColor(0.78, 0.78, 0.82, 0.70)
      table.insert(resizer.pixels, pixel)
    end
  end
  resizer:SetScript("OnEnter", function()
    for _, pixel in ipairs(resizer.pixels) do
      pixel:SetVertexColor(0.95, 0.95, 0.95, 0.95)
    end
  end)
  resizer:SetScript("OnLeave", function()
    for _, pixel in ipairs(resizer.pixels) do
      pixel:SetVertexColor(0.78, 0.78, 0.82, 0.70)
    end
  end)
  resizer:RegisterForDrag("LeftButton")
  resizer:SetScript("OnDragStart", function()
    if not TG.db.locked then
      main:StartSizing("BOTTOMRIGHT")
    end
  end)
  resizer:SetScript("OnDragStop", function()
    main:StopMovingOrSizing()
    TG.db.frame.w, TG.db.frame.h = main:GetWidth(), main:GetHeight()
    if TG.RefreshMainWindowLayout then
      TG:RefreshMainWindowLayout()
    end
  end)
  main.resizer = resizer

  State.smalls = {}
  for i = 1, MAX_SMALL do
    table.insert(State.smalls, makeSmallWindow(i))
  end

  main:Show()
  TG.mainFrame = main
  self:UpdateUI()
end

function TG:HideStepWindows()
  for _, frame in ipairs(State.smalls) do
    frame:Hide()
  end
end

function TG:UpdateStepWindows()
  if State.main and State.main:IsShown() then
    self:UpdateUI()
  end
end

function TG:RefreshMainWindowLayout()
  local main = State.main
  if not main then
    return
  end
  local width = stepContentWidth(main)
  main.content:SetWidth(width)
  for _, row in ipairs(rows) do
    row:SetWidth(width)
  end
  if main:IsShown() then
    self:UpdateUI()
  end
end

function TG:ToggleUI()
  if not State.main then
    self:InitUI()
    return
  end
  if State.main:IsShown() then
    State.main:Hide()
    self:HideStepWindows()
  else
    State.main:Show()
    self:UpdateUI()
  end
end

function TG:ApplyTheme() end

function TG:RefreshFonts()
  Text.refresh()
  if self.UpdateUI then
    self:UpdateUI()
  end
end

function TG:UpdateUI()
  local main = State.main
  if not main then
    return
  end
  if not main:IsShown() then
    self:HideStepWindows()
    return
  end
  local guide = self.currentGuide
  if not guide then
    main.guideName:SetText("No guide selected")
    main.progress:SetText("")
    self:HideStepWindows()
    for _, row in ipairs(rows) do
      row:Hide()
    end
    return
  end
  local index = self.currentStepIndex or 1
  local steps = guide.steps or {}
  local total = table.getn(steps)
  local label = (guide.category or "Guide") .. " - " .. (guide.name or "")
  local maxChars = math.max(10, math.floor(((main:GetWidth() or 200) - 92) / 5.2))
  if string.len(label) > maxChars then
    label = string.sub(label, 1, math.max(1, maxChars - 3)) .. "..."
  end
  main.guideName:SetText(label)
  main.progress:SetText(index .. "/" .. total)

  local current = steps[index]
  local smallData = { { title = "Step " .. index, entries = Text.entries(current) } }
  local auxSteps = (self.GetActiveAuxSteps and self:GetActiveAuxSteps()) or {}
  for _, aux in ipairs(auxSteps) do
    if aux ~= current and table.getn(smallData) < MAX_SMALL then
      table.insert(smallData, { title = "Extra", entries = Text.entries(aux) })
    end
  end
  local anchor, smallWidth = main, main:GetWidth()
  for i = 1, MAX_SMALL do
    local window = State.smalls[i]
    local data = smallData[i]
    if data then
      updateSmallWindow(window, data.title, data.entries, smallWidth)
      window:ClearAllPoints()
      window:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 2)
      window:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, 2)
      window:Show()
      anchor = window
    else
      window:Hide()
    end
  end

  local width = stepContentWidth(main)
  local used, y = 0, -2
  local last = math.min(total, index + MAX_STEPS)
  for stepIndex = index + 1, last do
    if used + 1 + MAX_TASKS > MAX_ROWS then
      break
    end
    local header = rows[used + 1]
    used = used + 1
    header:SetWidth(width)
    local height = renderRow(header, "Step " .. stepIndex, "note", nil, true, width)
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT", main.content, "TOPLEFT", 0, y)
    header:SetHeight(height)
    header:Show()
    y = y - height - ROW_GAP
    local entries = Text.entries(steps[stepIndex])
    local count = math.min(table.getn(entries), MAX_TASKS)
    for i = 1, count do
      local row = rows[used + 1]
      used = used + 1
      local entry = entries[i]
      row:SetWidth(width)
      local rowHeight = renderRow(row, entry.text, entry.state, entry.el, false, width)
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", main.content, "TOPLEFT", 0, y)
      row:SetHeight(rowHeight)
      row:Show()
      y = y - rowHeight - ROW_GAP
    end
    y = y - (GROUP_GAP - ROW_GAP)
  end
  for i = used + 1, table.getn(rows) do
    rows[i]:Hide()
  end
  main.content:SetHeight(math.max(20, math.abs(y) + 4))
  if self._uiStep ~= index then
    setScrollOffset(main.scroll, 0)
  end
  self._uiStep = index
  updateThumb(main)
end

TG.UI.Windows = {
  rows = function()
    return rows
  end,
}
