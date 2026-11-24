-- guide picker window
local TG = _G.TurtleGuides
local State = TG.UI.State
local Theme = TG.UI.Theme

function TG:ShowGuidePicker()
  if State.settingsFrame then
    State.settingsFrame:Hide()
  end
  if not State.pickerFrame then
    self:CreateGuidePicker()
  end
  self:RefreshGuidePicker()
  State.pickerFrame:Show()
end

function TG:CreateGuidePicker()
  local picker = CreateFrame("Frame", "TurtleGuidesPickerFrame", UIParent)
  State.pickerFrame = picker
  picker:SetWidth(420)
  picker:SetHeight(420)
  picker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  picker:SetMovable(true)
  picker:EnableMouse(true)
  picker:RegisterForDrag("LeftButton")
  picker:SetScript("OnDragStart", function()
    this:StartMoving()
  end)
  picker:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
  end)
  Theme.createBackdrop(picker)
  picker:Hide()

  local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", picker, "TOPLEFT", 12, -10)
  title:SetText("Select Guide")
  picker.title = title

  local close = CreateFrame("Button", nil, picker, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function()
    picker:Hide()
  end)

  local searchBox = CreateFrame("EditBox", nil, picker, "InputBoxTemplate")
  searchBox:SetWidth(200)
  searchBox:SetHeight(20)
  searchBox:SetPoint("TOPLEFT", picker, "TOPLEFT", 12, -36)
  searchBox:SetAutoFocus(false)
  searchBox:SetText("")
  searchBox:SetScript("OnTextChanged", function()
    if TG.RefreshGuidePicker then
      TG:RefreshGuidePicker()
    end
  end)
  picker.searchBox = searchBox

  local searchLabel = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  searchLabel:SetPoint("LEFT", searchBox, "RIGHT", 6, 0)
  searchLabel:SetText("Search")
  picker.searchLabel = searchLabel

  local scrollFrame = CreateFrame("ScrollFrame", "TurtleGuidesPickerScroll", picker, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", picker, "TOPLEFT", 12, -60)
  scrollFrame:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -32, 12)
  local content = CreateFrame("Frame", nil, scrollFrame)
  content:SetWidth(360)
  content:SetHeight(1)
  scrollFrame:SetScrollChild(content)
  picker.content = content
  picker.rows = {}
  TG:ApplyTheme()
end

function TG:RefreshGuidePicker()
  local picker = State.pickerFrame
  if not picker then
    return
  end
  local content = picker.content
  for _, row in ipairs(picker.rows) do
    row:Hide()
  end
  local categories = self:GetGuidesForPicker()
  local recommended = {}
  if TG.SuggestGuides then
    for _, suggestion in ipairs(TG:SuggestGuides() or {}) do
      if suggestion.guide then
        recommended[suggestion.guide.key] = true
      end
    end
  end
  local filter = ""
  if picker.searchBox and picker.searchBox.GetText then
    filter = string.lower(picker.searchBox:GetText() or "")
  end
  local y = -2
  local rowIndex = 1
  local function getRow()
    local row = picker.rows[rowIndex]
    if not row then
      row = CreateFrame("Button", nil, content)
      row:SetWidth(350)
      row:SetHeight(18)
      row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      row.text:SetPoint("LEFT", row, "LEFT", 0, 0)
      row.text:SetJustifyH("LEFT")
      row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
      Theme.restoreFont(row.text)
      picker.rows[rowIndex] = row
    end
    rowIndex = rowIndex + 1
    row:Show()
    return row
  end
  for _, category in ipairs(categories) do
    local filtered = {}
    for _, guide in ipairs(category.guides) do
      local label = string.lower((guide.group or "") .. " " .. (guide.name or ""))
      if filter == "" or string.find(label, filter, 1, true) then
        table.insert(filtered, guide)
      end
    end
    if table.getn(filtered) > 0 or filter == "" then
      local header = getRow()
      header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
      header.text:SetText("|cffffd100" .. category.name .. "|r (" .. table.getn(filtered) .. ")")
      header:SetScript("OnClick", nil)
      y = y - 20
      for _, guide in ipairs(filtered) do
        local row = getRow()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 10, y)
        local label = (recommended[guide.key] and "[rec] " or "") .. (guide.group or "") .. " - " .. (guide.name or "")
        row.text:SetText(label)
        local key = guide.key
        row:SetScript("OnClick", function()
          if key and TG.SetGuide then
            TG:SetGuide(key, 1, false)
          end
          if State.pickerFrame then
            State.pickerFrame:Hide()
          end
        end)
        y = y - 18
      end
    end
    y = y - 6
  end
  content:SetHeight(math.abs(y) + 20)
end
