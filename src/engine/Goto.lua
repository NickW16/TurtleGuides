-- goto extraction, route following, and waypoint updates
local TG = _G.TurtleGuides
local Shared = TG.Engine.Shared
local strtrim = TG.Util.strtrim
local Goto = {}
TG.Engine.Goto = Goto

local function zoneMatches(a, b)
  if TG.ZoneMatches then
    return TG:ZoneMatches(a, b)
  end
  if not a or not b then
    return false
  end
  return string.lower(a) == string.lower(b)
end

function TG:GetStepGotos(step)
  if not step or not step.elements then
    return {}
  end
  local gotos = {}
  for _, el in ipairs(step.elements) do
    if el.t == "cmd" and el.tag == "goto" and el.args then
      local text = el.text or ""
      if text ~= "" then
        if TG.cleanRxpColors then
          text = TG.cleanRxpColors(text)
        end
        text = string.gsub(text, "|T.-|t", "")
        text = strtrim(text)
      end
      local a = el.args
      if table.getn(a) >= 3 then
        local zone = a[1]
        local x, y = tonumber(a[2]), tonumber(a[3])
        local radius = tonumber(a[4]) or 0
        local optional = a[5] ~= nil
        if zone and x and y then
          table.insert(gotos, {
            zone = zone,
            x = x,
            y = y,
            radius = radius,
            range = radius,
            optional = optional,
            text = text,
          })
        end
      elseif table.getn(a) == 2 then
        local x, y = tonumber(a[1]), tonumber(a[2])
        if x and y then
          local zone = el.gotoZone or (GetZoneText and GetZoneText() or "")
          table.insert(gotos, {
            zone = zone,
            x = x,
            y = y,
            radius = 0,
            range = 0,
            optional = false,
            text = text,
          })
        end
      end
    end
  end
  return gotos
end

function TG:GetStepGoto(step)
  if not step or not step.elements then
    return nil
  end
  local gotos = self:GetStepGotos(step)
  if table.getn(gotos) == 0 then
    return nil
  end
  if not self._gotoIndex then
    self._gotoIndex = {}
  end
  local stepKey = tostring(step)
  local idx = self._gotoIndex[stepKey] or 1
  if idx > table.getn(gotos) then
    idx = table.getn(gotos)
  end
  local target = gotos[idx]
  return target.zone, target.x, target.y, target.text, target.radius, target.optional
end

local function localPlayerPos()
  if SetMapToCurrentZone and (not WorldMapFrame or not WorldMapFrame:IsVisible()) then
    SetMapToCurrentZone()
  end
  if not GetPlayerMapPosition then
    return nil
  end
  local px, py = GetPlayerMapPosition("player")
  if not px or not py or (px == 0 and py == 0) then
    return nil
  end
  return (GetZoneText and GetZoneText() or ""), px * 100, py * 100
end

local function gotoDistance(g)
  if TG.WorldDistanceToWaypoint then
    local d, reason = TG:WorldDistanceToWaypoint(g.zone, g.x, g.y)
    if d then
      return d, true
    end
    if reason then
      return nil, false
    end
  end
  local zone, px, py = localPlayerPos()
  if not px then
    return nil
  end
  local gotoZone = g.zone
  if TG.ZoneName then
    gotoZone = TG:ZoneName(gotoZone)
  end
  if not zoneMatches(zone, gotoZone) then
    return nil
  end
  local dx, dy = g.x - px, g.y - py
  return math.sqrt(dx * dx + dy * dy) * 10, false
end

local function isDynamicGoto(g)
  return g and g.radius and g.radius < 0
end

local function gotoRadius(g)
  local r = g.radius or g.range
  if r and r > 0 then
    return r
  end
  return Shared.DEFAULT_GOTO_RADIUS
end

local function reachedTable(self, stepKey)
  if not self._gotoReached then
    self._gotoReached = {}
  end
  if not self._gotoReached[stepKey] then
    self._gotoReached[stepKey] = {}
  end
  return self._gotoReached[stepKey]
end

local function markGotoReached(self, stepKey, upto)
  local reached = reachedTable(self, stepKey)
  for i = 1, upto do
    reached[i] = true
  end
end

local function clearGotoReached(self, stepKey)
  if self._gotoReached then
    self._gotoReached[stepKey] = nil
  end
end

local function updateWaypoint(self)
  if self.UpdateStepWaypoint then
    self:UpdateStepWaypoint()
  end
  if self.UpdateUI then
    self:UpdateUI()
  end
end

local function setGotoIndex(self, stepKey, idx, current)
  if idx == current then
    return
  end
  if idx > current then
    markGotoReached(self, stepKey, idx - 1)
  end
  self._gotoIndex[stepKey] = idx
  updateWaypoint(self)
end

local function advanceGotoIndex(self, stepKey, idx, total)
  markGotoReached(self, stepKey, idx)
  local nextIdx = idx + 1
  if nextIdx <= total then
    self._gotoIndex[stepKey] = nextIdx
    updateWaypoint(self)
  else
    self._gotoIndex[stepKey] = nil
    clearGotoReached(self, stepKey)
    self:NextStep(false)
  end
end

local function selectNearestGoto(self, gotos, stepKey, current, reached)
  local best, bestDist
  for i, g in ipairs(gotos) do
    if not reached[i] then
      local d = gotoDistance(g)
      if d and (not bestDist or d < bestDist or (d == bestDist and i == current)) then
        best, bestDist = i, d
      end
    end
  end
  if best and best ~= current then
    setGotoIndex(self, stepKey, best, current)
  end
  return best, bestDist
end

function TG:CheckGotoAdvance()
  if not self.currentGuide then
    return
  end
  local step = self:CurrentStep()
  if not step then
    return
  end
  if self.ShouldAutoSkipStep and self:ShouldAutoSkipStep(step) then
    return
  end
  local gotos = self:GetStepGotos(step)
  local total = table.getn(gotos)
  if total == 0 then
    return
  end
  if not self._gotoIndex then
    self._gotoIndex = {}
  end
  local stepKey = tostring(step)
  local reached = reachedTable(self, stepKey)
  local idx = self._gotoIndex[stepKey] or 1
  if idx > total then
    idx = total
  end
  while idx <= total and reached[idx] do
    idx = idx + 1
  end
  if idx > total then
    self._gotoIndex[stepKey] = nil
    clearGotoReached(self, stepKey)
    self:NextStep(false)
    return
  end
  self._gotoIndex[stepKey] = idx

  selectNearestGoto(self, gotos, stepKey, idx, reached)
  idx = self._gotoIndex[stepKey] or idx
  local g = gotos[idx]

  local reachedIdx
  for i, candidate in ipairs(gotos) do
    if not reached[i] and not isDynamicGoto(candidate) then
      local d = gotoDistance(candidate)
      if d and d <= gotoRadius(candidate) then
        reachedIdx = i
        break
      end
    end
  end
  if reachedIdx then
    if reachedIdx > idx then
      markGotoReached(self, stepKey, reachedIdx - 1)
    end
    local changed = reachedIdx ~= idx
    idx = reachedIdx
    g = gotos[idx]
    self._gotoIndex[stepKey] = idx
    if changed then
      updateWaypoint(self)
    end
  end

  if not reachedIdx then
    local zoneNow = (GetZoneText and GetZoneText() or "")
    local currentZone = g.zone
    if self.ZoneName then
      currentZone = self:ZoneName(currentZone)
    end
    if zoneNow ~= "" and not zoneMatches(zoneNow, currentZone) then
      for j = idx + 1, total do
        if not reached[j] then
          local nextZone = gotos[j].zone
          if self.ZoneName then
            nextZone = self:ZoneName(nextZone)
          end
          if zoneMatches(zoneNow, nextZone) then
            setGotoIndex(self, stepKey, j, idx)
            idx = j
            g = gotos[j]
            break
          end
        end
      end
    end
  end

  if isDynamicGoto(g) then
    return
  end

  local dist = gotoDistance(g)
  if not dist then
    return
  end
  if dist > gotoRadius(g) then
    return
  end

  local manualHold = self:StepHasManualAction(step) and not self:StepManualActionsSatisfied(step)
  if Shared.stepHasObjective(step) and not manualHold then
    local allDone = true
    for _, el in ipairs(step.elements or {}) do
      if Shared.isObjectiveElement(el) and self:IsElementDone(el) ~= true then
        allDone = false
        break
      end
    end
    if allDone then
      advanceGotoIndex(self, stepKey, idx, total)
    end
  elseif not manualHold then
    advanceGotoIndex(self, stepKey, idx, total)
  end
end

function TG:UpdateStepWaypoint()
  local step = self:CurrentStep()
  local zone, x, y, gotoText, radius = self:GetStepGoto(step)

  if (not zone) and step and self.currentGuide and self.currentGuide.steps and (step.completewith or step.sticky) then
    local target
    if step.completewith == "next" then
      for i, s in ipairs(self.currentGuide.steps) do
        if s == step then
          target = self.currentGuide.steps[i + 1]
          break
        end
      end
    elseif step.completewith then
      for _, s in ipairs(self.currentGuide.steps) do
        if s.label == step.completewith then
          target = s
          break
        end
      end
    else
      for i, s in ipairs(self.currentGuide.steps) do
        if s == step then
          target = self.currentGuide.steps[i + 1]
          break
        end
      end
    end
    if target then
      local g = self:GetStepGotos(target)[1]
      if g then
        zone, x, y = g.zone, g.x, g.y
        gotoText = nil
      end
    end
  end

  if zone and x and y then
    local zname = (self.ZoneName and self:ZoneName(zone)) or tostring(zone)
    local title = (gotoText ~= "") and gotoText or nil
    if not title then
      for _, g in ipairs(self:GetStepGotos(step)) do
        if g.text and g.text ~= "" then
          title = g.text
          break
        end
      end
    end
    if not title and step and step.elements then
      for _, el in ipairs(step.elements) do
        if not (el.t == "cmd" and el.tag == "goto") then
          local txt = el.text
          if txt and txt ~= "" then
            if TG.cleanRxpColors then
              txt = TG.cleanRxpColors(txt)
            end
            txt = string.gsub(txt, "|T.-|t", "")
            txt = strtrim(txt)
            if txt ~= "" then
              title = txt
              break
            end
          end
        end
      end
    end
    if not title then
      title = zname .. string.format(" (%.1f, %.1f)", x, y)
    end
    self:SetWaypoint(zname, x, y, title, radius)
  else
    self:ClearWaypoint()
  end
end

Goto.gotoDistance = gotoDistance
Goto.gotoRadius = gotoRadius
Goto.isDynamicGoto = isDynamicGoto
Goto.selectNearestGoto = selectNearestGoto
