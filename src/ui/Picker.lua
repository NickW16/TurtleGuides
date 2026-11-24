-- spotlight style guide picker with a custom search field
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local MAX_ROWS = 30
local ROW_HEIGHT = 16

local results = {}
local selected = 1

local function panel(frame)
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 4,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  frame:SetBackdropColor(0.04, 0.04, 0.05, 0.95)
  frame:SetBackdropBorderColor(0.28, 0.28, 0.30, 0.90)
end

local function textButton(parent, label, width, onClick)
  local button = CreateFrame("Button", nil, parent)
  button:SetWidth(width)
  button:SetHeight(14)
  local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("CENTER", button, "CENTER", 0, 0)
  text:SetText(label)
  text:SetTextColor(1.00, 0.82, 0.35)
  Text.register(text, 10)
  button:SetScript("OnClick", onClick)
  return button
end

local function handleKey(key)
  if key == "UP" then
    selected = math.max(1, selected - 1)
    TG:RefreshGuidePicker()
  elseif key == "DOWN" then
    selected = math.min(table.getn(results), selected + 1)
    TG:RefreshGuidePicker()
  elseif key == "ENTER" then
    TG:LoadPickedGuide(selected)
  elseif key == "ESCAPE" and State.picker then
    State.picker:Hide()
  end
end

function TG:ShowGuidePicker()
  if State.settings then
    State.settings:Hide()
  end
  if not State.picker then
    self:CreateGuidePicker()
  end
  self:RefreshGuidePicker()
  State.picker:Show()
  if State.picker.search.SetFocus then
    State.picker.search:SetFocus()
  end
end

function TG:CreateGuidePicker()
  local picker = CreateFrame("Frame", "TurtleGuidesPickerFrame", UIParent)
  State.picker = picker
  picker:SetWidth(340)
  picker:SetHeight(272)
  picker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  picker:SetMovable(true)
  if picker.EnableKeyboard then
    picker:EnableKeyboard(true)
  end
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
  picker:SetScript("OnKeyDown", function()
    handleKey(arg1)
  end)
  panel(picker)
  picker:Hide()

  local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -6)
  title:SetText("Guides")
  title:SetTextColor(1.00, 0.82, 0.35)
  Text.register(title, 10)

  local close = textButton(picker, "x", 12, function()
    picker:Hide()
  end)
  close:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -6, -5)

  local fieldBox = CreateFrame("Frame", nil, picker)
  fieldBox:SetWidth(324)
  fieldBox:SetHeight(22)
  fieldBox:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -24)
  fieldBox:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  fieldBox:SetBackdropColor(0.10, 0.10, 0.12, 0.95)
  picker.fieldBox = fieldBox

  local search = CreateFrame("EditBox", "TurtleGuidesPickerSearch", picker)
  search:SetWidth(306)
  search:SetHeight(18)
  search:SetPoint("TOPLEFT", fieldBox, "TOPLEFT", 9, -2)
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
  picker.search = search

  local placeholder = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  placeholder:SetPoint("TOPLEFT", fieldBox, "TOPLEFT", 9, -2)
  placeholder:SetText("Search guides...")
  placeholder:SetTextColor(0.45, 0.45, 0.48)
  Text.register(placeholder, 12)
  picker.placeholder = placeholder

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesPickerScroll", picker)
  scroll:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -52)
  scroll:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -20, 8)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(306)
  content:SetHeight(1)
  scroll:SetScrollChild(content)
  picker.scroll = scroll
  picker.content = content
  picker.scrollbar = TG.UI.Scrollbar.create(scroll, content)

  picker.rows = {}
  for i = 1, MAX_ROWS do
    local row = CreateFrame("Button", nil, content)
    row:SetWidth(306)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", row, "LEFT", 4, 0)
    Text.register(text, 10)
    row.text = text
    local highlight = row:CreateTexture(nil, "BACKGROUND")
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetAllPoints(row)
    highlight:SetAlpha(0.25)
    highlight:Hide()
    row.highlight = highlight
    row:SetScript("OnClick", function()
      TG:LoadPickedGuide(row.index)
    end)
    row:SetScript("OnEnter", function()
      selected = row.index or selected
      TG:RefreshGuidePicker()
    end)
    row:Hide()
    table.insert(picker.rows, row)
  end
end

function TG:LoadPickedGuide(index)
  local item = results[index]
  if not item then
    return
  end
  if self.SetGuide then
    self:SetGuide(item.guide.key, 1, false)
  end
  if State.picker then
    State.picker:Hide()
  end
end

function TG:RefreshGuidePicker()
  local picker = State.picker
  if not picker then
    return
  end
  local query = string.lower(picker.search:GetText() or "")
  picker.placeholder:SetText(query == "" and "Search guides..." or "")

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
    for _, guide in ipairs(category.guides or {}) do
      local label = string.lower((guide.group or "") .. " " .. (guide.name or "") .. " " .. (category.name or ""))
      if query == "" or string.find(label, query, 1, true) then
        table.insert(results, { guide = guide, rec = recommended[guide.key] and true or false })
      end
    end
  end
  table.sort(results, function(a, b)
    if a.rec ~= b.rec then
      return a.rec
    end
    return (a.guide.name or "") < (b.guide.name or "")
  end)
  if table.getn(results) == 0 then
    selected = 1
  elseif selected > table.getn(results) then
    selected = table.getn(results)
  end

  for i, row in ipairs(picker.rows) do
    local item = results[i]
    if item then
      local label = (item.rec and "* " or "") .. (item.guide.group or "") .. " - " .. (item.guide.name or "")
      row.text:SetText(label)
      row.text:SetTextColor(
        i == selected and 1.00 or 0.88,
        i == selected and 0.82 or 0.88,
        i == selected and 0.35 or 0.88
      )
      row.highlight:Show()
      row.index = i
      row:Show()
    else
      row:Hide()
    end
  end
  picker.content:SetHeight(math.max(1, table.getn(results) * ROW_HEIGHT))
  picker.scrollbar:ensure(selected, ROW_HEIGHT)
  picker.scrollbar:update()
end
