-- compact native guide picker
local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

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

function TG:ShowGuidePicker()
  if State.settings then
    State.settings:Hide()
  end
  if not State.picker then
    self:CreateGuidePicker()
  end
  self:RefreshGuidePicker()
  State.picker:Show()
end

function TG:CreateGuidePicker()
  local picker = CreateFrame("Frame", "TurtleGuidesPickerFrame", UIParent)
  State.picker = picker
  picker:SetWidth(330)
  picker:SetHeight(360)
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
  panel(picker)
  picker:Hide()

  local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOPLEFT", picker, "TOPLEFT", 6, -6)
  title:SetText("Guides")
  title:SetTextColor(1.00, 0.82, 0.35)
  Text.register(title, 10)

  local close = CreateFrame("Button", nil, picker, "UIPanelCloseButton")
  close:SetWidth(18)
  close:SetHeight(18)
  close:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function()
    picker:Hide()
  end)

  local search = CreateFrame("EditBox", nil, picker, "InputBoxTemplate")
  search:SetWidth(310)
  search:SetHeight(16)
  search:SetPoint("TOPLEFT", picker, "TOPLEFT", 10, -24)
  search:SetAutoFocus(false)
  search:SetText("")
  search:SetScript("OnTextChanged", function()
    if TG.RefreshGuidePicker then
      TG:RefreshGuidePicker()
    end
  end)
  picker.search = search

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesPickerScroll", picker, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -46)
  scroll:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -24, 8)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(290)
  content:SetHeight(1)
  scroll:SetScrollChild(content)
  picker.content = content
  picker.rows = {}
end

function TG:RefreshGuidePicker()
  local picker = State.picker
  if not picker then
    return
  end
  for _, row in ipairs(picker.rows) do
    row:Hide()
  end
  local filter = string.lower(picker.search:GetText() or "")
  local y = -2
  local used = 0
  local function getRow()
    used = used + 1
    local row = picker.rows[used]
    if not row then
      row = CreateFrame("Button", nil, picker.content)
      row:SetWidth(285)
      row:SetHeight(14)
      row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      Text.register(row.text, 10)
      row.text:SetJustifyH("LEFT")
      row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
      picker.rows[used] = row
    end
    return row
  end
  for _, category in ipairs(self:GetGuidesForPicker() or {}) do
    local filtered = {}
    for _, guide in ipairs(category.guides or {}) do
      local label = string.lower((guide.group or "") .. " " .. (guide.name or ""))
      if filter == "" or string.find(label, filter, 1, true) then
        table.insert(filtered, guide)
      end
    end
    if table.getn(filtered) > 0 then
      local header = getRow()
      header:SetPoint("TOPLEFT", picker.content, "TOPLEFT", 0, y)
      header.text:SetText(category.name .. " (" .. table.getn(filtered) .. ")")
      header.text:SetTextColor(1.00, 0.82, 0.35)
      header:SetScript("OnClick", nil)
      header:Show()
      y = y - 14
      for _, guide in ipairs(filtered) do
        local row = getRow()
        row:SetPoint("TOPLEFT", picker.content, "TOPLEFT", 8, y)
        row.text:SetText((guide.group or "") .. " - " .. (guide.name or ""))
        row.text:SetTextColor(0.90, 0.90, 0.90)
        local key = guide.key
        row:SetScript("OnClick", function()
          if key and TG.SetGuide then
            TG:SetGuide(key, 1, false)
          end
          picker:Hide()
        end)
        row:Show()
        y = y - 13
      end
      y = y - 4
    end
  end
  picker.content:SetHeight(math.max(1, math.abs(y) + 4))
end
