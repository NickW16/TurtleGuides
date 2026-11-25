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
  if not Quests.canReadQuestIds() then
    return nil
  end
  return (TG.GetQuestLogIndexById and TG:GetQuestLogIndexById(id)) ~= nil
end

local function checkQuestTurnedIn(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  if TG:IsQuestTurnedIn(id) then
    return true
  end
  return nil
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
  local unknown = false
  self._skipDebug = nil
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (Shared.CONDITION_TAGS[el.tag] or isXpCapElement(el)) then
      local tag, a = el.tag, (el.args or {})
      local value
      if tag == "itemcount" then
        value = checkItemCountCondition(el)
      elseif tag == "cooldown" then
        value = checkCooldownCondition(el)
      elseif tag == "xp" and isXpCapElement(el) then
        value = checkXpCap(el)
      elseif tag == "isOnQuest" and a[1] then
        value = checkQuestOn(a[1])
      elseif tag == "isNotOnQuest" and a[1] then
        local on = checkQuestOn(a[1])
        if on ~= nil then
          value = not on
        end
      elseif tag == "isQuestTurnedIn" and a[1] then
        value = checkQuestTurnedIn(a[1])
      elseif tag == "isQuestAvailable" and a[1] then
        local done = checkQuestTurnedIn(a[1])
        if done ~= nil then
          value = not done
        end
      elseif tag == "isQuestComplete" and tonumber(a[1]) then
        local id = tonumber(a[1])
        local on = checkQuestOn(id)
        if on == true then
          local idx = TG.GetQuestLogIndexById and TG:GetQuestLogIndexById(id)
          local done
          if idx and GetQuestLogTitle then
            local _, _, _, _, _, d = GetQuestLogTitle(idx)
            done = d
          end
          if done == 1 then
            value = true
          elseif done == 0 then
            value = false
          end
        elseif on == false then
          value = checkQuestTurnedIn(id)
        end
      end
      if value == false then
        self._skipDebug = "condition " .. tostring(tag) .. " not met"
        return false
      elseif value == nil then
        unknown = true
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
    return nil
  end
  self._skipDebug = nil
  return false
end

function TG:StepSkipState(step)
  if self.ShouldSkipStepForHardcoreMode and self:ShouldSkipStepForHardcoreMode(step) then
    self._skipDebug = "softcore step in hardcore mode"
    return true
  end
  local zone, cond
  if self.ShouldSkipStepByZone then
    zone = self:ShouldSkipStepByZone(step)
  end
  if zone == true then
    return true
  end
  if self.EvaluateConditions then
    cond = self:EvaluateConditions(step)
  end
  if cond == false then
    return true
  end
  if zone == nil or cond == nil then
    return nil
  end
  return false
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
