-- tri-state step gates for item counts, quest state, and zones
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local Quests = TG.Engine.Quests
local Conditions = {}
TG.Engine.Conditions = Conditions

function TG:IsSoftcoreStep(step)
  if not step then
    return false
  end
  if step._softcore == true then
    return true
  end
  return step.tags ~= nil and step.tags.softcore ~= nil
end

function TG:ShouldSkipStepForHardcoreMode(step)
  if not TG.db or not TG.db.hardcoreMode then
    return false
  end
  return self:IsSoftcoreStep(step)
end

local function canReadBags()
  if not GetContainerNumSlots then
    return false
  end
  local ok, slots = pcall(GetContainerNumSlots, 0)
  return ok and type(slots) == "number"
end

local function checkItemCountCondition(el)
  local a = el.args or {}
  local itemId = tonumber(a[1])
  local raw = tostring(a[2] or "1")
  local op, digits = string.match(raw, "^%s*([<>]?=?)(%d+)%s*$")
  if not itemId or not digits then
    return nil
  end
  if not canReadBags() then
    return nil
  end
  local want = tonumber(digits)
  local have = TG:GetItemCount(itemId) or 0
  if op == "<" then
    return have < want
  end
  if op == "<=" then
    return have <= want
  end
  if op == ">" then
    return have > want
  end
  if op == ">=" then
    return have >= want
  end
  if op == "=" then
    return have == want
  end
  return have >= want
end

local function itemCooldown(id)
  if GetItemCooldown then
    local ok, start, duration = pcall(GetItemCooldown, id)
    if ok and start and duration and duration > 0 then
      return start, duration
    end
  end
  if not GetContainerNumSlots then
    return nil
  end
  local found = false
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      local itemId
      if GetContainerItemID then
        itemId = GetContainerItemID(bag, slot)
      end
      if not itemId and GetContainerItemLink then
        local link = GetContainerItemLink(bag, slot)
        if link and TG.GetItemIdFromLink then
          itemId = TG:GetItemIdFromLink(link)
        end
      end
      if tonumber(itemId) == id then
        found = true
        if GetContainerItemCooldown then
          local start, duration = GetContainerItemCooldown(bag, slot)
          if start and duration and duration > 0 then
            return start, duration
          end
        end
      end
    end
  end
  if found then
    return 0, 0
  end
  return nil
end

local function cooldownRemaining(el)
  local a = el.args or {}
  local id = tonumber(a[2])
  if not id then
    return nil
  end
  local kind = string.lower(tostring(a[1] or "item"))
  local start, duration
  if kind == "spell" then
    if not GetSpellCooldown then
      return nil
    end
    start, duration = GetSpellCooldown(id)
  else
    start, duration = itemCooldown(id)
  end
  if not start or not duration then
    return nil
  end
  return (start + duration) - (GetTime and GetTime() or 0)
end

local function checkCooldownCondition(el)
  local raw = tostring(el.args and el.args[3] or "")
  local op, digits, suffix = string.match(raw, "^%s*([<>]?)%s*(%d+%.?%d*)%s*([ms]?)%s*$")
  if not digits then
    return nil
  end
  local need = tonumber(digits)
  if not need then
    return nil
  end
  if suffix == "m" then
    need = need * 60
  end
  if need < 2 then
    need = 2
  end
  local remaining = cooldownRemaining(el)
  if remaining == nil then
    return nil
  end
  if op == "<" then
    return remaining >= need
  end
  return remaining <= need
end

local function checkQuestOn(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  if Quests.recentlyAccepted(id) then
    return true
  end
  local evidence = TG:GetQuestEvidence(id)
  if evidence then
    return evidence.inLog == true
  end
  if not Quests.canReadQuestIds() then
    return nil
  end
  return false
end

local function checkQuestTurnedIn(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  local evidence = TG:GetQuestEvidence(id)
  if evidence then
    return evidence.turnedIn == true
  end
  if not Quests.canReadQuestIds() then
    return nil
  end
  return false
end

local function checkQuestComplete(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  local evidence = TG:GetQuestEvidence(id)
  if not evidence then
    if not Quests.canReadQuestIds() then
      return nil
    end
    return false
  end
  if evidence.complete or evidence.turnedIn then
    return true
  end
  return false
end

local function elementQuestIds(el)
  if el and el.questIds and table.getn(el.questIds) > 0 then
    return el.questIds
  end
  local ids = {}
  for _, arg in ipairs(el and el.args or {}) do
    local id = tonumber(arg)
    if id then
      table.insert(ids, math.abs(id))
    end
  end
  return ids
end

local function anyQuestValue(ids, fn)
  local unknown = false
  for _, id in ipairs(ids) do
    local value = fn(id)
    if value == true then
      return true
    elseif value == nil then
      unknown = true
    end
  end
  if unknown then
    return nil
  end
  return false
end

local function isXpCapElement(el)
  if not el or el.t ~= "cmd" or el.tag ~= "xp" or not TG.ParseXpArg then
    return false
  end
  local op = select(1, TG:ParseXpArg(el.args and el.args[1]))
  return op == "<"
end

local function checkXpCap(el)
  local op, level = TG:ParseXpArg(el.args and el.args[1])
  if op ~= "<" or not level or not UnitLevel then
    return nil
  end
  return UnitLevel("player") < level
end

function TG:IsItemCountConditionMet(el)
  return checkItemCountCondition(el) == true
end

function TG:IsQuestOn(id)
  return checkQuestOn(id) == true
end

function TG:EvaluateConditions(step)
  local hardcore = self.db and self.db.hardcoreMode == true
  if hardcore and step.tags and step.tags.ah then
    self._skipDebug = "variant gate"
    return false
  end
  local unknown = false
  self._skipDebug = nil
  self._unknownConditionTags = {}
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (Shared.CONDITION_TAGS[el.tag] or isXpCapElement(el)) then
      local tag = el.tag
      local ids = elementQuestIds(el)
      local value
      if tag == "itemcount" then
        value = checkItemCountCondition(el)
      elseif tag == "cooldown" then
        value = checkCooldownCondition(el)
      elseif tag == "xp" and isXpCapElement(el) then
        value = checkXpCap(el)
      elseif tag == "isOnQuest" and ids[1] then
        value = anyQuestValue(ids, checkQuestOn)
      elseif tag == "isNotOnQuest" and ids[1] then
        local on = anyQuestValue(ids, checkQuestOn)
        if on ~= nil then
          value = not on
        end
      elseif tag == "isQuestTurnedIn" and ids[1] then
        value = anyQuestValue(ids, checkQuestTurnedIn)
      elseif tag == "isQuestAvailable" and ids[1] then
        local done = anyQuestValue(ids, checkQuestTurnedIn)
        if done ~= nil then
          value = not done
        end
      elseif tag == "isQuestComplete" and ids[1] then
        value = anyQuestValue(ids, checkQuestComplete)
      end
      if value ~= nil and el.reverse then
        value = not value
      end
      if value == false then
        self._skipDebug = "condition " .. tostring(tag) .. " not met"
        return false
      elseif value == nil then
        unknown = true
        self._unknownConditionTags[tag] = true
        self._skipDebug = "condition " .. tostring(tag) .. " unreadable"
      end
    end
  end
  if unknown then
    return nil
  end
  self._skipDebug = nil
  return true
end

function TG:StepConditionsMet(step)
  return self:EvaluateConditions(step) ~= false
end

function TG:ShouldSkipStepByZone(step)
  if not step or not step.elements then
    return false
  end
  local unknown = false
  self._unknownZone = false
  for _, el in ipairs(step.elements) do
    if el.t == "cmd" and (el.tag == "zoneskip" or el.tag == "subzoneskip") then
      local name = el.args and el.args[1]
      if name and name ~= "" then
        local resolved = name
        if tonumber(name) then
          resolved = self.ZoneNameFromId and self:ZoneNameFromId(name) or nil
          if not resolved then
            unknown = true
          end
        end
        if resolved then
          local flags = tonumber(el.args and el.args[2]) or 0
          local reverse = math.mod(math.floor(flags), 2) == 1
          local inZone
          if self.IsInNamedZone then
            inZone = self:IsInNamedZone(resolved, el.tag == "subzoneskip")
          end
          if inZone == nil then
            unknown = true
          elseif inZone ~= reverse then
            self._skipDebug = "zone skip: " .. tostring(resolved)
            return true
          end
        end
      end
    end
  end
  if unknown then
    self._unknownZone = true
    return nil
  end
  self._skipDebug = nil
  return false
end

local function unknownStepKey(self, step)
  if step.index and self.currentGuide then
    return tostring(self.currentGuide.key or "") .. ":" .. tostring(step.index)
  end
  return tostring(step)
end

function TG:ResolveUnknownStepSkip(step, reason)
  if not step then
    return nil
  end
  self._unknownGateSince = self._unknownGateSince or {}
  local key = unknownStepKey(self, step)
  local now = GetTime and GetTime() or 0
  local since = self._unknownGateSince[key]
  if not since then
    since = now
    self._unknownGateSince[key] = since
  end
  if now - since < Shared.UNKNOWN_STATE_TIMEOUT then
    self._skipDebug = "unreadable " .. tostring(reason) .. " - holding"
    return nil
  end
  local questUnknown = false
  for tag in pairs(self._unknownConditionTags or {}) do
    if Shared.UNKNOWN_QUEST_GATES[tag] then
      questUnknown = true
      break
    end
  end
  self._skipDebug = "unreadable "
    .. tostring(reason)
    .. " timed out; "
    .. (questUnknown and "treating prerequisite as missing" or "keeping step")
  return questUnknown
end

function TG:ClearStepSkipStates(guide)
  for _, step in ipairs(guide and guide.steps or {}) do
    step.stepSkip = nil
    step.stepSkipReason = nil
  end
  self._unknownGateSince = {}
end

function TG:StepSkipState(step)
  self._skipDebug = nil
  self._unknownConditionTags = {}
  self._unknownZone = false
  if self.ShouldSkipStepForHardcoreMode and self:ShouldSkipStepForHardcoreMode(step) then
    self._skipDebug = "softcore step in hardcore mode"
    if step then
      step.stepSkip = true
      step.stepSkipReason = self._skipDebug
    end
    return true
  end
  local zone, cond
  if self.ShouldSkipStepByZone then
    zone = self:ShouldSkipStepByZone(step)
  end
  if zone == true then
    if step then
      step.stepSkip = true
      step.stepSkipReason = self._skipDebug
    end
    return true
  end
  if self.EvaluateConditions then
    cond = self:EvaluateConditions(step)
  end
  local state
  if cond == false then
    state = true
  elseif zone == nil or cond == nil then
    state = self:ResolveUnknownStepSkip(step, zone == nil and "zone skip" or "condition")
  else
    state = false
  end
  if step then
    step.stepSkip = state
    step.stepSkipReason = self._skipDebug or nil
  end
  return state
end

function TG:AutoSkipEnabled()
  return not (TG.db and TG.db.disableAutoSkip)
end

function TG:ShouldAutoSkipStep(step)
  return self:StepSkipState(step) == true and self:AutoSkipEnabled()
end

Conditions.canReadBags = canReadBags
Conditions.checkItemCountCondition = checkItemCountCondition
Conditions.checkQuestOn = checkQuestOn
Conditions.checkQuestTurnedIn = checkQuestTurnedIn
Conditions.checkQuestComplete = checkQuestComplete
Conditions.elementQuestIds = elementQuestIds
Conditions.anyQuestValue = anyQuestValue
