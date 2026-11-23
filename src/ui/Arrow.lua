-- waypoint arrow frame rendering
local TG = _G.TurtleGuides
local Geometry = TG.Arrow.Geometry
local State = TG.Arrow.State

local SHEET = {
  texture = "Interface\\AddOns\\TurtleGuides\\Media\\Arrow",
  turns = 64,
  perRow = 8,
  w = 1 / 8,
  h = 1 / 8,
  width = 52,
  height = 52,
}

local frame, pointer, titleText, distText, zoneText, driver

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
  pointer:SetVertexColor(Geometry.color(rel))
  pointer:Show()
  return true
end

local function update()
  local waypoint = State.get()
  if not frame or not waypoint or not (TG.db and TG.db.showArrow) then
    if frame then
      frame:Hide()
    end
    return
  end
  frame:Show()
  if titleText then
    titleText:SetText(waypoint.title or "")
  end
  local dx, dy, yards, sameZone = State.direction()
  if zoneText then
    zoneText:SetText(sameZone and "" or (waypoint.zone or ""))
  end
  if distText then
    distText:SetText(yards and string.format("%.0f yd", yards) or "~")
  end
  if pointer then
    pointer:Show()
  end
  point(dx, dy)
end

local function build()
  if frame then
    return
  end
  frame = CreateFrame("Frame", "TurtleGuidesArrow", UIParent)
  frame:SetWidth(220)
  frame:SetHeight(96)
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

  pointer = frame:CreateTexture(nil, "ARTWORK")
  pointer:SetTexture(SHEET.texture)
  pointer:SetWidth(SHEET.width)
  pointer:SetHeight(SHEET.height)
  pointer:SetPoint("TOP", frame, "TOP", 0, 0)
  pointer:SetTexCoord(0, SHEET.w, 0, SHEET.h)

  titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetPoint("TOP", pointer, "BOTTOM", 0, -2)
  titleText:SetWidth(220)

  distText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  distText:SetPoint("TOP", titleText, "BOTTOM", 0, -2)

  zoneText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  zoneText:SetPoint("TOP", distText, "BOTTOM", 0, -2)
  zoneText:SetWidth(200)
  zoneText:SetJustifyH("CENTER")

  frame:Hide()

  driver = CreateFrame("Frame", "TurtleGuidesArrowDriver")
  driver.wait = 0
  driver:SetScript("OnUpdate", function()
    this.wait = this.wait + arg1
    if this.wait < 0.05 then
      return
    end
    this.wait = 0
    update()
  end)
end

function TG:InitArrow()
  build()
  self:AddUpdater("arrow", 0.1, function() end)
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
    if titleText then
      titleText:SetText(State.get() and State.get().title or "")
    end
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
