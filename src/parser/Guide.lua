-- parses raw guide text into a guide table
local TG = _G.TurtleGuides
local Context = TG.Parser.Context
local parseElementLine = TG.Parser.parseElementLine
local strtrim = TG.Util.strtrim
local splitLines = TG.Util.splitLines

local function finalizeMeta(guide, source)
  guide.name = guide.meta.name or guide.meta["#name"] or source or "Unknown"
  guide.group = guide.meta.group or guide.meta["#group"] or "Guides"
  guide.subgroup = guide.meta.subgroup or ""
  guide.next = guide.meta.next
  guide.defaultFor = guide.meta.defaultfor or guide.meta.defaultFor
  guide.version = tonumber(guide.meta.version) or 0
  guide.key = (guide.group or "") .. "||" .. (guide.name or "")
  local mclassic = guide.meta.classic
  local hasEraTag = mclassic
    or guide.meta.tbc
    or guide.meta.wotlk
    or guide.meta.wrath
    or guide.meta.cata
    or guide.meta.mop
    or guide.meta.mists
    or guide.meta.retail
    or guide.meta.df
    or guide.meta.som
    or guide.meta.sod
  guide.isClassic = (mclassic ~= nil)
  if not guide.isClassic and not hasEraTag then
    guide.isClassic = false
  end
end
TG.Parser.FinalizeMeta = finalizeMeta

local function parseGuide(text, source)
  if not text then
    return nil, "empty"
  end
  local lines = splitLines(text)
  local guide = { source = source, meta = {}, steps = {}, labels = {}, raw = nil }
  local headerDone = false
  local currentStep = nil
  local ctx = Context.player()
  local guideApplicable = true
  local inHeader = true
  local lastGotoZone

  local function pushStep()
    if not currentStep then
      return
    end
    if not currentStep._skip then
      if currentStep.tags and currentStep.tags["season"] then
        local season = tonumber(currentStep.tags["season"])
        if season and season > 0 then
          currentStep._skip = true
        end
      end
      if not currentStep._skip then
        if table.getn(currentStep.elements) > 0 or currentStep.label or currentStep.completewith then
          currentStep.index = table.getn(guide.steps) + 1
          currentStep.stepSkip = nil
          currentStep.stepSkipReason = nil
          table.insert(guide.steps, currentStep)
          if currentStep.label and currentStep.label ~= "" then
            guide.labels[currentStep.label] = currentStep.index
          end
        end
      end
    end
    currentStep = nil
  end

  for _, raw in ipairs(lines) do
    local line = strtrim(raw)
    local commentText
    local cpos = string.find(line, "%-%-", 1)
    if cpos then
      commentText = strtrim(string.sub(line, cpos + 2))
      line = strtrim(string.sub(line, 1, cpos - 1))
    end

    if line ~= "" then
      if inHeader and string.sub(line, 1, 2) == "<<" and not string.find(line, "^step") then
        local cond = strtrim(string.sub(line, 3))
        if not TG.Parser.parseApplies(cond, ctx) then
          guideApplicable = false
        end
      elseif not headerDone and (string.find(line, "^#%S+") or (inHeader and string.sub(line, 1, 2) == "<<")) then
        if string.sub(line, 1, 2) == "<<" then
          local cond = strtrim(string.sub(line, 3))
          if not TG.Parser.parseApplies(cond, ctx) then
            guideApplicable = false
          end
        else
          local _, _, key, _, value = string.find(line, "^#(%S+)%s*(=?)%s*(.*)$")
          if key then
            value = strtrim(value or "")
            local p = string.find(value, "<<", 1, true)
            if p then
              local cond = strtrim(string.sub(value, p + 2))
              value = strtrim(string.sub(value, 1, p - 1))
              if not TG.Parser.parseApplies(cond, ctx) then
                value = nil
              end
            end
            if value ~= nil then
              local lk = string.lower(key)
              guide.meta[lk] = value
              guide.meta[key] = value
            end
          end
        end
      elseif string.find(line, "^step") then
        inHeader = false
        headerDone = true
        pushStep()
        local cond
        local p = string.find(line, "<<", 1, true)
        if p then
          cond = strtrim(string.sub(line, p + 2))
        end
        if TG.Parser.parseApplies(cond, ctx) then
          currentStep = { elements = {}, cond = cond, tags = {}, _deathskip = false, _softcore = false }
        else
          currentStep = { elements = {}, cond = cond, tags = {}, _skip = true, _deathskip = false, _softcore = false }
        end
      else
        inHeader = false
        headerDone = true
        if currentStep and not currentStep._skip then
          local el = parseElementLine(line, commentText)
          if el and el ~= false then
            if el.t == "tag" then
              local key = string.lower(el.key or "")
              if key == "label" then
                currentStep.label = el.value
              elseif key == "completewith" then
                currentStep.completewith = el.value
              elseif key == "sticky" then
                currentStep.sticky = true
              elseif key == "optional" then
                currentStep.optional = true
              elseif key == "requires" then
                currentStep.requires = el.value
              elseif key == "softcore" then
                currentStep._softcore = true
              else
                table.insert(currentStep.elements, el)
              end
              currentStep.tags[key] = el.value ~= "" and el.value or true
            else
              table.insert(currentStep.elements, el)
              if el.t == "cmd" and el.tag == "goto" and el.args then
                local count = table.getn(el.args)
                if count >= 3 then
                  lastGotoZone = el.args[1]
                elseif count == 2 and lastGotoZone then
                  el.gotoZone = lastGotoZone
                end
              elseif el.t == "cmd" and el.tag == "deathskip" then
                currentStep._deathskip = true
              end
            end
          end
        end
      end
    end
  end
  pushStep()

  for i, step in ipairs(guide.steps) do
    step.index = i
    if step.completewith == "next" then
      step.completewithIndex = i + 1
    elseif step.completewith and guide.labels[step.completewith] then
      step.completewithIndex = guide.labels[step.completewith]
    end
  end

  finalizeMeta(guide, source)

  if not guideApplicable then
    return nil, "not applicable"
  end
  return guide
end

TG.Parser.ParseGuide = parseGuide
