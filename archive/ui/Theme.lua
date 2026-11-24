-- colour presets and frame styling helpers
local TG = _G.TurtleGuides
local State = TG.UI.State
local Theme = {}
TG.UI.Theme = Theme

local THEMES = {
  modern = {
    name = "Modern",
    bg = { 0.06, 0.07, 0.10, 0.96 },
    panel = { 0.09, 0.11, 0.15, 0.94 },
    progress = { 0.04, 0.05, 0.08, 0.90 },
    border = { 0.16, 0.20, 0.28, 0.95 },
    header = { 0.30, 0.85, 0.90 },
    body = { 0.90, 0.93, 0.98 },
    bar = { 0.25, 0.78, 0.85 },
    accent = { 0.30, 0.85, 0.90 },
  },
  dark = {
    name = "Dark",
    bg = { 0.05, 0.05, 0.12, 0.95 },
    panel = { 0.03, 0.03, 0.08, 0.90 },
    progress = { 0.02, 0.02, 0.06, 0.80 },
    border = { 0.40, 0.40, 0.50, 0.80 },
    header = { 1.00, 0.82, 0.00 },
    body = { 0.95, 0.95, 0.95 },
    bar = { 0.20, 0.80, 0.20 },
  },
  light = {
    name = "Light",
    bg = { 0.20, 0.21, 0.25, 0.76 },
    panel = { 0.26, 0.27, 0.32, 0.80 },
    progress = { 0.16, 0.18, 0.22, 0.76 },
    border = { 0.49, 0.50, 0.57, 0.85 },
    header = { 1.00, 0.87, 0.35 },
    body = { 0.94, 0.94, 0.96 },
    bar = { 0.35, 0.62, 0.38 },
  },
  gold = {
    name = "Gold",
    bg = { 0.08, 0.08, 0.10, 0.95 },
    panel = { 0.12, 0.12, 0.15, 0.92 },
    progress = { 0.06, 0.06, 0.08, 0.85 },
    border = { 0.62, 0.53, 0.32, 0.90 },
    header = { 0.92, 0.80, 0.48 },
    body = { 0.95, 0.93, 0.88 },
    bar = { 0.78, 0.65, 0.32 },
  },
  purple = {
    name = "Purple",
    bg = { 0.09, 0.08, 0.12, 0.95 },
    panel = { 0.13, 0.12, 0.17, 0.92 },
    progress = { 0.07, 0.07, 0.10, 0.85 },
    border = { 0.50, 0.45, 0.58, 0.90 },
    header = { 0.82, 0.75, 0.90 },
    body = { 0.93, 0.92, 0.95 },
    bar = { 0.56, 0.46, 0.72 },
  },
  green = {
    name = "Green",
    bg = { 0.07, 0.10, 0.08, 0.95 },
    panel = { 0.11, 0.14, 0.12, 0.92 },
    progress = { 0.06, 0.08, 0.07, 0.85 },
    border = { 0.42, 0.52, 0.45, 0.90 },
    header = { 0.70, 0.84, 0.72 },
    body = { 0.92, 0.94, 0.92 },
    bar = { 0.38, 0.62, 0.44 },
  },
  lily = {
    name = "Lily",
    bg = { 0.15, 0.07, 0.15, 0.84 },
    panel = { 0.21, 0.10, 0.21, 0.82 },
    progress = { 0.12, 0.05, 0.13, 0.78 },
    border = { 0.92, 0.76, 0.36, 0.92 },
    header = { 1.00, 0.85, 0.45 },
    body = { 1.00, 0.90, 0.97 },
    bar = { 0.92, 0.72, 0.38 },
  },
}
local THEME_ORDER = { "modern", "dark", "light", "gold", "purple", "green", "lily" }

function Theme.current()
  return THEMES[TG.db and TG.db.theme] or THEMES.modern
end

function Theme.accent()
  local palette = Theme.current()
  return palette.accent or palette.header
end

function Theme.scale()
  return tonumber(TG.db and TG.db.uiScale) or 1.0
end

function Theme.createBackdrop(frame, bg, border)
  local palette = Theme.current()
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 8,
    edgeSize = 1,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  frame:SetBackdropColor(unpack(bg or palette.bg))
  frame:SetBackdropBorderColor(unpack(border or palette.border))
end

function Theme.restoreFont(fs)
  if not fs or not fs.GetFont then
    return
  end
  local path, size, flags = fs:GetFont()
  if not path or not size then
    return
  end
  if not fs._tgBaseSize then
    fs._tgBaseSize = size
  end
  fs:SetFont(path, fs._tgBaseSize, flags or "")
end

function Theme.applyStepFont(fs)
  Theme.restoreFont(fs)
  if not fs or not fs.GetFont then
    return
  end
  local path, size, flags = fs:GetFont()
  if not path or not size then
    return
  end
  local scale = tonumber(TG.db and TG.db.textScale) or 1.0
  fs:SetFont(path, math.max(8, math.floor((fs._tgBaseSize or size) * scale + 0.5)), flags or "")
end

local function childAnchorSpec()
  if TG.db and TG.db.frameOrientation == "above" then
    return "BOTTOM", "TOP", 4
  end
  return "TOP", "BOTTOM", -4
end

local function anchorChildFrame(child, anchor)
  if not child or not anchor then
    return
  end
  local point, relPoint, gap = childAnchorSpec()
  child:ClearAllPoints()
  child:SetPoint(point, anchor, relPoint, 0, gap)
end

function TG:ApplyFrameOrientation()
  local mainFrame = State.mainFrame
  if not mainFrame then
    return
  end
  local overflow = mainFrame.overflowFrame
  if overflow then
    anchorChildFrame(overflow, mainFrame)
  end
  local anchor = (overflow and overflow:IsVisible()) and overflow or mainFrame
  for i = 1, 12 do
    local aux = mainFrame.auxFrames and mainFrame.auxFrames[i]
    if aux then
      anchorChildFrame(aux, anchor)
      if aux:IsVisible() then
        anchor = aux
      end
    end
  end
end

function TG:SetFrameOrientation(value)
  if type(value) == "string" then
    value = string.lower(value)
  end
  self.db.frameOrientation = (value == "above" or value == true) and "above" or "below"
  self:ApplyFrameOrientation()
  if self.UpdateUI then
    self:UpdateUI()
  end
  if self.RefreshSettings then
    self:RefreshSettings()
  end
end

Theme.palettes = THEMES
Theme.order = THEME_ORDER
