-- current step diagnostics
local TG = _G.TurtleGuides

local copyFrame

function TG:ShowDebugCopy(text)
  if not copyFrame then
    copyFrame = CreateFrame("Frame", "TurtleGuidesDebugCopyFrame", UIParent)
    copyFrame:SetWidth(520)
    copyFrame:SetHeight(360)
    copyFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    copyFrame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      tile = true,
      tileSize = 4,
      edgeSize = 1,
      insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    copyFrame:SetBackdropColor(0.06, 0.06, 0.06, 0.96)
    copyFrame:SetBackdropBorderColor(0.45, 0.41, 0.35, 1)
    copyFrame:SetMovable(true)
    copyFrame:EnableMouse(true)
    copyFrame:RegisterForDrag("LeftButton")
    copyFrame:SetScript("OnDragStart", function()
      this:StartMoving()
    end)
    copyFrame:SetScript("OnDragStop", function()
      this:StopMovingOrSizing()
    end)

    local title = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    title:SetPoint("TOPLEFT", copyFrame, "TOPLEFT", 8, -8)
    title:SetText("TurtleGuides debug - text is selected, press Ctrl+C to copy")

    local close = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT", 2, -2)
    close:SetScript("OnClick", function()
      copyFrame:Hide()
    end)

    local scroll = CreateFrame("ScrollFrame", "TurtleGuidesDebugCopyScroll", copyFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", copyFrame, "TOPLEFT", 8, -28)
    scroll:SetPoint("BOTTOMRIGHT", copyFrame, "BOTTOMRIGHT", -28, 8)

    local edit = CreateFrame("EditBox", "TurtleGuidesDebugCopyText", scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(GameFontHighlightSmall)
    edit:SetTextInsets(4, 4, 4, 4)
    edit:SetScript("OnEscapePressed", function()
      copyFrame:Hide()
    end)
    scroll:SetScrollChild(edit)

    copyFrame.edit = edit
    copyFrame.scroll = scroll
    copyFrame:SetScript("OnShow", function()
      local width = scroll:GetWidth()
      if width and width > 0 then
        edit:SetWidth(width - 18)
      end
      edit:SetFocus()
      edit:HighlightText()
    end)
  end

  local value = tostring(text or "")
  local _, lines = string.gsub(value, "\n", "\n")
  copyFrame.edit:SetText(value)
  copyFrame.edit:SetHeight(math.max(240, (lines + 1) * 15))
  copyFrame:Show()
  copyFrame.edit:SetFocus()
  copyFrame.edit:HighlightText()
end

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
  add("  guide key: " .. tostring(guide.key or "?"))
  local cursor = self.cdb and self.cdb.guideCursors and self.cdb.guideCursors[guide.key] or self.cdb and self.cdb.stepIndex
  add("  saved cursor: " .. tostring(cursor or "none"))
  if step then
    add(
      "  step index: "
        .. tostring(step.index or idx)
        .. (step.label and (" label=" .. tostring(step.label)) or "")
        .. (step.completewith and (" completewith=" .. tostring(step.completewith)) or "")
        .. (step.sticky and " sticky" or "")
        .. (step.optional and " optional" or "")
        .. (step.requires and (" requires=" .. tostring(step.requires)) or "")
    )
  end
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
      local ids = ""
      if el.questIds and table.getn(el.questIds) > 0 then
        ids = table.concat(el.questIds, ",")
      end
      add(
        "  ["
          .. i
          .. "] t="
          .. tostring(el.t or "?")
          .. " tag="
          .. tostring(el.tag or "")
          .. " source="
          .. tostring(el.sourceTag or "")
          .. " args={"
          .. args
          .. "} ids={"
          .. ids
          .. "}"
          .. (el.skipIfMissing and " skipIfMissing" or "")
          .. (el.reverse and " reverse" or "")
          .. " text="
          .. tostring(text)
          .. (el.objectiveText and (" objective=" .. tostring(el.objectiveText)) or "")
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
        local title, id
        if el.tag ~= "collect" and el.tag ~= "xp" then
          title, id = self:ResolveQuestTitle(el)
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
        if id or title then
          local evidence = self:GetQuestEvidence(id, title)
          if evidence then
            add(
              "    ledger: id="
                .. tostring(evidence.id)
                .. " title="
                .. tostring(evidence.title)
                .. " inLog="
                .. tostring(evidence.inLog)
                .. " complete="
                .. tostring(evidence.complete)
                .. " turnedIn="
                .. tostring(evidence.turnedIn)
                .. " logIndex="
                .. tostring(evidence.logIndex)
            )
          else
            add("    ledger: no evidence")
          end
        end
        if el.tag == "complete" then
          local objNum = el.args and tonumber(el.args[2])
          local objectives
          if title and self.GetQuestObjectives then
            objectives = self:GetQuestObjectives(title)
          end
          if (not objectives or not (objNum and objectives[objNum])) and id and self.GetQuestObjectivesById then
            objectives = self:GetQuestObjectivesById(id)
          end
          local objective = objNum and objectives and objectives[objNum] or nil
          add("    objectiveText: " .. tostring(el.objectiveText))
          add(
            "    log objective: "
              .. tostring(objective and objective.text)
              .. " done="
              .. tostring(objective and objective.done)
              .. " questId="
              .. tostring(id)
              .. " title="
              .. tostring(title)
          )
          add(
            "    turnedIn character="
              .. tostring(self.cdb and self.cdb.turnedIn and self.cdb.turnedIn[tonumber(id or "")])
              .. " account="
              .. tostring(pfQuest_history and pfQuest_history[tonumber(id or "")])
          )
        end
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
    add("  step complete: " .. tostring(self:IsStepComplete(step)))
    local skipState = self.StepSkipState and self:StepSkipState(step)
    add("  skip gate: " .. tostring(skipState) .. (self._skipDebug and (" (" .. self._skipDebug .. ")") or ""))
    add(
      "  stepSkip: "
        .. tostring(step.stepSkip)
        .. (step.stepSkipReason and (" (" .. tostring(step.stepSkipReason) .. ")") or "")
    )
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
  if self.ShowDebugCopy then
    self:ShowDebugCopy(table.concat(lines, "\n"))
  end
end
