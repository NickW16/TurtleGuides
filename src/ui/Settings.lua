-- settings window and guide suggestions
local TG = _G.TurtleGuides
local State = TG.UI.State
local Theme = TG.UI.Theme
local Widgets = TG.UI.Widgets

local function frameOrientationAbove()
  return TG.db and TG.db.frameOrientation == "above"
end

local function selectSettingsTab(name)
  local frame = State.settingsFrame
  if not frame then
    return
  end
  frame.activeTab = name or "General"
  for tabName, button in pairs(frame.tabs or {}) do
    local label = (tabName == frame.activeTab and "|cffffd100" or "|cffffffff") .. tabName .. "|r"
    button:SetText(label)
    if tabName == frame.activeTab and button.LockHighlight then
      button:LockHighlight()
    end
    if tabName ~= frame.activeTab and button.UnlockHighlight then
      button:UnlockHighlight()
    end
  end
  for pageName, page in pairs(frame.pages or {}) do
    if pageName == frame.activeTab then
      page:Show()
    else
      page:Hide()
    end
  end
  if frame.activeTab == "Guides" and TG.RefreshSuggestions then
    TG:RefreshSuggestions()
  end
end

function TG:ShowSettings(tab)
  if State.pickerFrame then
    State.pickerFrame:Hide()
  end
  if not State.settingsFrame then
    self:CreateSettings()
  end
  self:RefreshSettings()
  State.settingsFrame:Show()
  selectSettingsTab(tab or "General")
end

function TG:ShowSuggestions()
  self:ShowSettings("Guides")
end

function TG:CreateSettings()
  local frame = CreateFrame("Frame", "TurtleGuidesSettingsFrame", UIParent)
  State.settingsFrame = frame
  TG.settingsFrame = frame
  frame:SetWidth(460)
  frame:SetHeight(450)
  if not TG.db.settingsFrame then
    TG.db.settingsFrame = {}
  end
  local sp = TG.db.settingsFrame
  frame:SetPoint(sp.point or "CENTER", UIParent, sp.relPoint or "CENTER", sp.x or 60, sp.y or 40)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function()
    if not TG.db.locked then
      frame:StartMoving()
    end
  end)
  frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    local point, _, rel, x, y = frame:GetPoint(1)
    sp.point, sp.relPoint, sp.x, sp.y = point, rel, x, y
  end)
  Theme.createBackdrop(frame)
  frame:Hide()

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -10)
  title:SetText("TurtleGuides Settings")
  frame.title = title

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame.tabs = {}
  frame.pages = {}
  for i, name in ipairs(Widgets.SETTINGS_TABS) do
    local tabName = name
    local tab = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    tab:SetWidth(110)
    tab:SetHeight(22)
    tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 12 + (i - 1) * 116, -38)
    tab:SetText(tabName)
    tab:SetScript("OnClick", function()
      selectSettingsTab(tabName)
    end)
    frame.tabs[tabName] = tab

    local page = CreateFrame("Frame", nil, frame)
    page:SetWidth(436)
    page:SetHeight(350)
    page:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -68)
    Theme.createBackdrop(page, Theme.current().panel)
    page:Hide()
    frame.pages[tabName] = page
  end
  local general, automation, guides = frame.pages.General, frame.pages.Automation, frame.pages.Guides

  frame.cbs = {}
  local function addCheck(parent, y, label, lines, get, set)
    local cb = Widgets.makeCheck(parent, label, 4, y, get, set)
    Widgets.addTooltip(cb, label, lines)
    table.insert(frame.cbs, cb)
    return y - 28
  end

  local y = -8
  y = addCheck(general, y, "Show arrow", {
    "Show the waypoint arrow on steps that have a goto waypoint.",
  }, function()
    return TG.db.showArrow
  end, function(v)
    TG.db.showArrow = v
    if TG.UpdateArrowVisibility then
      TG:UpdateArrowVisibility()
    end
  end)
  y = addCheck(general, y, "Disable auto-skip", {
    "Hold steps for manual Next instead of skipping when a",
    "condition or zone check is definitely false. Unknown state",
    "always holds the step.",
  }, function()
    return TG.db.disableAutoSkip
  end, function(v)
    TG.db.disableAutoSkip = v
  end)
  y = addCheck(general, y, "Lock frames", {
    "Prevent the guide, settings and picker windows from dragging.",
  }, function()
    return TG.db.locked
  end, function(v)
    TG.db.locked = v
  end)
  y = addCheck(general, y, "Show minimap button", {
    "Show or hide the TurtleGuides minimap button.",
  }, function()
    return TG.db.showMinimap
  end, function(v)
    TG.db.showMinimap = v
    if TG.UpdateMinimap then
      TG:UpdateMinimap()
    end
  end)

  y = y - 16
  frame.themeBtn = Widgets.makeButton(general, "Theme: " .. Theme.current().name, 6, y, function()
    local index = 1
    for i, key in ipairs(Theme.order) do
      if key == TG.db.theme then
        index = i
        break
      end
    end
    index = math.mod(index, table.getn(Theme.order)) + 1
    TG.db.theme = Theme.order[index]
    TG:ApplyTheme()
    TG:RefreshSettings()
  end)
  frame.orientationBtn = Widgets.makeButton(
    general,
    frameOrientationAbove() and "Frames: Above" or "Frames: Below",
    162,
    y,
    function()
      TG:SetFrameOrientation(frameOrientationAbove() and "below" or "above")
    end
  )
  Widgets.addTooltip(frame.orientationBtn, "Frame orientation", {
    "Stack the More/notes frames above the guide instead of below it.",
    "The setting is remembered and applies immediately.",
  })
  y = y - 40
  frame.uiSlider = Widgets.makeSlider(general, "UI scale", 8, y, 0.8, 1.4, 0.1, function()
    return Theme.scale()
  end, function(v)
    TG.db.uiScale = v
    TG:ApplyTheme()
    if TG.UpdateUI then
      TG:UpdateUI()
    end
  end)
  y = y - 36
  frame.textSlider = Widgets.makeSlider(general, "Step text", 8, y, 0.8, 1.5, 0.1, function()
    return tonumber(TG.db.textScale) or 1.0
  end, function(v)
    TG.db.textScale = v
    TG:ApplyTheme()
    if TG.UpdateUI then
      TG:UpdateUI()
    end
  end)

  local ay = -8
  ay = addCheck(automation, ay, "Auto accept / turn-in", {
    "Accept and hand in quests when the guide reaches those steps.",
  }, function()
    return TG.db.autoTurnIn
  end, function(v)
    TG.db.autoTurnIn = v
  end)
  frame.autoNote = Widgets.makeNote(
    automation,
    ay,
    "|cffaaaaaaDetected merchant, trainer and flight-master events\n"
      .. "satisfy those steps. Undetected manual-only steps\n"
      .. "still wait for Next.|r"
  )
  ay = ay - 50
  ay = addCheck(automation, ay, "Auto sell junk", {
    "Sell greys and items you marked as junk when a vendor opens.",
  }, function()
    return TG.db.autoSellJunk
  end, function(v)
    TG.db.autoSellJunk = v
  end)
  frame.junkHint = Widgets.makeNote(
    automation,
    ay,
    "|cffaaaaaaMark junk: Ctrl+RightClick or Alt+RightClick\n" .. "an item in your bags. Auto sell is off by default.|r"
  )
  ay = ay - 36
  ay = addCheck(automation, ay, "Hardcore Mode", {
    "Skip death and respawn steps. Toggling this reloads the guide",
    "so step visibility is recalculated immediately.",
  }, function()
    return TG.db.hardcoreMode
  end, function(v)
    TG.db.hardcoreMode = v
    if TG.currentGuide then
      TG:SetGuide(TG.currentGuide.key, TG.currentStepIndex, true)
    end
  end)
  frame.hardcoreHint = Widgets.makeNote(
    automation,
    ay,
    "|cffaaaaaaSkips death and respawn steps. Toggling it reloads\n"
      .. "the guide so step visibility updates immediately.|r"
  )
  ay = ay - 36
  ay = addCheck(automation, ay, "Auto use quest items", {
    "Use quest items from your bags when the guide asks you to.",
  }, function()
    return TG.db.autoUseQuestItems
  end, function(v)
    TG.db.autoUseQuestItems = v
  end)
  ay = addCheck(automation, ay, "Auto flight paths", {
    "Take a flight path when the guide reaches a fly step.",
  }, function()
    return TG.db.autoTakeFlight
  end, function(v)
    TG.db.autoTakeFlight = v
  end)
  addCheck(automation, ay, "Auto buy vendor items", {
    "Buy vendor items named by the current guide step.",
  }, function()
    return TG.db.autoBuyVendor
  end, function(v)
    TG.db.autoBuyVendor = v
  end)

  local gy = -8
  frame.findBtn = Widgets.makeButton(guides, "Find my place", 6, gy, function()
    if TG.FindMyPlace then
      TG:FindMyPlace()
    end
  end)
  frame.findBtn:SetWidth(150)
  Widgets.addTooltip(frame.findBtn, "Find my place", {
    "Puts the current guide back where your quest log says",
    "you are. It stops before any quest you still have",
    "unfinished, and never changes your completion history.",
    "Use Previous if it picks the wrong step.",
  })
  local refreshBtn = Widgets.makeButton(guides, "Refresh", 164, gy, function()
    if TG.RefreshSuggestions then
      TG:RefreshSuggestions()
    end
  end)
  refreshBtn:SetWidth(90)
  Widgets.addTooltip(refreshBtn, "Refresh suggestions", {
    "Recalculate the shortlist from your current level, zone",
    "and quest log.",
  })
  frame.refreshBtn = refreshBtn
  gy = gy - 32
  frame.guideHelp = Widgets.makeNote(
    guides,
    gy,
    "|cffaaaaaaSuggestions use your level, race/class, faction and\n"
      .. "current zone. Click Load to switch; nothing changes\n"
      .. "automatically.|r"
  )
  gy = gy - 50
  frame.suggestStatus = Widgets.makeNote(guides, gy, "")
  gy = gy - 22

  frame.suggestRows = {}
  for _ = 1, 3 do
    local row = CreateFrame("Button", nil, guides)
    row:SetWidth(420)
    row:SetHeight(58)
    row:SetPoint("TOPLEFT", guides, "TOPLEFT", 6, gy)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    local rowTitle = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rowTitle:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -2)
    rowTitle:SetPoint("RIGHT", row, "RIGHT", -58, 0)
    rowTitle:SetJustifyH("LEFT")
    local rowDetail = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rowDetail:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -20)
    rowDetail:SetPoint("RIGHT", row, "RIGHT", -58, 0)
    rowDetail:SetJustifyH("LEFT")
    local load = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    load:SetWidth(50)
    load:SetHeight(20)
    load:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -4)
    load:SetText("Load")
    Widgets.addTooltip(load, "Load this guide", {
      "Load the guide at step 1. Nothing changes until you click.",
    })
    row.title = rowTitle
    row.detail = rowDetail
    row.load = load
    table.insert(frame.suggestRows, row)
    gy = gy - 62
  end
  frame.guideHint =
    Widgets.makeNote(guides, gy, "|cffaaaaaaPrev still works if a suggestion lands on the wrong step.|r")

  selectSettingsTab("General")
  TG:ApplyTheme()
end

function TG:RefreshSuggestions()
  local frame = State.settingsFrame
  if not frame or not frame.suggestRows then
    return
  end
  local list = (self.SuggestGuides and self:SuggestGuides()) or {}
  local level = self.PlayerInfo and self:PlayerInfo().level or (UnitLevel and UnitLevel("player")) or "?"
  if table.getn(list) == 0 then
    frame.suggestStatus:SetText("No suggested guide for level " .. tostring(level) .. ".")
  else
    frame.suggestStatus:SetText("Suggested guides for level " .. tostring(level) .. ":")
  end
  for i, row in ipairs(frame.suggestRows) do
    local suggestion = list[i]
    if not suggestion or not suggestion.guide then
      row:Hide()
    else
      row:Show()
      local guide = suggestion.guide
      row.title:SetText(Widgets.shortText((guide.group or "") .. " - " .. (guide.name or ""), 54))
      local detail = "Levels " .. tostring(suggestion.lo or "?") .. "-" .. tostring(suggestion.hi or "?")
      if suggestion.why and table.getn(suggestion.why) > 0 then
        detail = detail .. ". " .. table.concat(suggestion.why, ", ")
      end
      if guide.key and self.currentGuide and self.currentGuide.key == guide.key then
        detail = detail .. " (current)"
      end
      row.detail:SetText(Widgets.shortText(detail, 66))
      local key = guide.key
      local load = function()
        if key and TG.SetGuide then
          TG:SetGuide(key, 1, false)
        end
        if State.settingsFrame then
          State.settingsFrame:Hide()
        end
      end
      row:SetScript("OnClick", load)
      row.load:SetScript("OnClick", load)
      Widgets.addTooltip(row, "Load suggested guide", {
        "Click to load this guide at step 1.",
        "Nothing changes until you click.",
      })
    end
  end
end

function TG:RefreshSettings()
  local frame = State.settingsFrame
  if not frame then
    return
  end
  for _, cb in ipairs(frame.cbs or {}) do
    if cb._get then
      cb:SetChecked(cb._get() and 1 or 0)
    end
  end
  if frame.themeBtn then
    frame.themeBtn:SetText("Theme: " .. Theme.current().name)
  end
  if frame.orientationBtn then
    frame.orientationBtn:SetText(frameOrientationAbove() and "Frames: Above" or "Frames: Below")
  end
  if frame.uiSlider and frame.uiSlider._refresh then
    frame.uiSlider._refresh()
  end
  if frame.textSlider and frame.textSlider._refresh then
    frame.textSlider._refresh()
  end
  self:RefreshSuggestions()
end
