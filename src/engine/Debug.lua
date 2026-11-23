-- current step diagnostics
local TG = _G.TurtleGuides

function TG:DebugCurrentStep()
  local guide = self.currentGuide
  if not guide then
    self:Print("Debug: no guide loaded.")
    return
  end
  local idx = self.currentStepIndex or 1
  local step = guide.steps[idx]
  local lines = {}
  local function add(s)
    table.insert(lines, s)
    self:Print(s)
  end

  add("Debug guide: " .. (guide.name or guide.key or "?") .. " step " .. idx .. "/" .. table.getn(guide.steps or {}))
  if not step then
    add("Debug: no step object.")
  elseif not step.elements then
    add("Debug: no elements.")
  else
    for i, el in ipairs(step.elements) do
      local args = ""
      if el.args then
        for j = 1, table.getn(el.args) do
          if j > 1 then
            args = args .. ","
          end
          args = args .. tostring(el.args[j])
        end
      end
      local text = el.text or ""
      if string.len(text) > 120 then
        text = string.sub(text, 1, 120) .. "..."
      end
      add(
        "  ["
          .. i
          .. "] t="
          .. tostring(el.t or "?")
          .. " tag="
          .. tostring(el.tag or "")
          .. " args={"
          .. args
          .. "} text="
          .. tostring(text)
      )
    end
  end

  if step then
    local wz, wx, wy, _, wradius, woptional = self:GetStepGoto(step)
    if wz then
      local mode = "default"
      if wradius and wradius > 0 then
        mode = "radius"
      elseif wradius and wradius < 0 then
        mode = "dynamic/nearest"
      end
      local dist
      if TG.WorldDistanceToWaypoint then
        dist = TG:WorldDistanceToWaypoint(wz, wx, wy)
      end
      add(
        "  waypoint: "
          .. tostring(wz)
          .. " "
          .. string.format("%.1f, %.1f", wx, wy)
          .. " radius="
          .. tostring(wradius)
          .. " mode="
          .. mode
          .. (woptional and " optional" or "")
          .. (dist and string.format(" distance=%.0f yd", dist) or "")
      )
    end
  end

  if step and step.elements then
    local hasReq = false
    for _, el in ipairs(step.elements) do
      if
        el.t == "cmd"
        and (el.tag == "accept" or el.tag == "turnin" or el.tag == "complete" or el.tag == "collect" or el.tag == "xp")
      then
        hasReq = true
        local state = self:IsElementDone(el)
        local source = self._tgDoneSource or "unknown"
        local title
        if el.tag ~= "collect" and el.tag ~= "xp" then
          title = self:ResolveQuestTitle(el)
        end
        add(
          "  objective "
            .. tostring(el.tag)
            .. " -> "
            .. tostring(state)
            .. " ("
            .. source
            .. ")"
            .. (title and (" (" .. title .. ")") or "")
        )
        if el._tgManualDone then
          add("    manual checkbox override active - click the checkbox to undo")
        end
      end
    end
    local manual, manualTag = self:StepHasManualAction(step)
    if manual then
      local satisfied = self:StepManualActionsSatisfied(step)
      if manualTag == "home" then
        add(
          "  .home detected: "
            .. tostring(satisfied)
            .. " (bound to "
            .. tostring(self:CurrentBindLocation() or "unknown")
            .. ")"
        )
      end
      if not satisfied then
        add("  manual action ." .. tostring(manualTag) .. " - not detected; press Next when done")
      end
    elseif not hasReq then
      add("  no trackable objectives - manual Next required")
    end
  end

  if step then
    local skipState = self.StepSkipState and self:StepSkipState(step)
    add("  skip gate: " .. tostring(skipState) .. (self._skipDebug and (" (" .. self._skipDebug .. ")") or ""))
  end
  if TG.db and TG.db.disableAutoSkip then
    add("  auto-skip disabled in settings")
  end
  if self:IsManualNavHeld() then
    add(
      "  auto-advance held by "
        .. tostring(self._manualNavReason)
        .. " - waiting for objective change, movement or another manual action"
    )
    add("  captured state: " .. tostring(self._manualNavSignature))
  elseif self._manualNavClearedBy then
    add("  manual-navigation hold released by " .. tostring(self._manualNavClearedBy))
  end
  local now = GetTime and GetTime() or 0
  if self._autoNavTime and (now - self._autoNavTime) < 0.25 then
    add("  auto-advance paused: transition debounce")
  end
  if self.cdb then
    self.cdb.debug = table.concat(lines, "\n")
    add("Debug: saved to TurtleGuidesCharDB.debug (will persist after /reload).")
  end
end
