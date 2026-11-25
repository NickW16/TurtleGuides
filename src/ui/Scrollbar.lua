-- reusable slim scrollbar for scroll frames
local TG = _G.TurtleGuides
local Scrollbar = {}
TG.UI = TG.UI or {}
TG.UI.Scrollbar = Scrollbar

local TRACK_TEX = "Interface\\AddOns\\TurtleGuides\\Media\\ScrollTrack"
local THUMB_TEX = "Interface\\AddOns\\TurtleGuides\\Media\\ScrollThumb"

local function getOffset(scroll)
  return (scroll.GetVerticalScroll and scroll:GetVerticalScroll()) or 0
end

local function setOffset(scroll, value)
  if scroll.SetVerticalScroll then
    scroll:SetVerticalScroll(value)
  end
end

local function getRange(scroll, content)
  return math.max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
end

function Scrollbar.create(scroll, content, width)
  width = math.max(8, width or 8)
  local btnH = width

  local up = CreateFrame("Button", nil, scroll)
  up:SetWidth(width)
  up:SetHeight(btnH)
  up:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
  local upTex = up:CreateTexture(nil, "ARTWORK")
  upTex:SetAllPoints(up)
  upTex:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\ScrollUp")
  up.tex = upTex
  up:EnableMouse(true)

  local down = CreateFrame("Button", nil, scroll)
  down:SetWidth(width)
  down:SetHeight(btnH)
  down:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
  local downTex = down:CreateTexture(nil, "ARTWORK")
  downTex:SetAllPoints(down)
  downTex:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\ScrollDown")
  down.tex = downTex
  down:EnableMouse(true)

  local track = CreateFrame("Frame", nil, scroll)
  track:SetWidth(width)
  track:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, -btnH)
  track:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, btnH)
  track:SetBackdrop({ bgFile = TRACK_TEX })
  track:SetBackdropColor(1, 1, 1, 1)
  track:EnableMouse(true)

  local thumb = CreateFrame("Frame", nil, scroll)
  thumb:SetWidth(width)
  thumb:SetHeight(22)
  thumb:SetBackdrop({ bgFile = THUMB_TEX })
  thumb:SetBackdropColor(1, 1, 1, 1)
  thumb:EnableMouse(true)
  thumb:SetMovable(true)
  if thumb.SetFrameLevel then
    thumb:SetFrameLevel(scroll:GetFrameLevel() + 2)
  end

  local bar = { scroll = scroll, content = content, track = track, thumb = thumb, width = width, up = up, down = down, btnH = btnH }

  local function trackViewH()
    local h = (scroll:GetHeight() or 0) - (btnH * 2)
    if h < 0 then
      h = 0
    end
    return h
  end

  function bar:update()
    local rawViewH = scroll:GetHeight() or 0
    local contentH = content:GetHeight() or 1
    local viewH = trackViewH()
    if rawViewH > 0 and contentH <= rawViewH then
      setOffset(scroll, 0)
      thumb:Hide()
      up:Hide()
      down:Hide()
      track:Hide()
      return
    end
    up:Show()
    down:Show()
    track:Show()
    thumb:Show()
    local range = math.max(0, contentH - rawViewH)
    local offset = math.max(0, math.min(range, getOffset(scroll)))
    if offset ~= getOffset(scroll) then
      setOffset(scroll, offset)
    end
    local thumbH = math.max(16, math.floor(viewH * viewH / math.max(contentH, 1)))
    if thumbH > viewH then
      thumbH = viewH
    end
    thumb:SetHeight(thumbH)
    local travel = math.max(0, viewH - thumbH)
    local y = -btnH - (range > 0 and (offset / range) * travel or 0)
    thumb:ClearAllPoints()
    thumb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -width, y)
  end

  function bar:page(delta)
    local range = getRange(scroll, content)
    if range <= 0 then
      return
    end
    local offset = math.max(0, math.min(range, getOffset(scroll) - (tonumber(delta) or 0) * 24))
    setOffset(scroll, offset)
    self:update()
  end

  function bar:top()
    setOffset(scroll, 0)
    self:update()
  end

  function bar:ensure(index, rowHeight)
    if getRange(scroll, content) <= 0 then
      return
    end
    local viewH = scroll:GetHeight() or 1
    local top = (index - 1) * rowHeight
    local bottom = top + rowHeight
    local offset = getOffset(scroll)
    if top < offset then
      setOffset(scroll, top)
    elseif bottom > offset + viewH then
      setOffset(scroll, bottom - viewH)
    end
    self:update()
  end

  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnMouseWheel", function()
    bar:page(arg1)
  end)

  up:SetScript("OnClick", function()
    bar:page(1)
  end)
  down:SetScript("OnClick", function()
    bar:page(-1)
  end)

  track:SetScript("OnMouseDown", function()
    if bar.dragging or not GetCursorPosition or not track.GetCenter then
      return
    end
    local scale = track:GetEffectiveScale() or 1
    local _, mouseY = GetCursorPosition()
    local _, thumbY = thumb:GetCenter()
    local height = track:GetHeight() or 1
    local topY = (select(2, track:GetCenter()) or 0) + height / 2
    if math.abs(mouseY / scale - thumbY) <= (thumb:GetHeight() or 22) / 2 + 1 then
      return
    end
    local fraction = math.max(0, math.min(1, (topY - mouseY / scale) / height))
    setOffset(scroll, fraction * getRange(scroll, content))
    bar:update()
  end)

  local function dragUpdate()
    if not GetCursorPosition or not scroll.GetCenter or getRange(scroll, content) <= 0 then
      return
    end
    local scale = scroll:GetEffectiveScale() or 1
    local _, mouseY = GetCursorPosition()
    local viewH = trackViewH()
    local topY = ((select(2, scroll:GetCenter()) or 0) + (scroll:GetHeight() or 0) / 2) - btnH
    local thumbH = thumb:GetHeight() or 22
    local travel = math.max(0, viewH - thumbH)
    local y = math.max(-travel, math.min(0, -(topY - mouseY / scale - thumbH / 2)))
    local range = getRange(scroll, content)
    local offset = (travel > 0) and (-y / travel) * range or 0
    setOffset(scroll, math.max(0, math.min(range, offset)))
    thumb:ClearAllPoints()
    thumb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -width, -btnH + y)
  end
  thumb:SetScript("OnMouseDown", function()
    bar.dragging = true
    dragUpdate()
    thumb:SetScript("OnUpdate", dragUpdate)
  end)
  thumb:SetScript("OnMouseUp", function()
    bar.dragging = nil
    thumb:SetScript("OnUpdate", nil)
  end)
  return bar
end
