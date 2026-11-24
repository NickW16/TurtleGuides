-- reusable slim scrollbar for scroll frames
local TG = _G.TurtleGuides
local Scrollbar = {}
TG.UI = TG.UI or {}
TG.UI.Scrollbar = Scrollbar

local DOT = "Interface\\Buttons\\WHITE8X8"
local TRACK_COLOR = { 0.10, 0.10, 0.11, 1.00 }
local THUMB_COLOR = { 0.55, 0.56, 0.60, 1.00 }

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
  width = width or 8
  local track = CreateFrame("Frame", nil, scroll)
  track:SetWidth(width)
  track:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
  track:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
  track:SetBackdrop({ bgFile = DOT })
  track:SetBackdropColor(unpack(TRACK_COLOR))
  track:EnableMouse(true)

  local thumb = CreateFrame("Frame", nil, scroll)
  thumb:SetWidth(width)
  thumb:SetHeight(22)
  thumb:SetBackdrop({ bgFile = DOT })
  thumb:SetBackdropColor(unpack(THUMB_COLOR))
  thumb:EnableMouse(true)
  thumb:SetMovable(true)
  if thumb.SetFrameLevel then
    thumb:SetFrameLevel(scroll:GetFrameLevel() + 2)
  end

  local bar = { scroll = scroll, content = content, track = track, thumb = thumb, width = width }

  function bar:update()
    local viewH = scroll:GetHeight() or 1
    local contentH = content:GetHeight() or viewH
    local thumbH = math.max(22, math.floor(viewH * viewH / math.max(contentH, 1)))
    if thumbH > viewH then
      thumbH = viewH
    end
    thumb:SetHeight(thumbH)
    local range = getRange(scroll, content)
    local y = (range > 0) and -(getOffset(scroll) / range) * (viewH - thumbH) or 0
    thumb:ClearAllPoints()
    thumb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -width, y)
    thumb:Show()
  end

  function bar:page(delta)
    local range = getRange(scroll, content)
    local offset = math.max(0, math.min(range, getOffset(scroll) - (tonumber(delta) or 0) * 24))
    setOffset(scroll, offset)
    self:update()
  end

  function bar:top()
    setOffset(scroll, 0)
    self:update()
  end

  function bar:ensure(index, rowHeight)
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
    if not GetCursorPosition or not scroll.GetCenter then
      return
    end
    local scale = scroll:GetEffectiveScale() or 1
    local _, mouseY = GetCursorPosition()
    local _, centerY = scroll:GetCenter()
    local viewH = scroll:GetHeight() or 1
    local topY = centerY + viewH / 2
    local thumbH = thumb:GetHeight() or 22
    local travel = math.max(0, viewH - thumbH)
    local y = math.max(-travel, math.min(0, -(topY - mouseY / scale - thumbH / 2)))
    local range = getRange(scroll, content)
    local offset = (travel > 0) and (-y / travel) * range or 0
    setOffset(scroll, math.max(0, math.min(range, offset)))
    thumb:ClearAllPoints()
    thumb:SetPoint("TOPLEFT", scroll, "TOPRIGHT", -width, y)
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
