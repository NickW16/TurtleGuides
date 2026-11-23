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
          local zone = (GetZoneText and GetZoneText() or "")
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
    local d = TG:WorldDistanceToWaypoint(g.zone, g.x, g.y)
    if d then
      return d, true
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

local function selectNearestDynamicGoto(self, gotos, stepKey, current)
  local best, bestDist
  for i, g in ipairs(gotos) do
    if isDynamicGoto(g) then
      local d = gotoDistance(g)
      if d and (not bestDist or d < bestDist) then
        best, bestDist = i, d
      end
    end
  end
  if best and best ~= current then
    self._gotoIndex[stepKey] = best
    if self.UpdateStepWaypoint then
      self:UpdateStepWaypoint()
    end
    if self.UpdateUI then
      self:UpdateUI()
    end
  end
  return best
end

local function advanceGotoIndex(self, stepKey, idx, total)
  local nextIdx = idx + 1
  if nextIdx <= total then
    self._gotoIndex[stepKey] = nextIdx
    if self.UpdateStepWaypoint then
      self:UpdateStepWaypoint()
    end
    if self.UpdateUI then
      self:UpdateUI()
    end
  else
    self._gotoIndex[stepKey] = nil
    self:NextStep(false)
  end
end

function TG:CheckGotoAdvance()
  if not self.currentGuide then
    return
  end
  local step = self:CurrentStep()
  if not step then
    return
  end
  if self.StepSkipState and self:StepSkipState(step) == true then
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
  local idx = self._gotoIndex[stepKey] or 1
  if idx > total then
    idx = total
  end
  local g = gotos[idx]

  local arrivedFromDynamic = false
  if isDynamicGoto(g) then
    local reached
    for i, candidate in ipairs(gotos) do
      if not isDynamicGoto(candidate) then
        local d = gotoDistance(candidate)
        if d and d <= gotoRadius(candidate) then
          reached = i
          break
        end
      end
    end
    if reached then
      idx = reached
      g = gotos[idx]
      self._gotoIndex[stepKey] = idx
      arrivedFromDynamic = true
    else
      selectNearestDynamicGoto(self, gotos, stepKey, idx)
      return
    end
  end

  if not arrivedFromDynamic then
    local zoneNow = (GetZoneText and GetZoneText() or "")
    local currentZone = g.zone
    if self.ZoneName then
      currentZone = self:ZoneName(currentZone)
    end
    if zoneNow ~= "" and not zoneMatches(zoneNow, currentZone) then
      for j = idx + 1, total do
        local nextZone = gotos[j].zone
        if self.ZoneName then
          nextZone = self:ZoneName(nextZone)
        end
        if zoneMatches(zoneNow, nextZone) then
          self._gotoIndex[stepKey] = j
          if self.UpdateStepWaypoint then
            self:UpdateStepWaypoint()
          end
          if self.UpdateUI then
            self:UpdateUI()
          end
          return
        end
      end
    end
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
