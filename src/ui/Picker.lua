-- spotlight style guide picker with a custom search field
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local ROW_HEIGHT = 16
local WINDOW_W = 400
local WINDOW_H = 360
local BAR = "Interface\\AddOns\\TurtleGuides\\Media\\BarTexture"
local DOT = "Interface\\Buttons\\WHITE8X8"
local FLIP_W = 10
local SIDEBAR_W = 96
local TITLE_COLOR = { 0.85, 0.85, 0.88 }
local ACTIVE_COLOR = { 0.85, 0.75, 0.40 }

local savedEscape
local escapeBound = false

local function captureEscape(button)
  if escapeBound or not SetBinding or not GetBindingAction then
    return
  end
  local name = button and button.GetName and button:GetName()
  if not name then
    return
  end
  savedEscape = GetBindingAction("ESCAPE")
  if SetBinding("ESCAPE", "CLICK " .. name .. ":LeftButton") ~= false then
    escapeBound = true
  else
    savedEscape = nil
  end
end

local function restoreEscape()
  if not escapeBound then
    return
  end
  if SetBinding then
    SetBinding("ESCAPE", savedEscape or "")
  end
  escapeBound = false
  savedEscape = nil
end

local results = {}
local selected = 1
local collapsed = {}

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

local function applyMenuLayout(picker, sidebarShown)
  local x = sidebarShown and (2 + SIDEBAR_W + 2) or 14
  local width = WINDOW_W - x - 8
  picker.fieldBox:SetPoint("TOPLEFT", picker, "TOPLEFT", x, -32)
  picker.fieldBox:SetWidth(width)
  picker.search:SetWidth(width - 28)
  picker.scroll:SetPoint("TOPLEFT", picker, "TOPLEFT", x, -60)
  picker.content:SetWidth(width)
  for _, row in ipairs(picker.rows or {}) do
    row:SetWidth(width)
  end
  local settings = State.settings
  if settings then
    settings:SetPoint("TOPLEFT", picker, "TOPLEFT", x, -32)
    settings:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -8, 8)
  end
  if picker.sidebar then
    if sidebarShown then
      picker.sidebar:Show()
    else
      picker.sidebar:Hide()
    end
  end
  if picker.flipper then
    picker.flipper:SetPoint("LEFT", picker, "LEFT", sidebarShown and x - FLIP_W or 1, 0)
    if picker.flipper.arrow then
      picker.flipper.arrow:SetTexture(
        sidebarShown and "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronRight_Flat"
          or "Interface\\AddOns\\TurtleGuides\\Media\\NavChevronLeft_Flat"
      )
    end
  end
  picker._sidebarShown = sidebarShown and true or false
end

local function moveSelection(delta)
  local count = table.getn(results)
  if count == 0 then
    selected = 1
    return
  end
  local index = selected
  for _ = 1, count do
    index = index + delta
    if index < 1 then
      index = count
    elseif index > count then
      index = 1
    end
    if results[index].kind == "guide" then
      selected = index
      return
    end
  end
end

local function routeLabel(category, group, guideCategory)
  local source = guideCategory or category or ""
  if source == "Speedrun" then
    return "Fast Route"
  end
  if string.find(source, "Survival", 1, true) then
    return "Safe Route"
  end
  return group or ""
end

local function handleKey(key)
  if key == "UP" then
    moveSelection(-1)
    TG:RefreshGuidePicker()
  elseif key == "DOWN" then
    moveSelection(1)
    TG:RefreshGuidePicker()
  elseif key == "ENTER" then
    TG:LoadPickedGuide(selected)
  elseif key == "ESCAPE" and State.picker then
    TG:HideMenu()
  end
end

function TG:ShowMenu(view)
  if not State.picker then
    self:CreateGuidePicker()
  end
  local picker = State.picker
  local guides = view ~= "settings"
  if not guides and not State.settings then
    self:CreateSettings()
  end
  for _, el in ipairs(picker.guideElements or {}) do
    if guides then
      el:Show()
    else
      el:Hide()
    end
  end
  if State.settings then
    if guides then
      State.settings:Hide()
    else
      State.settings:Show()
    end
  end
  if picker.title then
    picker.title:SetText("TurtleGuides 0.1.0")
  end
  for _, button in ipairs(picker.sidebarButtons or {}) do
    local active = (guides and button.view == "guides") or (not guides and button.view == "settings")
    local color = active and ACTIVE_COLOR or TITLE_COLOR
    button.text:SetTextColor(color[1], color[2], color[3])
  end
  applyMenuLayout(picker, picker._sidebarShown)
  picker:Show()
  captureEscape(picker.close)
  if guides then
    self:RefreshGuidePicker()
  elseif self.RefreshSettings then
    self:RefreshSettings()
  end
end

function TG:HideMenu()
  restoreEscape()
  if State.picker then
    State.picker:Hide()
  end
end

function TG:ShowGuidePicker()
  self:ShowMenu("guides")
end

function TG:ShowSettings()
  self:ShowMenu("settings")
end

function TG:ToggleSidebar()
  local picker = State.picker
  if not picker then
    return
  end
  applyMenuLayout(picker, not picker._sidebarShown)
end

function TG:ToggleSettingsDocked()
  self:ToggleSidebar()
end

function TG:RefreshPickerFlipper()
  local picker = State.picker
  if not picker then
    return
  end
  applyMenuLayout(picker, picker._sidebarShown)
end

local function makePickerRow(picker, i)
  local row = CreateFrame("Button", nil, picker.content)
  row:SetWidth(WINDOW_W - 16)
  row:SetHeight(ROW_HEIGHT)
  row:SetPoint("TOPLEFT", picker.content, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
  local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  text:SetPoint("LEFT", row, "LEFT", 4, 0)
  Text.register(text, 10)
  row.text = text
  local background = row:CreateTexture(nil, "BACKGROUND")
  background:SetTexture("Interface\\Buttons\\WHITE8X8")
  background:SetAllPoints(row)
  row.background = background
  local chevron = row:CreateTexture(nil, "OVERLAY")
  chevron:SetWidth(12)
  chevron:SetHeight(12)
  chevron:SetPoint("LEFT", row, "LEFT", 2, 0)
  chevron:SetVertexColor(0.85, 0.85, 0.88)
  row.chevron = chevron
  row:SetScript("OnClick", function()
    if row.index then
      TG:LoadPickedGuide(row.index)
    elseif row.category then
      collapsed[row.category] = not collapsed[row.category]
      TG:RefreshGuidePicker()
    end
  end)
  row:Hide()
  table.insert(picker.rows, row)
end

local function ensureRows(picker, count)
  while table.getn(picker.rows) < count do
    makePickerRow(picker, table.getn(picker.rows) + 1)
  end
end

function TG:CreateGuidePicker()
  local picker = CreateFrame("Frame", "TurtleGuidesPickerFrame", UIParent)
  State.picker = picker
  picker:SetWidth(WINDOW_W)
  picker:SetHeight(WINDOW_H)
  picker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  picker:SetMovable(true)
  picker:EnableMouse(true)
  picker:RegisterForDrag("LeftButton")
  picker:SetScript("OnDragStart", function()
    if not TG.db.locked then
      this:StartMoving()
    end
  end)
  picker:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
  end)
  panel(picker)
  picker:Hide()

  local topbar = picker:CreateTexture(nil, "BORDER")
  topbar:SetTexture(BAR)
  topbar:SetPoint("TOPLEFT", picker, "TOPLEFT", 1, -1)
  topbar:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -1, -1)
  topbar:SetHeight(20)
  topbar:SetVertexColor(0.92, 0.90, 0.86, 1.00)

  local topbarLine = picker:CreateTexture(nil, "ARTWORK")
  topbarLine:SetTexture(DOT)
  topbarLine:SetPoint("TOPLEFT", picker, "TOPLEFT", 1, -21)
  topbarLine:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -1, -21)
  topbarLine:SetHeight(1)
  topbarLine:SetVertexColor(0.85, 0.85, 0.88, 0.08)

  local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -5)
  title:SetText("TurtleGuides 0.1.0")
  title:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])
  Text.register(title, 12)
  picker.title = title

  local sidebar = CreateFrame("Frame", nil, picker)
  sidebar:SetWidth(SIDEBAR_W)
  sidebar:SetPoint("TOPLEFT", picker, "TOPLEFT", 2, -26)
  sidebar:SetPoint("BOTTOMLEFT", picker, "BOTTOMLEFT", 2, 8)
  sidebar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  sidebar:SetBackdropColor(0.09, 0.09, 0.10, 0.95)
  picker.sidebar = sidebar
  picker._sidebarShown = true
  picker.sidebarButtons = {}

  local function sidebarButton(label, y, view)
    local button = CreateFrame("Button", nil, sidebar)
    button:SetWidth(SIDEBAR_W - 4)
    button:SetHeight(16)
    button:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 2, y)
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", button, "LEFT", 2, 0)
    text:SetText(label)
    text:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])
    Text.register(text, 10)
    button.text = text
    button.view = view
    button:SetScript("OnClick", function()
      TG:ShowMenu(view)
    end)
    table.insert(picker.sidebarButtons, button)
    return button
  end
  sidebarButton("Guides", -4, "guides")
  sidebarButton("Settings", -22, "settings")

  local flipper = CreateFrame("Button", "TurtleGuidesPickerFlipper", picker)
  flipper:SetWidth(FLIP_W)
  flipper:SetHeight(28)
  flipper:SetPoint("LEFT", picker, "LEFT", 1, 0)
  flipper:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 4,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  flipper:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
  flipper:SetBackdropBorderColor(0.40, 0.36, 0.30, 0.90)
  local flipperArrow = flipper:CreateTexture(nil, "ARTWORK")
  flipperArrow:SetWidth(FLIP_W)
  flipperArrow:SetHeight(FLIP_W)
  flipperArrow:SetPoint("CENTER", flipper, "CENTER", 0, 0)
  flipperArrow:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\NavChevronRight_Flat")
  flipper.arrow = flipperArrow
  flipper:SetScript("OnClick", function()
    TG:ToggleSidebar()
  end)
  picker.flipper = flipper

  local close = CreateFrame("Button", "TurtleGuidesMenuCloseButton", picker)
  picker.close = close
  close:SetWidth(12)
  close:SetHeight(12)
  close:SetNormalTexture("Interface\\AddOns\\TurtleGuides\\Media\\Close")
  close:SetPushedTexture("Interface\\AddOns\\TurtleGuides\\Media\\Close")
  local closeIcon = close.GetNormalTexture and close:GetNormalTexture() or nil
  if closeIcon and closeIcon.SetVertexColor then
    closeIcon:SetVertexColor(0.85, 0.85, 0.88)
  end
  close:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -6, -6)
  close:SetScript("OnClick", function()
    TG:HideMenu()
  end)

  local fieldBox = CreateFrame("Frame", nil, picker)
  fieldBox:SetWidth(WINDOW_W - 16)
  fieldBox:SetHeight(22)
  fieldBox:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -32)
  fieldBox:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  fieldBox:SetBackdropColor(0.10, 0.10, 0.10, 0.95)
  picker.fieldBox = fieldBox

  local search = CreateFrame("EditBox", "TurtleGuidesPickerSearch", picker)
  search:SetWidth(WINDOW_W - 44)
  search:SetHeight(18)
  search:SetPoint("TOPLEFT", fieldBox, "TOPLEFT", 16, -2)
  search:SetAutoFocus(false)
  search:SetText("")
  if search.SetTextColor then
    search:SetTextColor(0.95, 0.95, 0.95)
  end
  if search.SetFont then
    Text.register(search, 12)
  end
  search:SetScript("OnTextChanged", function()
    selected = 1
    if TG.RefreshGuidePicker then
      TG:RefreshGuidePicker()
    end
  end)
  search:SetScript("OnKeyDown", function()
    handleKey(arg1)
  end)
  search:SetScript("OnEscapePressed", function()
    TG:HideMenu()
  end)
  search:SetScript("OnEnterPressed", function()
    TG:LoadPickedGuide(selected)
  end)
  picker.search = search

  local placeholder = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  placeholder:SetDrawLayer("OVERLAY", 2)
  placeholder:SetPoint("TOPLEFT", fieldBox, "TOPLEFT", 16, -2)
  placeholder:SetText("Search Guides")
  Text.register(placeholder, 12)
  placeholder:SetTextColor(1.00, 1.00, 1.00, 1.00)
  placeholder:SetAlpha(1.00)
  picker.placeholder = placeholder

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesPickerScroll", picker)
  scroll:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -60)
  scroll:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -8, 8)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(WINDOW_W - 16)
  content:SetHeight(1)
  scroll:SetScrollChild(content)
  picker.scroll = scroll
  picker.content = content
  picker.guideElements = { fieldBox, search, placeholder, scroll }
  picker.scrollbar = TG.UI.Scrollbar.create(scroll, content)

  picker.rows = {}
  for i = 1, 16 do
    makePickerRow(picker, i)
  end
end

function TG:LoadPickedGuide(index)
  local item = results[index]
  if not item or item.kind ~= "guide" then
    return
  end
  local loaded
  if self.SetGuide then
    loaded = self:SetGuide(item.guide.key, 1, false)
  end
  if loaded ~= false and self.FindMyPlace then
    self:FindMyPlace(true)
  end
  if State.settings then
    State.settings:Hide()
  end
  self:HideMenu()
end

function TG:RefreshGuidePicker()
  local picker = State.picker
  if not picker then
    return
  end
  local query = string.lower(picker.search:GetText() or "")
  picker.placeholder:SetText(query == "" and "Search Guides" or "")
  picker.placeholder:SetTextColor(1.00, 1.00, 1.00, 1.00)

  local recommended = {}
  if self.SuggestGuides then
    for _, suggestion in ipairs(self:SuggestGuides() or {}) do
      if suggestion.guide then
        recommended[suggestion.guide.key] = true
      end
    end
  end
  results = {}
  for _, category in ipairs(self:GetGuidesForPicker() or {}) do
    local matches = {}
    for _, guide in ipairs(category.guides or {}) do
      local label = string.lower((guide.group or "") .. " " .. (guide.name or "") .. " " .. (category.name or ""))
      if query == "" or string.find(label, query, 1, true) then
        table.insert(matches, guide)
      end
    end
    if table.getn(matches) > 0 then
      local hidden = (query == "") and collapsed[category.name] and true or false
      table.insert(results, {
        kind = "header",
        label = category.name .. " (" .. table.getn(matches) .. ")",
        category = category.name,
        hidden = hidden,
      })
      if not hidden then
        for _, guide in ipairs(matches) do
          table.insert(results, {
            kind = "guide",
            guide = guide,
            category = category.name,
            rec = recommended[guide.key] and true or false,
          })
        end
      end
    end
  end
  local firstGuide = 0
  for i, item in ipairs(results) do
    if item.kind == "guide" then
      firstGuide = i
      break
    end
  end
  if firstGuide == 0 then
    selected = 1
  elseif selected < firstGuide or selected > table.getn(results) or results[selected].kind ~= "guide" then
    selected = firstGuide
  end

  ensureRows(picker, table.getn(results))
  for i, row in ipairs(picker.rows) do
    local item = results[i]
    if item then
      if item.kind == "header" then
        row.text:SetText(item.label)
        row.text:SetTextColor(0.85, 0.85, 0.88)
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row, "LEFT", 16, 0)
        row.chevron:SetTexture(
          item.hidden and "Interface\\AddOns\\TurtleGuides\\Media\\ChevronDown_Flat"
            or "Interface\\AddOns\\TurtleGuides\\Media\\ChevronUp_Flat"
        )
        row.chevron:Show()
        row.background:SetVertexColor(0.13, 0.13, 0.14, 0.75)
        row.index = nil
        row.category = item.category
      else
        local label = routeLabel(item.category, item.guide.group, item.guide.category)
          .. " - "
          .. (item.guide.name or "")
        row.text:SetText(label)
        if i == selected then
          row.text:SetTextColor(0.85, 0.85, 0.88)
        elseif item.rec then
          row.text:SetTextColor(0.50, 0.78, 0.95)
        else
          row.text:SetTextColor(0.88, 0.88, 0.88)
        end
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row, "LEFT", 16, 0)
        row.chevron:Hide()
        if i == selected then
          row.background:SetVertexColor(0.20, 0.18, 0.12, 0.85)
        elseif math.mod(i, 2) == 0 then
          row.background:SetVertexColor(0.10, 0.10, 0.11, 0.60)
        else
          row.background:SetVertexColor(0.07, 0.07, 0.08, 0.60)
        end
        row.index = i
        row.category = nil
      end
      row:Show()
    else
      row:Hide()
    end
  end
  picker.content:SetHeight(math.max(1, table.getn(results) * ROW_HEIGHT))
  picker.scrollbar:ensure(selected, ROW_HEIGHT)
  picker.scrollbar:update()
end
