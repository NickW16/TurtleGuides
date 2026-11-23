-- tri-state step gates for item counts, quest state, and zones
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local Quests = TG.Engine.Quests
local Conditions = {}
TG.Engine.Conditions = Conditions

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
    if el.t == "cmd" and Shared.CONDITION_TAGS[el.tag] then
      local tag, a = el.tag, (el.args or {})
      local value
      if tag == "itemcount" then
        value = checkItemCountCondition(el)
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
      if name and name ~= "" and tonumber(name) == nil then
        local flags = tonumber(el.args and el.args[2]) or 0
        local reverse = math.mod(math.floor(flags), 2) == 1
        local inZone
        if self.IsInNamedZone then
          inZone = self:IsInNamedZone(name, el.tag == "subzoneskip")
        end
        if inZone == nil then
          unknown = true
        elseif inZone ~= reverse then
          self._skipDebug = "zone skip: " .. tostring(name)
          return true
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

Conditions.canReadBags = canReadBags
Conditions.checkItemCountCondition = checkItemCountCondition
Conditions.checkQuestOn = checkQuestOn
Conditions.checkQuestTurnedIn = checkQuestTurnedIn
