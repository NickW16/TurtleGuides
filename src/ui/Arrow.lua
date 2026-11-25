-- waypoint arrow frame rendering
local TG = _G.TurtleGuides
local Geometry = TG.Arrow.Geometry
local State = TG.Arrow.State

local SHEET = {
  texture = "Interface\\AddOns\\TurtleGuides\\Media\\Arrow",
  w = 1 / 8,
  h = 1 / 8,
  width = 48,
  height = 48,
}

local DIAL_SHEET = {
  texture = "Interface\\AddOns\\TurtleGuides\\Media\\CompassDial",
  w = 1 / 8,
  h = 1 / 8,
}

local frame, ring, dial, pointer, distText, driver

local function point(dx, dy)
  local facing = GetPlayerFacing and GetPlayerFacing()
  if not facing then
    if pointer then
      pointer:Hide()
    end
    return false
  end
  local rel = Geometry.relative(Geometry.bearing(dx, dy), facing)
  local index = Geometry.cell(rel)
  local col, row = Geometry.cellCoords(index)
  pointer:SetTexCoord(col * SHEET.w, (col + 1) * SHEET.w, row * SHEET.h, (row + 1) * SHEET.h)
  pointer:Show()
  return true
end

local function arrowVisible()
  return frame and State.get() and TG.db and TG.db.showArrow
end

local function updateDial()
  if not arrowVisible() then
    return
  end
  local facing = GetPlayerFacing and GetPlayerFacing()
  if not facing then
    return
  end
  local index = Geometry.cell(-facing)
  local col, row = Geometry.cellCoords(index)
  dial:SetTexCoord(col * DIAL_SHEET.w, (col + 1) * DIAL_SHEET.w, row * DIAL_SHEET.h, (row + 1) * DIAL_SHEET.h)
end

local function updatePointer()
  if not arrowVisible() then
    if frame then
      frame:Hide()
    end
    return
  end
  frame:Show()
  if pointer then
    pointer:Show()
  end
  local dx, dy = State.direction()
  point(dx, dy)
end

local function updateDistance()
  if not arrowVisible() then
    return
  end
  local _, _, yards = State.direction()
  distText:SetText(yards and string.format("%.0f yd", yards) or "~")
end

local function update()
  updateDial()
  updatePointer()
  updateDistance()
end

local function build()
  if frame then
    return
  end
  frame = CreateFrame("Frame", "TurtleGuidesArrow", UIParent)
  frame:SetWidth(220)
  frame:SetHeight(72)
  if not TG.db.arrowFrame then
    TG.db.arrowFrame = {}
  end
  local ap = TG.db.arrowFrame
  frame:SetPoint(ap.point or "TOP", UIParent, ap.relPoint or "TOP", ap.x or 0, ap.y or -110)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function()
    if not TG.db.locked then
      this:StartMoving()
    end
  end)
  frame:SetScript("OnDragStop", function()
    this:StopMovingOrSizing()
    local pointName, _, rel, x, y = this:GetPoint(1)
    ap.point, ap.relPoint, ap.x, ap.y = pointName, rel, x, y
  end)
  frame:SetFrameStrata("MEDIUM")
  frame:SetClampedToScreen(true)

  ring = frame:CreateTexture(nil, "BORDER")
  ring:SetTexture("Interface\\AddOns\\TurtleGuides\\Media\\CompassRing")
  ring:SetWidth(SHEET.width)
  ring:SetHeight(SHEET.height)
  ring:SetPoint("TOP", frame, "TOP", 0, 0)

  dial = frame:CreateTexture(nil, "ARTWORK")
  dial:SetTexture(DIAL_SHEET.texture)
  dial:SetWidth(SHEET.width)
  dial:SetHeight(SHEET.height)
  dial:SetPoint("TOP", frame, "TOP", 0, 0)
  dial:SetTexCoord(0, DIAL_SHEET.w, 0, DIAL_SHEET.h)

  pointer = frame:CreateTexture(nil, "OVERLAY")
  pointer:SetTexture(SHEET.texture)
  pointer:SetWidth(SHEET.width)
  pointer:SetHeight(SHEET.height)
  pointer:SetPoint("TOP", frame, "TOP", 0, 0)
  pointer:SetTexCoord(0, SHEET.w, 0, SHEET.h)

  distText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  distText:SetPoint("TOP", pointer, "BOTTOM", 0, -2)

  frame:Hide()

  driver = CreateFrame("Frame", "TurtleGuidesArrowDriver")
  driver.wait = 0
  driver:SetScript("OnUpdate", function()
    updateDial()
    updatePointer()
    this.wait = this.wait + arg1
    if this.wait < 0.1 then
      return
    end
    this.wait = 0
    updateDistance()
  end)
end

function TG:InitArrow()
  build()
  self:UpdateArrowVisibility()
end

function TG:UpdateArrowVisibility()
  if not frame then
    return
  end
  if TG.db and TG.db.showArrow and State.get() then
    frame:Show()
  else
    frame:Hide()
  end
end

function TG:SetWaypoint(zone, x, y, title, radius)
  State.set(zone, x, y, title, radius)
  if frame then
    TG:UpdateArrowVisibility()
  end
end

function TG:ClearWaypoint()
  State.clear()
  if frame then
    frame:Hide()
  end
end

function TG:GetWaypoint()
  return State.get()
end

function TG:ArrowUpdate()
  if not frame then
    build()
  end
  update()
end
