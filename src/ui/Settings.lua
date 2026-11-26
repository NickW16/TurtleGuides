local TG = _G.TurtleGuides
local State = TG.UI.State
local Text = TG.UI.Text

local ROW_H = 18
local HEADER_H = 18
local DOT = "Interface\\Buttons\\WHITE8X8"
local TITLE = { 0.85, 0.85, 0.88 }
local MUTED = { 0.72, 0.72, 0.74 }
local ON = { 0.85, 0.75, 0.40 }
local OFF = { 0.35, 0.35, 0.37 }

local function makeCheckbox(parent)
  local box = CreateFrame("Frame", nil, parent)
  box:SetWidth(10)
  box:SetHeight(10)
  box:SetBackdrop({
    bgFile = DOT,
    edgeFile = DOT,
    tile = true,
    tileSize = 4,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
  })
  local fill = box:CreateTexture(nil, "ARTWORK")
  fill:SetTexture(DOT)
  fill:SetPoint("TOPLEFT", box, "TOPLEFT", 2, -2)
  fill:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -2, 2)
  box.fill = fill
  return box
end

function TG:ShowSuggestions()
  self:ShowGuidePicker()
end

function TG:CreateSettings()
  local picker = State.picker
  local frame = CreateFrame("Frame", "TurtleGuidesSettingsFrame", picker)
  State.settings = frame
  frame:SetPoint("TOPLEFT", picker, "TOPLEFT", 8, -32)
  frame:SetPoint("BOTTOMRIGHT", picker, "BOTTOMRIGHT", -8, 24)
  frame:Hide()

  local scroll = CreateFrame("ScrollFrame", "TurtleGuidesSettingsScroll", frame)
  scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(232)
  content:SetHeight(1)
  scroll:SetScrollChild(content)
  frame.scroll = scroll
  frame.content = content
  frame.scrollbar = TG.UI.Scrollbar.create(scroll, content)

  local categories = {
    {
      name = "Display",
      items = {
        { "showArrow", "Show arrow" },
        { "locked", "Lock frames" },
        { "showMinimap", "Show minimap button" },
        { kind = "font" },
      },
    },
    {
      name = "Guide",
      items = {
        { "disableAutoSkip", "Disable auto-skip" },
        {
          "hardcoreMode",
          "Hardcore mode",
          function()
            if TG.currentGuide then
              TG:SetGuide(TG.currentGuide.key, TG.currentStepIndex, true)
            end
          end,
        },
      },
    },
    {
      name = "Automation",
      items = {
        { "autoTurnIn", "Auto accept / turn-in" },
        { "autoSellJunk", "Auto sell junk" },
        { "autoUseQuestItems", "Auto use quest items" },
        { "autoTakeFlight", "Auto flight paths" },
        { "autoBuyVendor", "Auto buy vendor items" },
      },
    },
  }

  frame.rows = {}
  frame.fontRows = {}
  local y = -4

  for _, cat in ipairs(categories) do
    local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", content, "TOPLEFT", 4, y)
    header:SetText(cat.name)
    header:SetTextColor(TITLE[1], TITLE[2], TITLE[3])
    Text.register(header, 10)
    y = y - HEADER_H

    for _, def in ipairs(cat.items) do
      if def.kind == "font" then
        local row = CreateFrame("Frame", nil, content)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 16, y)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", -4, y)
        row:SetHeight(ROW_H)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        label:SetText("Font size")
        label:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
        Text.register(label, 10)

        local function stepButton(anchor, x, text, delta)
          local button = CreateFrame("Button", nil, row)
          button:SetWidth(18)
          button:SetHeight(16)
          button:SetPoint("RIGHT", anchor, "RIGHT", x, 0)
          button:SetBackdrop({
            bgFile = DOT,
            edgeFile = DOT,
            tile = true,
            tileSize = 4,
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
          })
          button:SetBackdropColor(0.12, 0.12, 0.12, 1)
          button:SetBackdropBorderColor(0.40, 0.36, 0.30, 0.90)
          local t = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
          t:SetPoint("CENTER", button, "CENTER", 0, 0)
          t:SetText(text)
          t:SetTextColor(TITLE[1], TITLE[2], TITLE[3])
          Text.register(t, 11)
          button.text = t
          button:SetScript("OnClick", function()
            local current = tonumber(TG.db.fontScale) or 1.0
            TG.db.fontScale = math.max(0.8, math.min(1.4, current + delta))
            if TG.RefreshFonts then
              TG:RefreshFonts()
            end
            TG:RefreshSettings()
          end)
          return button
        end

        local plus = stepButton(row, 0, "+", 0.1)
        local valueBg = CreateFrame("Frame", nil, row)
        valueBg:SetWidth(34)
        valueBg:SetHeight(16)
        valueBg:SetPoint("RIGHT", plus, "LEFT", -2, 0)
        valueBg:SetBackdrop({
          bgFile = DOT,
          edgeFile = DOT,
          tile = true,
          tileSize = 4,
          edgeSize = 1,
          insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        valueBg:SetBackdropColor(0.08, 0.08, 0.08, 1)
        valueBg:SetBackdropBorderColor(0.25, 0.25, 0.27, 1)

        local value = valueBg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        value:SetPoint("CENTER", valueBg, "CENTER", 0, 0)
        value:SetTextColor(ON[1], ON[2], ON[3])
        Text.register(value, 10)
        frame.fontValue = value

        stepButton(valueBg, -36, "-", -0.1)
        table.insert(frame.fontRows, row)
      else
        local row = CreateFrame("Button", nil, content)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 16, y)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", -4, y)
        row:SetHeight(ROW_H)
        local box = makeCheckbox(row)
        box:SetPoint("LEFT", row, "LEFT", 0, 0)
        row.box = box
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", box, "RIGHT", 6, 0)
        text:SetText(def[2])
        text:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
        Text.register(text, 10)
        row.text = text
        row.key = def[1]
        row.label = def[2]
        row.after = def[3]
        row:SetScript("OnClick", function()
          if row._skipToggle then
            row._skipToggle = nil
            return
          end
          if row.swatches then
            for _, swatch in pairs(row.swatches) do
              local mouseIsOver = _G.MouseIsOver
              if (mouseIsOver and mouseIsOver(swatch)) or (swatch.IsMouseOver and swatch:IsMouseOver()) then
                return
              end
            end
          end
          TG.db[row.key] = not TG.db[row.key]
          if row.after then
            row.after()
          end
          TG:RefreshSettings()
        end)
        if def[1] == "showArrow" and TG.ArrowColors then
          row.swatches = {}
          local colors = TG:ArrowColors()
          local x = 0
          for i = table.getn(colors), 1, -1 do
            local c = colors[i]
            local swatch = CreateFrame("Button", nil, row)
            swatch:SetWidth(10)
            swatch:SetHeight(10)
            swatch:SetPoint("RIGHT", row, "RIGHT", x, 0)
            swatch:SetBackdrop({
              bgFile = DOT,
              edgeFile = DOT,
              tile = true,
              tileSize = 4,
              edgeSize = 1,
              insets = { left = 1, right = 1, top = 1, bottom = 1 },
            })
            swatch:SetBackdropColor(c.r, c.g, c.b, 1)
            swatch:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
            swatch.colorKey = c.key
            swatch:SetScript("OnClick", function()
              row._skipToggle = true
              TG.db.arrowColor = c.key
              if TG.ApplyArrowColor then
                TG:ApplyArrowColor()
              end
              TG:RefreshSettings()
            end)
            row.swatches[c.key] = swatch
            x = x - 12
          end
        end
        table.insert(frame.rows, row)
      end
      y = y - ROW_H
    end
    y = y - 4
  end
  content:SetHeight(math.max(1, -y + 4))
  frame.scrollbar:update()
end

function TG:RefreshSettings()
  local frame = State.settings
  if not frame then
    return
  end
  for _, row in ipairs(frame.rows or {}) do
    local enabled = TG.db[row.key] and true or false
    row.checked = enabled
    if row.box then
      if enabled then
        row.box:SetBackdropColor(0.20, 0.28, 0.20, 1)
        row.box:SetBackdropBorderColor(ON[1], ON[2], ON[3], 1)
        row.box.fill:SetVertexColor(ON[1], ON[2], ON[3], 1)
        row.box.fill:Show()
      else
        row.box:SetBackdropColor(0.10, 0.10, 0.10, 1)
        row.box:SetBackdropBorderColor(OFF[1], OFF[2], OFF[3], 1)
        row.box.fill:Hide()
      end
    end
    row.text:SetText(row.label)
    row.text:SetTextColor(enabled and 0.90 or MUTED[1], enabled and 0.92 or MUTED[2], enabled and 0.90 or MUTED[3])
    if row.swatches then
      local selected = TG.db and TG.db.arrowColor or "royal"
      for key, swatch in pairs(row.swatches) do
        if key == selected then
          swatch:SetBackdropBorderColor(1, 1, 1, 1)
        else
          swatch:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
        end
      end
    end
  end
  if frame.fontValue then
    frame.fontValue:SetText(string.format("%.1f", tonumber(TG.db.fontScale) or 1.0))
  end
  if frame.content and frame.GetWidth then
    local width = (frame:GetWidth() or 240) - 8
    if width > 0 then
      frame.content:SetWidth(width)
    end
  end
  if frame.scrollbar then
    frame.scrollbar:update()
  end
end
