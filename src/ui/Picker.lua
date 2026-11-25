-- spotlight style guide picker with a custom search field
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local ROW_HEIGHT = 16

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
  frame:SetBackdropColor(0.04, 0.04, 0.05, 0.95)
  frame:SetBackdropBorderColor(0.28, 0.28, 0.30, 0.90)
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

local function makePickerRow(picker, i)
  local row = CreateFrame("Button", nil, picker.content)
  row:SetWidth(324)
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
  chevron:SetVertexColor(1.00, 0.82, 0.35)
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

  local close = CreateFrame("Button", nil, picker)
  close:SetWidth(9)
  close:SetHeight(9)
  close:SetNormalTexture("Interface\\AddOns\\TurtleGuides\\Media\\Close")
  close:SetPushedTexture("Interface\\AddOns\\TurtleGuides\\Media\\Close")
  local closeIcon = close.GetNormalTexture and close:GetNormalTexture() or nil
  if closeIcon and closeIcon.SetVertexColor then
    closeIcon:SetVertexColor(1.00, 0.82, 0.35)
  end
  close:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -6, -6)
  close:SetScript("OnClick", function()
    picker:Hide()
  end)

  local fieldBox = CreateFrame("Frame", nil, picker)
  fieldBox:SetWidth(324)
  fieldBox:SetHeight(22)
  fieldBox:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -24)
  fieldBox:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  fieldBox:SetBackdropColor(0.10, 0.10, 0.12, 0.95)
  picker.fieldBox = fieldBox

  local search = CreateFrame("EditBox", "TurtleGuidesPickerSearch", picker)
  search:SetWidth(296)
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
    picker:Hide()
  end)
  search:SetScript("OnEnterPressed", function()
    TG:LoadPickedGuide(selected)
  end)
  picker.search = search

  local placeholder = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  placeholder:SetPoint("TOPLEFT", fieldBox, "TOPLEFT", 16, -2)
  placeholder:SetText("Search guides...")
  placeholder:SetTextColor(1.00, 1.00, 1.00)
  Text.register(placeholder, 12)
  picker.placeholder = placeholder

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesPickerScroll", picker)
  scroll:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -52)
  scroll:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -8, 8)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(324)
  content:SetHeight(1)
  scroll:SetScrollChild(content)
  picker.scroll = scroll
  picker.content = content
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
        row.text:SetTextColor(1.00, 0.82, 0.35)
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row, "LEFT", 16, 0)
        row.chevron:SetTexture(
          item.hidden and "Interface\\AddOns\\TurtleGuides\\Media\\ChevronDown"
            or "Interface\\AddOns\\TurtleGuides\\Media\\ChevronUp"
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
          row.text:SetTextColor(1.00, 0.82, 0.35)
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
