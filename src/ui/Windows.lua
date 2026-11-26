-- compact native guide windows: small windows hold the current step, the main window holds upcoming steps
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local DOT = "Interface\\Buttons\\WHITE8X8"
local CHECK_ON = { 0.85, 0.75, 0.40 }
local CHECK_OFF = { 0.35, 0.35, 0.37 }
local CLASS_ICONS = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
local CLASS_ICON_COORDS = {
  WARRIOR = { 0, 0.25, 0, 0.25 },
  MAGE = { 0.25, 0.49609375, 0, 0.25 },
  ROGUE = { 0.49609375, 0.7421875, 0, 0.25 },
  DRUID = { 0.7421875, 0.98828125, 0, 0.25 },
  HUNTER = { 0, 0.25, 0.25, 0.5 },
  SHAMAN = { 0.25, 0.49609375, 0.25, 0.5 },
  PRIEST = { 0.49609375, 0.7421875, 0.25, 0.5 },
  WARLOCK = { 0.7421875, 0.98828125, 0.25, 0.5 },
  PALADIN = { 0, 0.25, 0.5, 0.75 },
}
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
  frame:SetBackdropColor(0.06, 0.06, 0.06, alpha or 0.90)
  frame:SetBackdropBorderColor(0.40, 0.36, 0.30, 0.90)
end

local function stepContentWidth(main)
  local barWidth = (main.scrollbar and main.scrollbar.width) or 8
  return math.max(120, (main:GetWidth() or 225) - 9 - barWidth)
end

local function makeRow(parent, size)
  local row = CreateFrame("Frame", nil, parent)
  row.size = size or BODY_SIZE
  row:SetHeight(Text.size(row.size) + 4)
  local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  Text.register(text, row.size)
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
  local contentIcons = {}
  local contentHolders = {}
  for _ = 1, 6 do
    local holder = CreateFrame("Frame", nil, row)
    local contentIcon = holder:CreateTexture(nil, "OVERLAY")
    contentIcon:Hide()
    table.insert(contentIcons, contentIcon)
    table.insert(contentHolders, holder)
  end
  row.contentIcons = contentIcons
  row.contentIconHolders = contentHolders
  row.contentIcon = contentIcons[1]
  local headerLine = row:CreateTexture(nil, "ARTWORK")
  headerLine:SetTexture(DOT)
  headerLine:SetHeight(1)
  headerLine:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
  headerLine:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
  headerLine:SetVertexColor(0.85, 0.85, 0.88, 0.15)
  headerLine:Hide()
  row.headerLine = headerLine
  local stepNum = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  Text.register(stepNum, 9)
  stepNum:SetJustifyH("RIGHT")
  stepNum:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -2, 1)
  stepNum:SetTextColor(0.65, 0.65, 0.70)
  stepNum:Hide()
  row.stepNum = stepNum
  local check = CreateFrame("Button", nil, row)
  check:SetWidth(10)
  check:SetHeight(10)
  check:SetBackdrop({
    bgFile = DOT,
    edgeFile = DOT,
    tile = true,
    tileSize = 4,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  local checkFill = check:CreateTexture(nil, "ARTWORK")
  checkFill:SetTexture(DOT)
  checkFill:SetPoint("TOPLEFT", check, "TOPLEFT", 2, -2)
  checkFill:SetPoint("BOTTOMRIGHT", check, "BOTTOMRIGHT", -2, 2)
  check.fill = checkFill
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

local ICON_MARKER = "\001"

local function renderRow(
  row,
  text,
  state,
  el,
  isHeader,
  width,
  icon,
  iconColor,
  bulletIcon,
  child,
  contentIcon,
  interactive,
  stepNum,
  topLine,
  contentIcons
)
  row.el = el
  row.kind = isHeader and "header" or "task"
  row.trackable = (el and TG.IsElementTrackable and TG:IsElementTrackable(el)) or false
  if stepNum then
    row.stepNum:SetText(tostring(stepNum))
    row.stepNum:Show()
  else
    row.stepNum:Hide()
  end
  local topPad = (topLine and not isHeader) and 2 or 0
  local x = isHeader and 2 or (child and 22 or (bulletIcon and 16 or (icon and 26 or (row.trackable and 16 or 12))))
  local textWidth = math.max(20, width - x - 1 - (stepNum and 18 or 0))
  local anchors = {}
  if contentIcons and not isHeader then
    for _, item in ipairs(contentIcons) do
      table.insert(anchors, item.finish)
    end
  elseif contentIcon and not isHeader then
    local bracket = string.find(text or "", "%[", 1, true)
    local close = bracket and string.find(text or "", "]", bracket, true)
    if close then
      table.insert(anchors, close + 1)
    end
  end
  table.sort(anchors)
  if contentIcons then
    table.sort(contentIcons, function(left, right)
      return left.finish < right.finish
    end)
  end
  local iconSize = Text.size(row.size)
  local iconPad = 3
  local displayText = text or ""
  for index = table.getn(anchors), 1, -1 do
    local anchor = anchors[index]
    displayText = string.sub(displayText, 1, anchor) .. ICON_MARKER .. "      " .. string.sub(displayText, anchor + 1)
  end
  local wrapped, lines = Text.wrap(displayText, textWidth, row.size)
  local placements = {}
  local search = 1
  for _ = 1, table.getn(anchors) do
    local start, finish = string.find(wrapped, ICON_MARKER, search, true)
    if not start then
      break
    end
    local line, lastBreak = 1, 1
    for index = 1, start - 1 do
      if string.sub(wrapped, index, index) == "\n" then
        line = line + 1
        lastBreak = index + 1
      end
    end
    table.insert(placements, {
      line = line,
      prefix = string.sub(wrapped, lastBreak, start - 1),
    })
    search = finish + 1
  end
  local finalText = string.gsub(wrapped, ICON_MARKER, "")
  row.text:SetWidth(textWidth)
  row.text:SetText(finalText)
  row.text:ClearAllPoints()
  row.text:SetPoint("TOPLEFT", row, "TOPLEFT", x, -1 - topPad)
  local measured = (row.text.GetStringHeight and row.text:GetStringHeight()) or 0
  local lineStep = lines > 0 and (measured / lines) or Text.lineHeight(row.size)
  for _, placement in ipairs(placements) do
    placement.x = x + Text.width(placement.prefix, row.size) - 1
    placement.y = -(topPad + (placement.line - 1) * lineStep)
  end
  local height = math.max(measured + 2 + topPad, lines * Text.lineHeight(row.size) + topPad)
  if isHeader then
    row.icon:Hide()
    row.itemIcon:Hide()
    for index, texture in ipairs(row.contentIcons) do
      texture:Hide()
      row.contentIconHolders[index]:Hide()
    end
    row.check:Hide()
    row.headerLine:ClearAllPoints()
    row.headerLine:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.headerLine:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    row.headerLine:Show()
    row.text:SetTextColor(0.58, 0.58, 0.62)
    row.text:SetAlpha(0.90)
    return height
  end
  row.text:SetAlpha(1.00)
  if topLine then
    row.headerLine:ClearAllPoints()
    row.headerLine:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.headerLine:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    row.headerLine:Show()
  else
    row.headerLine:Hide()
  end
  row.text:SetTextColor(0.90, 0.90, 0.90)
  row.text:SetAlpha(1.00)
  local pool = row.contentIcons
  local holders = row.contentIconHolders
  local used = 0
  local function applyIcon(index, texturePath, placement)
    local holder = holders[index]
    local texture = pool[index]
    holder:SetWidth(iconSize + iconPad * 2)
    holder:SetHeight(iconSize + iconPad * 2)
    texture:SetWidth(iconSize)
    texture:SetHeight(iconSize)
    texture:SetTexture(texturePath)
    texture:SetVertexColor(1.00, 1.00, 1.00, 1.00)
    texture:SetPoint("TOPLEFT", holder, "TOPLEFT", iconPad, -iconPad)
    texture:Show()
    holder:Show()
    if placement then
      holder:SetPoint("TOPLEFT", row, "TOPLEFT", placement.x, placement.y)
    end
  end
  if not isHeader then
    for _, item in ipairs(contentIcons or {}) do
      if used < table.getn(pool) then
        used = used + 1
        applyIcon(used, item.texture, placements[used])
      end
    end
    if used == 0 and contentIcon and anchors[1] then
      used = 1
      applyIcon(1, contentIcon, placements[1])
    end
  end
  for index = used + 1, table.getn(pool) do
    pool[index]:Hide()
    holders[index]:Hide()
  end
  if child then
    row.check:Hide()
    row.icon:Hide()
    if icon then
      row.itemIcon:Show()
      row.itemIcon:SetTexture(icon)
      row.itemIcon:SetVertexColor(1.00, 1.00, 1.00, 1.00)
      row.itemIcon:ClearAllPoints()
      row.itemIcon:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -1 - topPad)
    else
      row.itemIcon:Hide()
      row.icon:Show()
      row.icon:SetWidth(3)
      row.icon:SetHeight(3)
      row.icon:ClearAllPoints()
      row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 13, -5 - topPad)
      row.icon:SetTexture(DOT)
      row.icon:SetVertexColor(0.60, 0.60, 0.60, 0.80)
    end
    return height
  end
  if icon then
    row.itemIcon:Show()
    row.itemIcon:SetTexture(icon)
    local tint = iconColor or { 1.00, 1.00, 1.00 }
    if state == true and not bulletIcon then
      tint = { 0.55, 0.90, 0.55 }
    end
    row.itemIcon:SetVertexColor(unpack(tint))
    row.itemIcon:ClearAllPoints()
    row.itemIcon:SetPoint("TOPLEFT", row, "TOPLEFT", bulletIcon and 3 or 16, -1 - topPad)
  else
    row.itemIcon:Hide()
  end
  if bulletIcon then
    row.icon:Hide()
    row.check:Hide()
    return height
  end
  if row.trackable then
    row.icon:Hide()
    if interactive then
      row.check:Show()
    else
      row.check:Hide()
    end
    row.check:SetWidth(10)
    row.check:SetHeight(10)
    row.check:ClearAllPoints()
    row.check:SetPoint("TOPLEFT", row, "TOPLEFT", 3, -1 - topPad)
    if state == true then
      row.check:SetBackdropColor(0.20, 0.28, 0.20, 1)
      row.check:SetBackdropBorderColor(CHECK_ON[1], CHECK_ON[2], CHECK_ON[3], 1)
      row.check.fill:SetVertexColor(CHECK_ON[1], CHECK_ON[2], CHECK_ON[3], 1)
      row.check.fill:Show()
      row.text:SetTextColor(0.55, 0.90, 0.55)
    else
      row.check:SetBackdropColor(0.10, 0.10, 0.10, 1)
      row.check:SetBackdropBorderColor(CHECK_OFF[1], CHECK_OFF[2], CHECK_OFF[3], 1)
      row.check.fill:Hide()
      if state == false then
        row.text:SetTextColor(0.90, 0.90, 0.90)
      else
        row.text:SetTextColor(0.65, 0.65, 0.65)
      end
    end
  else
    row.check:Hide()
    row.icon:Show()
    row.icon:SetWidth(3)
    row.icon:SetHeight(3)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("TOPLEFT", row, "TOPLEFT", 7, -5 - topPad)
    row.icon:SetTexture(DOT)
    row.icon:SetVertexColor(0.60, 0.60, 0.60, 0.80)
  end
  return height
end

local function makeSmallWindow(index)
  local frame = CreateFrame("Frame", "TurtleGuidesStep" .. index, UIParent)
  panel(frame, 0.90)
  frame.size = (index == 1) and (BODY_SIZE + 1) or BODY_SIZE
  local plaque = CreateFrame("Frame", nil, frame)
  plaque:SetHeight(16)
  plaque:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 6, -10)
  panel(plaque, 0.96)
  local borderMask = plaque:CreateTexture(nil, "OVERLAY")
  borderMask:SetTexture(DOT)
  borderMask:SetPoint("BOTTOMLEFT", plaque, "BOTTOMLEFT", 1, 1)
  borderMask:SetPoint("BOTTOMRIGHT", plaque, "BOTTOMRIGHT", -1, 1)
  borderMask:SetHeight(1)
  borderMask:SetVertexColor(0.05, 0.07, 0.11, 1.00)
  local title = plaque:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("LEFT", plaque, "LEFT", 8, 0)
  title:SetTextColor(0.85, 0.85, 0.88)
  Text.register(title, BODY_SIZE)
  frame.title = title
  frame.plaque = plaque
  frame.rows = {}
  for _ = 1, MAX_SMALL_LINES do
    table.insert(frame.rows, makeRow(frame, frame.size))
  end
  frame:Hide()
  return frame
end

local function updateSmallWindow(frame, title, entries, width)
  frame.title:SetText(title)
  frame.plaque:SetWidth(Text.width(title, BODY_SIZE) + 18)
  local y = -10
  local shown = entries
  for i = 1, MAX_SMALL_LINES do
    local row = frame.rows[i]
    local entry = shown[i]
    if entry then
      row:SetWidth(width)
      local height = renderRow(
        row,
        entry.text,
        entry.state,
        entry.el,
        false,
        width,
        entry.icon,
        entry.iconColor,
        entry.bulletIcon,
        entry.child,
        entry.contentIcon,
        true,
        nil,
        nil,
        entry.contentIcons
      )
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, y)
      row:SetHeight(height)
      row:Show()
      y = y - height - ROW_GAP
    else
      row:Hide()
    end
  end
  frame:SetWidth(width)
  frame:SetHeight(4 + math.abs(y))
end

local function iconButton(parent, texture, label, onClick, size)
  local button = CreateFrame("Button", nil, parent)
  button:SetWidth(size or 14)
  button:SetHeight(size or 14)
  button:SetNormalTexture(texture)
  button:SetPushedTexture(texture)
  local icon = button.GetNormalTexture and button:GetNormalTexture() or nil
  if icon and icon.SetVertexColor then
    icon:SetVertexColor(0.82, 0.82, 0.82, 1.00)
  end
  button:SetScript("OnEnter", function()
    if icon and icon.SetVertexColor then
      icon:SetVertexColor(1.00, 1.00, 1.00, 1.00)
    end
    if not GameTooltip then
      return
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetText(label)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function()
    if icon and icon.SetVertexColor then
      icon:SetVertexColor(0.82, 0.82, 0.82, 1.00)
    end
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
    main:SetHeight(40)
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
    local texture = minimized and "Interface\\AddOns\\TurtleGuides\\Media\\ChevronDown_Button"
      or "Interface\\AddOns\\TurtleGuides\\Media\\ChevronUp_Button"
    main.minimizeBtn:SetNormalTexture(texture)
    main.minimizeBtn:SetPushedTexture(texture)
    local icon = main.minimizeBtn.GetNormalTexture and main.minimizeBtn:GetNormalTexture() or nil
    if icon and icon.SetVertexColor then
      icon:SetVertexColor(0.82, 0.82, 0.82, 1.00)
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
  main:SetFrameStrata("MEDIUM")
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
  end)

  local topbar = main:CreateTexture(nil, "BORDER")
  topbar:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\BarTexture")
  topbar:SetPoint("TOPLEFT", main, "TOPLEFT", 1, -1)
  topbar:SetPoint("TOPRIGHT", main, "TOPRIGHT", -1, -1)
  topbar:SetHeight(24)
  topbar:SetVertexColor(0.92, 0.90, 0.86, 1.00)
  main.topbar = topbar

  local topbarLine = main:CreateTexture(nil, "ARTWORK")
  topbarLine:SetTexture(DOT)
  topbarLine:SetPoint("TOPLEFT", main, "TOPLEFT", 1, -25)
  topbarLine:SetPoint("TOPRIGHT", main, "TOPRIGHT", -1, -25)
  topbarLine:SetHeight(1)
  topbarLine:SetVertexColor(0.85, 0.85, 0.88, 0.08)

  local classBtn = CreateFrame("Frame", nil, main)
  classBtn:SetWidth(28)
  classBtn:SetHeight(28)
  classBtn:SetPoint("TOPLEFT", main, "TOPLEFT", 0, 0)
  local classBg = classBtn:CreateTexture(nil, "OVERLAY")
  classBg:SetAllPoints(classBtn)
  classBg:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\SquircleFrame")
  local classIcon = classBtn:CreateTexture(nil, "ARTWORK")
  classIcon:SetPoint("TOPLEFT", classBtn, "TOPLEFT", 3, -3)
  classIcon:SetPoint("BOTTOMRIGHT", classBtn, "BOTTOMRIGHT", -3, 3)
  local classToken
  if UnitClass then
    local _, token = UnitClass("player")
    classToken = token
  end
  local coords = classToken and CLASS_ICON_COORDS[string.upper(classToken)]
  if coords then
    classIcon:SetTexture(CLASS_ICONS)
    classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
  else
    classIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    classIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
  main.classIcon = classIcon
  main.classBtn = classBtn

  local title = main:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", main, "TOPLEFT", 32, -6)
  title:SetPoint("RIGHT", main, "RIGHT", -24, 0)
  title:SetJustifyH("LEFT")
  title:SetText("TurtleGuide")
  title:SetTextColor(0.90, 0.90, 0.92)
  Text.register(title, 12)
  main.title = title

  local minimizeBtn = iconButton(
    main,
    "Interface\\AddOns\\TurtleGuides\\Media\\ChevronUp_Button",
    "Minimize",
    function()
      TG:SetMainWindowMinimized(not (State.main and State.main._tgMinimized))
    end,
    14
  )
  minimizeBtn:SetPoint("TOPRIGHT", main, "TOPRIGHT", -6, -6)
  main.minimizeBtn = minimizeBtn

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesStepScroll", main)
  scroll:SetPoint("TOPLEFT", main, "TOPLEFT", 5, -27)
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

  local footer = main:CreateTexture(nil, "BORDER")
  footer:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\BarTexture")
  footer:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 1, 1)
  footer:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -1, 1)
  footer:SetHeight(16)
  footer:SetVertexColor(0.92, 0.90, 0.86, 1.00)

  local progress = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  progress:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 6, 3)
  progress:SetText("")
  progress:SetTextColor(0.85, 0.85, 0.88)
  Text.register(progress, BODY_SIZE)
  main.progress = progress

  local guideName = main:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  guideName:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 42, 3)
  guideName:SetPoint("RIGHT", main, "RIGHT", -54, 0)
  guideName:SetJustifyH("LEFT")
  guideName:SetText("")
  guideName:SetTextColor(0.75, 0.75, 0.75)
  Text.register(guideName, BODY_SIZE)
  main.guideName = guideName

  local nextBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronRight", "Next step", function()
    if TG.NextStep then
      TG:NextStep(true)
    end
  end, 12)
  nextBtn:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -10, 2)
  local prevBtn = iconButton(main, "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronLeft", "Previous step", function()
    if TG.PrevStep then
      TG:PrevStep()
    end
  end, 12)
  prevBtn:SetPoint("RIGHT", nextBtn, "LEFT", -2, 0)

  local settingsBtn = CreateFrame("Button", nil, main)
  settingsBtn:SetWidth(12)
  settingsBtn:SetHeight(12)
  settingsBtn:SetPoint("RIGHT", prevBtn, "LEFT", -4, 0)
  local settingsIcon = settingsBtn:CreateTexture(nil, "ARTWORK")
  settingsIcon:SetAllPoints(settingsBtn)
  settingsIcon:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\Cog_Filled")
  settingsIcon:SetVertexColor(0.85, 0.75, 0.40)
  settingsBtn:SetScript("OnClick", function()
    if TG.ShowGuidePicker then
      TG:ShowGuidePicker()
    end
  end)
  settingsBtn:SetScript("OnEnter", function()
    settingsIcon:SetVertexColor(1.00, 0.92, 0.55)
    if GameTooltip then
      GameTooltip:SetOwner(settingsBtn, "ANCHOR_RIGHT")
      GameTooltip:SetText("Guides")
      GameTooltip:Show()
    end
  end)
  settingsBtn:SetScript("OnLeave", function()
    settingsIcon:SetVertexColor(0.85, 0.75, 0.40)
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
  main.settingsBtn = settingsBtn

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
    main.guideName:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 6 + width + 8, 3)
    main.guideName:SetPoint("RIGHT", main, "RIGHT", -54, 0)
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
      local gap = 10
      window:ClearAllPoints()
      window:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, gap)
      window:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, gap)
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
    local entries = Text.entries(steps[stepIndex])
    local count = math.min(table.getn(entries), MAX_TASKS)
    if count == 0 then
      count = 1
      entries = { { text = "", state = "note" } }
    end
    if used + count + 1 > MAX_ROWS then
      break
    end
    local headerRow = rows[used + 1]
    used = used + 1
    headerRow:SetWidth(width)
    local headerHeight =
      renderRow(headerRow, "Step " .. stepIndex, nil, nil, true, width, nil, nil, nil, nil, nil, false, nil, false)
    headerRow:ClearAllPoints()
    headerRow:SetPoint("TOPLEFT", main.content, "TOPLEFT", 0, y)
    headerRow:SetHeight(headerHeight)
    headerRow:Show()
    y = y - headerHeight - ROW_GAP
    for i = 1, count do
      local row = rows[used + 1]
      used = used + 1
      local entry = entries[i]
      row:SetWidth(width)
      local rowHeight = renderRow(
        row,
        entry.text,
        entry.state,
        entry.el,
        false,
        width,
        entry.icon,
        entry.iconColor,
        entry.bulletIcon,
        entry.child,
        entry.contentIcon,
        false,
        nil,
        false,
        entry.contentIcons
      )
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
