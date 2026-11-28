-- marks friendly npcs with star and enemies with skull from the current step
local TG = _G.TurtleGuides

local Marker = {}
TG.TargetMarker = Marker

local STAR = 1
local SKULL = 8

local marks = {}

local function cleanName(name)
  if not name then
    return nil
  end
  name = string.gsub(name, "|c%x%x%x%x%x%x%x%x", "")
  name = string.gsub(name, "|r", "")
  name = string.gsub(name, "^%+", "")
  return name
end

local function addWanted(wanted, name, marker)
  name = cleanName(name)
  if not name or name == "" then
    return
  end
  if wanted[name] == nil or marker == SKULL then
    wanted[name] = marker
  end
end

local function wantedTargets(step)
  local wanted = {}
  if not step then
    return wanted
  end
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and el.sourceTag == "target" then
      addWanted(wanted, el.args and el.args[1], STAR)
    end
    local text = el.text
    if text then
      for name in string.gmatch(text, "|cRXP_FRIENDLY_([^|]+)|r") do
        addWanted(wanted, name, STAR)
      end
      for name in string.gmatch(text, "|cRXP_ENEMY_([^|]+)|r") do
        addWanted(wanted, name, SKULL)
      end
    end
  end
  return wanted
end

local function unitName(token)
  if not _G.UnitExists or not _G.UnitExists(token) then
    return nil
  end
  return cleanName(_G.UnitName and _G.UnitName(token))
end

local function raidIndex(token)
  return _G.GetRaidTargetIndex and _G.GetRaidTargetIndex(token) or nil
end

local function clearToken(token)
  local mark = marks[token]
  if not mark then
    return
  end
  if _G.SetRaidTarget and _G.UnitExists and _G.UnitExists(token) then
    if raidIndex(token) == mark.marker then
      _G.SetRaidTarget(token, 0)
    end
  end
  marks[token] = nil
end

local function clearMarks()
  local tokens = {}
  for token in pairs(marks) do
    table.insert(tokens, token)
  end
  for _, token in ipairs(tokens) do
    clearToken(token)
  end
end

local function nameplates()
  local api = _G.C_NamePlate
  if not api or type(api.GetNamePlates) ~= "function" then
    return nil
  end
  return api.GetNamePlates()
end

local function canMark(token)
  if not token then
    return false
  end
  if _G.UnitIsDead and _G.UnitIsDead(token) then
    return false
  end
  if _G.UnitIsPlayer and _G.UnitIsPlayer(token) then
    return false
  end
  if _G.UnitIsUnit and _G.UnitIsUnit(token, "pet") then
    return false
  end
  return true
end

function Marker.scan()
  local wanted = wantedTargets(TG.CurrentStep and TG:CurrentStep())
  if next(wanted) == nil then
    clearMarks()
    return
  end

  for token, mark in pairs(marks) do
    local current = unitName(token)
    if current ~= mark.name or wanted[current] ~= mark.marker or raidIndex(token) ~= mark.marker then
      clearToken(token)
    end
  end

  local claimed = {}
  for token, mark in pairs(marks) do
    claimed[mark.name] = token
  end

  local tokens = {}
  local seen = {}
  local function addToken(token)
    if token and not seen[token] then
      seen[token] = true
      table.insert(tokens, token)
    end
  end

  local plates = nameplates()
  if plates then
    for _, plate in ipairs(plates) do
      addToken(plate.namePlateUnitToken)
    end
  end
  if _G.UnitExists then
    if _G.UnitExists("target") then
      addToken("target")
    end
    if _G.UnitExists("mouseover") then
      addToken("mouseover")
    end
  end

  for _, token in ipairs(tokens) do
    local name = unitName(token)
    local marker = name and wanted[name]
    if marker and not claimed[name] and not marks[token] and not raidIndex(token) and canMark(token) then
      if _G.SetRaidTarget then
        _G.SetRaidTarget(token, marker)
        marks[token] = { name = name, marker = marker }
        claimed[name] = token
      end
    end
  end
end

function Marker.findToken(name)
  local want = cleanName(name)
  if not want then
    return nil
  end
  local tokens = {}
  local seen = {}
  local function addToken(token)
    if token and not seen[token] then
      seen[token] = true
      table.insert(tokens, token)
    end
  end
  local plates = nameplates()
  if plates then
    for _, plate in ipairs(plates) do
      addToken(plate.namePlateUnitToken)
    end
  end
  if _G.UnitExists then
    if _G.UnitExists("target") then
      addToken("target")
    end
    if _G.UnitExists("mouseover") then
      addToken("mouseover")
    end
  end
  for _, token in ipairs(tokens) do
    local current = unitName(token)
    if current and cleanName(current) == want then
      return token
    end
  end
  return nil
end

function Marker.reset()
  clearMarks()
end

TG:AddUpdater("npcMarker", 0.25, function()
  Marker.scan()
end)

local lastEventScan = 0
local function scanFromEvent()
  if not _G.GetTime then
    Marker.scan()
    return
  end
  local now = _G.GetTime()
  if now - lastEventScan < 0.05 then
    return
  end
  lastEventScan = now
  Marker.scan()
end

TG:RegisterEvent("NAME_PLATE_UNIT_ADDED", scanFromEvent)
TG:RegisterEvent("PLAYER_TARGET_CHANGED", scanFromEvent)

Marker.wantedTargets = wantedTargets
