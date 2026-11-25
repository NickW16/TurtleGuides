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

local function guideLabel(guide)
  local category = guide.category or ""
  if category == "Speedrun" then
    return "Fast Route"
  end
  if string.find(category, "Survival", 1, true) then
    return "Safe Route"
  end
  return guide.group or "Guide"
end

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
  return math.max(120, (main:GetWidth() or 225) - 13)
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
  local itemIcon = row:CreateTexture(nil, "OVERLAY")
  itemIcon:SetWidth(10)
  itemIcon:SetHeight(10)
  row.itemIcon = itemIcon
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

local function renderRow(row, text, state, el, isHeader, width, icon, iconColor, bulletIcon)
  row.el = el
  row.kind = isHeader and "header" or "task"
  row.trackable = (el and TG.IsElementTrackable and TG:IsElementTrackable(el)) or false
  local x = isHeader and 2 or (bulletIcon and 18 or (icon and 28 or 14))
  local textWidth = math.max(20, width - x - 3)
  local wrapped, lines = Text.wrap(text or "", textWidth, BODY_SIZE)
  row.text:SetWidth(textWidth)
  row.text:SetText(wrapped)
  row.text:ClearAllPoints()
  row.text:SetPoint("TOPLEFT", row, "TOPLEFT", x, -1)
  local height = lines * Text.lineHeight(BODY_SIZE) + 1
  if isHeader then
    row.icon:Hide()
    row.itemIcon:Hide()
    row.check:Hide()
    row.text:SetTextColor(1.00, 0.82, 0.35)
    row.text:SetAlpha(1.00)
    return height
  end
  row.text:SetTextColor(0.90, 0.90, 0.90)
  row.text:SetAlpha(1.00)
  if icon then
    row.itemIcon:Show()
    row.itemIcon:SetTexture(icon)
    local tint = iconColor or { 1.00, 1.00, 1.00 }
    if state == true and not bulletIcon then
      tint = { 0.55, 0.90, 0.55 }
    end
    row.itemIcon:SetVertexColor(unpack(tint))
    row.itemIcon:ClearAllPoints()
    row.itemIcon:SetPoint("TOPLEFT", row, "TOPLEFT", bulletIcon and 3 or 16, -2)
  else
    row.itemIcon:Hide()
  end
  if bulletIcon then
    row.icon:Hide()
    row.check:Show()
    row.check:SetWidth(10)
    row.check:SetHeight(10)
    row.check:ClearAllPoints()
    row.check:SetPoint("TOPLEFT", row, "TOPLEFT", 3, -2)
    return height
  end
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

local function iconButton(parent, texture, label, onClick, size)
  local button = CreateFrame("Button", nil, parent)
  button:SetWidth(size or 14)
  button:SetHeight(size or 14)
  button:SetNormalTexture(texture)
  button:SetPushedTexture(texture)
  local icon = button.GetNormalTexture and button:GetNormalTexture() or nil
  if icon and icon.SetVertexColor then
    icon:SetVertexColor(1.00, 0.82, 0.35, 1.00)
  end
  button:SetScript("OnEnter", function()
    if not GameTooltip then
      return
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetText(label)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
  button:SetScript("OnClick", onClick)
  return button
end

function TG:SetMainWindowMinimized(value)
  local main = State.main
  if not main then
    return
  end
  local minimized = value and true or false
  if minimized == main._tgMinimized then
    return
  end
  local children = { main.scroll, main.resizer }
  if minimized then
    main._tgSavedHeight = main:GetHeight()
    main:SetHeight(36)
    for _, child in ipairs(children) do
      if child then
        child:Hide()
      end
    end
  else
    main:SetHeight(main._tgSavedHeight or 230)
    for _, child in ipairs(children) do
      if child then
        child:Show()
      end
    end
  end
  main._tgMinimized = minimized
  if main.minimizeBtn then
    local texture = minimized and "Interface\\AddOns\\TurtleGuides\\Media\\ChevronDown"
      or "Interface\\AddOns\\TurtleGuides\\Media\\ChevronUp"
    main.minimizeBtn:SetNormalTexture(texture)
    main.minimizeBtn:SetPushedTexture(texture)
    local icon = main.minimizeBtn.GetNormalTexture and main.minimizeBtn:GetNormalTexture() or nil
    if icon and icon.SetVertexColor then
      icon:SetVertexColor(1.00, 0.82, 0.35, 1.00)
    end
  end
  if not minimized then
    self:UpdateUI()
  end
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
  main:SetMinResize(170, 38)
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

  local closeBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\Close", "Hide", function()
    main:Hide()
    if TG.HideStepWindows then
      TG:HideStepWindows()
    end
  end, 10)
  closeBtn:SetPoint("TOPRIGHT", main, "TOPRIGHT", -4, -5)

  local minimizeBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\ChevronUp", "Minimize", function()
    TG:SetMainWindowMinimized(not main._tgMinimized)
  end, 12)
  minimizeBtn:SetPoint("RIGHT", closeBtn, "LEFT", -5, 1)
  main.minimizeBtn = minimizeBtn

  local guidesBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\Magnifier", "Guides", function()
    if TG.ShowGuidePicker then
      TG:ShowGuidePicker()
    end
  end, 12)
  guidesBtn:SetPoint("RIGHT", minimizeBtn, "LEFT", -5, 0)

  local settingsBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\Cog", "Settings", function()
    if TG.ShowSettings then
      TG:ShowSettings()
    end
  end, 12)
  settingsBtn:SetPoint("RIGHT", guidesBtn, "LEFT", -5, 0)
  main.settingsBtn = settingsBtn

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesStepScroll", main)
  scroll:SetPoint("TOPLEFT", main, "TOPLEFT", 5, -19)
  scroll:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -4, 16)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(stepContentWidth(main))
  content:SetHeight(20)
  scroll:SetScrollChild(content)
  main.scroll = scroll
  main.content = content
  main.scrollbar = TG.UI.Scrollbar.create(scroll, content)
  for _ = 1, MAX_ROWS do
    table.insert(rows, makeRow(content))
  end

  local progress = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  progress:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 6, 3)
  progress:SetText("")
  progress:SetTextColor(1.00, 0.82, 0.35)
  Text.register(progress, BODY_SIZE)
  main.progress = progress

  local guideName = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  guideName:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 42, 3)
  guideName:SetPoint("RIGHT", main, "RIGHT", -80, 0)
  guideName:SetJustifyH("LEFT")
  guideName:SetText("")
  guideName:SetTextColor(0.75, 0.75, 0.75)
  Text.register(guideName, BODY_SIZE)
  main.guideName = guideName

  local nextBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\ArrowRight", "Next step", function()
    if TG.NextStep then
      TG:NextStep(true)
    end
  end, 12)
  nextBtn:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -10, 1)
  local prevBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\ArrowLeft", "Previous step", function()
    if TG.PrevStep then
      TG:PrevStep()
    end
  end, 12)
  prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -2, 0)

  local version = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  version:SetPoint("RIGHT", prevBtn, "LEFT", -6, 1)
  version:SetText("tg " .. (TG.version or ""))
  version:SetTextColor(0.62, 0.62, 0.66)
  Text.register(version, 8)
  main.version = version

  local resizer = CreateFrame("Button", nil, main)
  resizer:SetWidth(12)
  resizer:SetHeight(12)
  resizer:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -1, 1)
  resizer.pixels = {}
  for i = 0, 7 do
    local row = resizer:CreateTexture(nil, "OVERLAY")
    row:SetTexture(DOT)
    row:SetWidth(8 - i)
    row:SetHeight(1)
    row:SetPoint("BOTTOMRIGHT", resizer, "BOTTOMRIGHT", 0, i)
    row:SetVertexColor(0.72, 0.72, 0.76, 0.55)
    table.insert(resizer.pixels, row)
  end
  resizer:SetScript("OnEnter", function()
    for _, pixel in ipairs(resizer.pixels) do
      pixel:SetVertexColor(0.90, 0.90, 0.92, 0.85)
    end
  end)
  resizer:SetScript("OnLeave", function()
    for _, pixel in ipairs(resizer.pixels) do
      pixel:SetVertexColor(0.72, 0.72, 0.76, 0.55)
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
  local function layoutFooter()
    local width = (main.progress.GetStringWidth and main.progress:GetStringWidth()) or 24
    main.guideName:ClearAllPoints()
    main.guideName:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 6 + width + 12, 3)
    main.guideName:SetPoint("RIGHT", main, "RIGHT", -80, 0)
  end
  local guide = self.currentGuide
  if not guide then
    main.title:SetText("TurtleGuide")
    main.guideName:SetText("No guide selected")
    main.progress:SetText("")
    layoutFooter()
    self:HideStepWindows()
    for _, row in ipairs(rows) do
      row:Hide()
    end
    return
  end
  local index = self.currentStepIndex or 1
  local steps = guide.steps or {}
  local total = table.getn(steps)
  main.title:SetText((guide.name and guide.name ~= "" and guide.name) or "TurtleGuide")
  main.guideName:SetText(guideLabel(guide))
  main.progress:SetText(index .. "/" .. total)
  layoutFooter()

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
      local rowHeight =
        renderRow(row, entry.text, entry.state, entry.el, false, width, entry.icon, entry.iconColor, entry.bulletIcon)
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
    main.scrollbar:top()
  end
  self._uiStep = index
  main.scrollbar:update()
end

TG.UI.Windows = {
  rows = function()
    return rows
  end,
}
