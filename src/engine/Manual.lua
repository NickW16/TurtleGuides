-- manual action signals and auto-advance holds
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local Manual = {}
TG.Engine.Manual = Manual

local HEARTHSTONE_ITEM_ID = 6948
local HEARTHSTONE_SPELL_IDS = { [8690] = true, [556] = true }
local HEARTHSTONE_SPELL_NAMES = { "Hearthstone", "Astral Recall" }
local HEARTHSTONE_MIN_COOLDOWN = 300

function TG:IsHearthstoneSpell(id)
  return HEARTHSTONE_SPELL_IDS[tonumber(id)] == true
end

local function cleanBindText(s)
  s = (TG.stripCodes and TG.stripCodes(s)) or tostring(s or "")
  s = string.gsub(s, "^%s*(.-)%s*$", "%1")
  return s
end

local function bindPlaceFromElement(el)
  local text = cleanBindText(el and el.text)
  local _, _, where = string.find(text, " to (.+)$")
  if not where or where == "" then
    return nil
  end
  local stop = string.find(where, " if ", 1, true)
  if stop then
    where = string.sub(where, 1, stop - 1)
  end
  where = string.gsub(where, "^%s*(.-)%s*[%.!%?]*%s*$", "%1")
  if where == "" then
    return nil
  end
  return string.lower(where)
end

local function samePlace(a, b)
  if not a or not b then
    return false
  end
  a, b = string.lower(a), string.lower(b)
  if a == b then
    return true
  end
  if string.len(a) > 3 and string.len(b) > 3 then
    return string.find(a, b, 1, true) ~= nil or string.find(b, a, 1, true) ~= nil
  end
  return false
end

function TG:StepHasManualAction(step)
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and Shared.MANUAL_ACTION_TAGS[el.tag] then
      return true, el.tag
    end
  end
  return false
end

function TG:CurrentBindLocation()
  if not GetBindLocation then
    return nil
  end
  local bind = GetBindLocation()
  if not bind or bind == "" then
    return nil
  end
  return bind
end

local function hearthstoneCooldown()
  local now = GetTime and GetTime() or 0
  local start, duration

  if GetItemCooldown then
    local ok, itemStart, itemDuration = pcall(GetItemCooldown, HEARTHSTONE_ITEM_ID)
    if ok and itemStart and itemDuration and itemDuration >= HEARTHSTONE_MIN_COOLDOWN
      and (itemStart + itemDuration) > now then
      start, duration = itemStart, itemDuration
    end
  end

  if not start and GetSpellCooldown then
    for _, spell in ipairs(HEARTHSTONE_SPELL_NAMES) do
      local ok, spellStart, spellDuration = pcall(GetSpellCooldown, spell)
      if ok and spellStart and spellDuration and spellDuration >= HEARTHSTONE_MIN_COOLDOWN
        and (spellStart + spellDuration) > now then
        start, duration = spellStart, spellDuration
        break
      end
    end
    if not start then
      for id in pairs(HEARTHSTONE_SPELL_IDS) do
        local ok, spellStart, spellDuration = pcall(GetSpellCooldown, id)
        if ok and spellStart and spellDuration and spellDuration >= HEARTHSTONE_MIN_COOLDOWN
          and (spellStart + spellDuration) > now then
          start, duration = spellStart, spellDuration
          break
        end
      end
    end
  end

  if not start then
    return nil
  end
  return start, duration
end

local function cooldownKey(start, duration)
  if not start then
    return "none"
  end
  return tostring(math.floor(start * 100)) .. ":" .. tostring(math.floor(duration))
end

function TG:SignalHearthstoneUse()
  local step = self:CurrentStep()
  if not step then
    return false
  end
  if not self._manualSignals then
    self._manualSignals = {}
  end
  local stepKey = tostring(step)
  local hsKey = stepKey .. ":hs"
  local hearthKey = stepKey .. ":hearth"
  if self._manualSignals[hsKey] and self._manualSignals[hearthKey] then
    return false
  end
  self._manualSignals[hsKey] = true
  self._manualSignals[hearthKey] = true
  self._wasStepComplete = nil
  if self.InvalidateStepCompletionCache then
    self:InvalidateStepCompletionCache(step)
  end
  if self.CheckAdvance then
    self:CheckAdvance("event")
  end
  return true
end

function TG:PollHearthstoneUse()
  local start, duration = hearthstoneCooldown()
  local key = cooldownKey(start, duration)
  if self._hearthCooldownKey == nil then
    self._hearthCooldownKey = key
    return false
  end
  if key == self._hearthCooldownKey then
    return false
  end
  self._hearthCooldownKey = key
  if not start then
    return false
  end
  return self:SignalHearthstoneUse()
end

function TG:ResetManualSignals()
  self._manualSignals = {}
  self._bindBaseline = self:CurrentBindLocation()
  self._bindSignal = nil
  local start, duration = hearthstoneCooldown()
  self._hearthCooldownKey = start and cooldownKey(start, duration) or nil
end

function TG:PollBindLocation()
  local bind = self:CurrentBindLocation()
  if not bind then
    return
  end
  if self._bindBaseline == nil then
    self._bindBaseline = bind
  elseif not samePlace(self._bindBaseline, bind) then
    self._bindSignal = true
    self._bindBaseline = bind
  end
end

function TG:SignalManualAction(tag)
  local step = self:CurrentStep()
  if not step then
    return
  end
  if not self._manualSignals then
    self._manualSignals = {}
  end
  self._manualSignals[tostring(step) .. ":" .. tag] = true
  self._wasStepComplete = nil
  if self.InvalidateStepCompletionCache then
    self:InvalidateStepCompletionCache(step)
  end
  if self.CheckAdvance then
    self:CheckAdvance("event")
  end
end

function TG:ManualActionDetected(el, stepKey)
  local tag = el and el.tag
  if tag == "hs" or tag == "hearth" then
    local signals = self._manualSignals
    return (signals and signals[stepKey .. ":hs"] == true)
      or (signals and signals[stepKey .. ":hearth"] == true)
      or false
  end
  if tag == "abandon" then
    return self:QuestAbsentFromLog(el) or false
  end
  if tag == "use" then
    return self:QuestStarterAcceptedForItem(el.args and el.args[1]) or false
  end
  if tag == "home" then
    local bind = self:CurrentBindLocation()
    local place = bindPlaceFromElement(el)
    if place and bind and samePlace(place, bind) then
      return true
    end
    if self._bindSignal and (not place or not bind or samePlace(place, bind)) then
      return true
    end
    return false
  end
  return (self._manualSignals and self._manualSignals[stepKey .. ":" .. tostring(tag)] == true) or false
end

function TG:StepManualActionsSatisfied(step)
  if not step or not step.elements then
    return false
  end
  local stepKey = tostring(step)
  local saw = false
  for _, el in ipairs(step.elements) do
    if el.t == "cmd" and Shared.MANUAL_ACTION_TAGS[el.tag] then
      saw = true
      if not self:ManualActionDetected(el, stepKey) then
        return false
      end
    end
  end
  return saw
end

function TG:ClearManualCheckHold()
  self._manualCheckTime = nil
  self._manualCheckStep = nil
end

function TG:StepStateSignature(step)
  if not step then
    return ""
  end
  local parts = {}
  local stepKey = tostring(step)
  for _, el in ipairs(step.elements or {}) do
    if Shared.isObjectiveElement(el) then
      table.insert(parts, tostring(el.tag) .. ":" .. tostring(self:IsElementDone(el)))
    elseif el.t == "cmd" and Shared.MANUAL_ACTION_TAGS[el.tag] then
      table.insert(parts, "manual:" .. tostring(el.tag) .. ":" .. tostring(self:ManualActionDetected(el, stepKey)))
    end
  end
  table.insert(parts, "skip:" .. tostring(self.StepSkipState and self:StepSkipState(step) or false))
  return table.concat(parts, "|")
end

function TG:GetManualNavPosition()
  local zone = (GetZoneText and GetZoneText() or "")
  local px, py
  if GetPlayerMapPosition then
    local x, y = GetPlayerMapPosition("player")
    if x and y and not (x == 0 and y == 0) then
      px, py = x * 100, y * 100
    end
  end
  return zone, px, py
end

function TG:PlayerMovedSinceManualNav()
  local nav = self._manualNavPos
  if not nav then
    return false
  end
  local zone, px, py = self:GetManualNavPosition()
  if zone ~= nav.zone then
    return true
  end
  if px and py and nav.x and nav.y then
    local dx, dy = px - nav.x, py - nav.y
    return (dx * dx + dy * dy) >= 0.25
  end
  return false
end

function TG:CaptureManualNavState(reason)
  local step = self:CurrentStep()
  self._manualNavHold = true
  self._manualNavStep = self.currentStepIndex
  self._manualNavReason = reason or "manual navigation"
  self._manualNavClearedBy = nil
  self._manualNavSignature = step and self:StepStateSignature(step) or ""
  local zone, x, y = self:GetManualNavPosition()
  self._manualNavPos = { zone = zone, x = x, y = y }
  self._autoNavTime = nil
  self._wasStepComplete = nil
  self:ClearManualCheckHold()
end

function TG:ClearManualNavHold(reason)
  if not self._manualNavHold then
    return
  end
  self._manualNavHold = nil
  self._manualNavStep = nil
  self._manualNavSignature = nil
  self._manualNavPos = nil
  self._manualNavClearedBy = reason or "explicit action"
end

function TG:IsManualNavHeld()
  if not self._manualNavHold then
    return false
  end
  if self._manualNavStep and self._manualNavStep ~= self.currentStepIndex then
    self:ClearManualNavHold("step changed")
    return false
  end
  return true
end

function TG:CheckManualCheckAdvance()
  if not self._manualCheckTime then
    return
  end
  local now = GetTime and GetTime() or 0
  if now - self._manualCheckTime < Shared.MANUAL_CHECK_VISIBLE_DELAY then
    return
  end
  local stepIndex = self._manualCheckStep
  self:ClearManualCheckHold()
  if stepIndex and self.currentStepIndex ~= stepIndex then
    return
  end
  self:CheckAdvance("manual")
end

local function manualKey(self, el)
  if not self.currentGuide then
    return nil
  end
  for _, step in ipairs(self.currentGuide.steps or {}) do
    for index, element in ipairs(step.elements or {}) do
      if element == el then
        local stepKey = step.stepId or step.index or "?"
        return tostring(stepKey) .. ":" .. tostring(index)
      end
    end
  end
  return nil
end

function TG:IsElementManuallyDone(el)
  if not self.cdb then
    return false
  end
  local key = manualKey(self, el)
  if not key then
    return false
  end
  local guideKey = self.currentGuide and self.currentGuide.key
  local saved = guideKey and self.cdb.manualDoneByGuide and self.cdb.manualDoneByGuide[guideKey]
  return saved and saved[key] == true or false
end

function TG:RestoreManualElementStates(guide)
  if not guide or not self.cdb then
    return
  end
  local saved = self.cdb.manualDoneByGuide and self.cdb.manualDoneByGuide[guide.key]
  if not saved then
    return
  end
  for _, step in ipairs(guide.steps or {}) do
    local stepKey = step.stepId or step.index or "?"
    for index, el in ipairs(step.elements or {}) do
      if saved[tostring(stepKey) .. ":" .. tostring(index)] then
        el._tgManualDone = true
      end
    end
  end
end

function TG:SetElementManualDone(el, value)
  if not self:IsElementTrackable(el) then
    return false
  end
  if self.InvalidateStepCompletionCache then
    self:InvalidateStepCompletionCache()
  end
  if value then
    el._tgManualDone = true
    local key = manualKey(self, el)
    local guideKey = self.currentGuide and self.currentGuide.key
    if key and guideKey then
      self.cdb.manualDoneByGuide = self.cdb.manualDoneByGuide or {}
      self.cdb.manualDoneByGuide[guideKey] = self.cdb.manualDoneByGuide[guideKey] or {}
      self.cdb.manualDoneByGuide[guideKey][key] = true
    end
    self._manualCheckTime = GetTime and GetTime() or 0
    self._manualCheckStep = self.currentStepIndex
    self._wasStepComplete = nil
    if self.ClearManualNavHold then
      self:ClearManualNavHold("checkbox click")
    end
    self._autoNavTime = nil
  else
    el._tgManualDone = nil
    local key = manualKey(self, el)
    local guideKey = self.currentGuide and self.currentGuide.key
    local saved = guideKey and self.cdb and self.cdb.manualDoneByGuide and self.cdb.manualDoneByGuide[guideKey]
    if key and saved then
      saved[key] = nil
    end
    self:ClearManualCheckHold()
  end
  return true
end

function TG:ClearManualElementStates(step)
  if not step then
    return
  end
  for _, el in ipairs(step.elements or {}) do
    el._tgManualDone = self:IsElementManuallyDone(el) and true or nil
  end
  if self.InvalidateStepCompletionCache then
    self:InvalidateStepCompletionCache(step)
  end
end

Manual.bindPlaceFromElement = bindPlaceFromElement
Manual.samePlace = samePlace
