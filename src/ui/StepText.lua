-- formats guide elements into display text
local TG = _G.TurtleGuides
local strtrim = TG.Util.strtrim
local StepText = {}
TG.UI = TG.UI or {}
TG.UI.StepText = StepText

local MARK_DONE = "|cff66ff66[x]|r "
local MARK_PENDING = "|cffffff80[ ]|r "
local MARK_UNKNOWN = "|cffaaaaaa[?]|r "

local function cleanText(t)
  if not t or t == "" then
    return ""
  end
  return strtrim(t)
end

local function stripAllColors(t)
  t = TG.cleanRxpColors and TG.cleanRxpColors(t or "") or (t or "")
  t = string.gsub(t, "|c%x%x%x%x%x%x%x%x", "")
  t = string.gsub(t, "|cRXP_%w+_", "")
  t = string.gsub(t, "|r", "")
  return t
end

local function questNameFrom(id, txt)
  if txt and txt ~= "" then
    local t = TG.cleanRxpColors and TG.cleanRxpColors(txt) or txt
    t = string.gsub(t, "|T.-|t", "")
    t = string.gsub(t, "^Accept%s+", "")
    t = string.gsub(t, "^Turn in%s+", "")
    t = string.gsub(t, "^Turn In%s+", "")
    t = string.gsub(t, "^Complete%s+", "")
    t = strtrim(t)
    if t ~= "" then
      return t
    end
  end
  id = tonumber(id)
  if id and TG.GetQuestTitleById then
    local name = TG:GetQuestTitleById(id)
    if name and name ~= "" then
      return name
    end
  end
  return nil
end

local function parseObjectiveComment(text)
  text = TG.cleanRxpColors and TG.cleanRxpColors(text or "") or (text or "")
  text = string.gsub(text, "|T.-|t", "")
  text = strtrim(text)
  local label, count = string.match(text, "^(.-)%s*%(([xX]?%d+[xX]?)%)$")
  if not label then
    return nil
  end
  local need = tonumber(string.match(count, "%d+"))
  if not need then
    return nil
  end
  local explicit = string.match(label, "^[Cc]ollect%s+") or string.match(label, "^[Ll]oot%s+") or false
  label = string.gsub(label, "^[Cc]ollect%s+", "")
  label = string.gsub(label, "^[Ll]oot%s+", "")
  label = string.gsub(label, "^%[(.-)%]$", "%1")
  label = strtrim(label)
  if label == "" then
    return nil
  end
  local lower = string.lower(label)
  local killOrEvent = string.find(lower, "kill", 1, true)
    or string.find(lower, "slain", 1, true)
    or string.find(lower, "complete", 1, true)
    or string.find(lower, "performed", 1, true)
    or string.find(lower, "defeat", 1, true)
  return label, need, explicit or not killOrEvent
end

local function itemCountForName(name)
  if TG.GetItemCountByName then
    local n = TG:GetItemCountByName(name)
    if n then
      return n
    end
  end
  if TG.GetItemIdByName and TG.GetItemCount then
    local id = TG:GetItemIdByName(name)
    if id then
      return TG:GetItemCount(id)
    end
  end
  return nil
end

local function xpProgressString(level, xp, op)
  if not level or op == "<" or op == ">" then
    return ""
  end
  local curLevel = UnitLevel("player") or 1
  local curXP = (UnitXP and UnitXP("player")) or 0
  local maxXP = (UnitXPMax and UnitXPMax("player")) or 1
  if not maxXP or maxXP < 1 then
    maxXP = 1
  end
  if xp and xp < 0 then
    if curLevel == level - 1 then
      local target = math.max(0, math.floor(maxXP + xp))
      return string.format(" (%d/%d)", math.min(math.floor(curXP), target), target)
    end
  elseif xp and xp >= 1 then
    if curLevel == level then
      return string.format(" (%d/%d)", math.floor(curXP), math.floor(xp))
    end
  elseif xp and xp > 0 then
    if curLevel == level then
      return string.format(" (%d/%d)", math.floor(curXP), math.floor(maxXP * xp))
    end
  elseif curLevel == level then
    return string.format(" (%d/%d)", math.floor(curXP), math.floor(maxXP))
  end
  return ""
end

local function formatXpStep(el, txt)
  local arg1 = el.args and el.args[1]
  local op, level, xp
  if TG.ParseXpArg then
    op, level, xp = TG:ParseXpArg(arg1)
  end
  local body
  if txt ~= "" then
    body = txt
  elseif not level then
    body = "Reach level " .. tostring(arg1 or "")
  elseif op == "<" then
    body = "Skip below level " .. level
  elseif op == ">" then
    body = "Skip at level " .. level .. " or higher"
  elseif xp and xp < 0 then
    body = string.format("Grind until %d xp before level %d", -xp, level)
  elseif xp and xp >= 1 then
    body = string.format("Grind to %d xp into level %d", xp, level)
  elseif xp and xp > 0 then
    body = string.format("Grind to %.0f%% into level %d", xp * 100, level)
  else
    body = "Grind to level " .. level
  end
  local prefix = (txt == "") and "|cffaaaaaa" or ""
  local suffix = (txt == "") and "|r" or ""
  return prefix .. body .. xpProgressString(level, xp, op) .. suffix
end

local function elToText(el)
  if not el then
    return ""
  end
  if el.t == "text" then
    local t = TG.cleanRxpColors and TG.cleanRxpColors(el.text or "") or (el.text or "")
    t = string.gsub(t, "|T.-|t", "")
    return cleanText(t)
  elseif el.t == "cmd" then
    local tag = el.tag or ""
    local a = el.args or {}
    local txt = TG.cleanRxpColors and TG.cleanRxpColors(el.text or "") or (el.text or "")
    txt = string.gsub(txt, "|T.-|t", "")
    txt = cleanText(txt)
    if tag == "accept" then
      local q = questNameFrom(a[1], txt)
      return "|cff00ff00Accept:|r " .. (q or ("Quest " .. tostring(a[1] or "?")))
    elseif tag == "turnin" then
      local q = questNameFrom(a[1], txt)
      return "|cffffff00Turn in:|r " .. (q or ("Quest " .. tostring(a[1] or "?")))
    elseif tag == "complete" then
      local q = questNameFrom(a[1], txt)
      local objText
      local objn = a[2]
      if q and objn and TG.GetQuestObjectives then
        local objectives = TG:GetQuestObjectives(q)
        if objectives and objectives[tonumber(objn)] then
          objText = objectives[tonumber(objn)].text
        end
      end
      if txt ~= "" then
        return "|cff00ccffComplete:|r " .. txt
      end
      if objText and objText ~= "" then
        return "|cff00ccffComplete:|r " .. objText
      end
      if el.objectiveText and el.objectiveText ~= "" then
        local itemName, need, isItem = parseObjectiveComment(el.objectiveText)
        if itemName and need then
          local itemId = TG.GetItemIdByName and TG:GetItemIdByName(itemName)
          if itemId or isItem then
            local have = itemCountForName(itemName)
            if not have and isItem then
              have = 0
            end
            if have then
              if have > need then
                have = need
              end
              local counter = "|cffffd100" .. have .. "|r/|cffffd100" .. need .. "|r"
              return "|cff00ccffComplete:|r " .. itemName .. " " .. counter
            end
          end
        end
        return "|cff00ccffComplete:|r " .. el.objectiveText
      end
      if q then
        return "|cff00ccffComplete:|r " .. q .. (objn and (" (obj " .. tostring(objn) .. ")") or "")
      end
      if objn then
        return "|cff00ccffObjective:|r " .. tostring(objn)
      end
      return "|cff00ccffComplete objective|r"
    elseif tag == "itemcount" then
      if el.objectiveText and el.objectiveText ~= "" then
        return "|cffaaaaaaHave:|r " .. el.objectiveText
      end
      if txt and txt ~= "" then
        return "|cffaaaaaaHave:|r " .. txt
      end
      local itemId = tonumber(a[1])
      local iname = (itemId and TG.GetItemNameById) and TG:GetItemNameById(itemId) or nil
      return "|cffaaaaaaHave:|r " .. (iname or ("Item #" .. tostring(itemId or "?"))) .. " " .. tostring(a[2] or "1")
    elseif tag == "collect" then
      local id = tonumber(a[1])
      local count = tostring(a[2] or "1")
      local name = txt
      if name ~= "" then
        name = strtrim(string.gsub(name, "|T.-|t", ""))
      end
      if name == "" and id and TG.GetItemNameById then
        local iname = TG:GetItemNameById(id)
        if iname then
          name = iname
        end
      end
      if name == "" and id and pfDB and pfDB["items"] then
        local idb = pfDB["items"]
        local loc = idb["loc"] or idb["enUS"] or idb["enUS-turtle"]
        if type(loc) == "table" and loc[id] then
          local v = loc[id]
          if type(v) == "string" and v ~= "" and v ~= "_" then
            name = v
          elseif type(v) == "table" then
            local t = v["T"] or v["t"] or v[1]
            if type(t) == "string" and t ~= "" then
              name = t
            end
          end
        end
        if name == "" then
          for key, table_ in pairs(idb) do
            if
              type(table_) == "table"
              and type(key) == "string"
              and (string.find(key, "enUS") or string.find(key, "loc"))
            then
              local v = table_[id]
              if type(v) == "string" and v ~= "" and v ~= "_" then
                name = v
                break
              elseif type(v) == "table" then
                local t = v["T"] or v["t"] or v[1]
                if type(t) == "string" and t ~= "" then
                  name = t
                  break
                end
              end
            end
          end
        end
      end
      if name == "" then
        if id and GetItemInfo then
          GetItemInfo(id)
        end
        name = "Item #" .. tostring(id or "?")
      end
      local have = (id and TG.GetItemCount) and TG:GetItemCount(id) or 0
      local need = tonumber(count) or 1
      if have > need then
        have = need
      end
      local counter = "|cffffd100" .. have .. "|r/|cffffd100" .. need .. "|r"
      return "|cffffd100Collect:|r " .. name .. " " .. counter
    elseif tag == "goto" then
      if txt ~= "" then
        return txt
      end
      return nil
    elseif tag == "xp" then
      return formatXpStep(el, txt)
    elseif tag == "hs" or tag == "hearth" then
      return "|cffaaaaaaHearth:|r " .. (txt ~= "" and txt or "Hearthstone")
    elseif tag == "fly" or tag == "f" then
      return "|cffaaaaaaFly:|r " .. (txt ~= "" and txt or table.concat(a, " "))
    elseif tag == "home" then
      return "|cffaaaaaaSet hearth:|r " .. (txt ~= "" and txt or "")
    elseif tag == "vendor" then
      return "|cffaaaaaaVendor/Repair:|r " .. (txt ~= "" and txt or "")
    elseif tag == "trainer" or tag == "train" then
      local name = txt
      if name == "" then
        local sid = tonumber(a[1])
        if sid and GetSpellInfo then
          name = GetSpellInfo(sid) or name
        end
      end
      if name == "" and a[1] then
        name = "Spell " .. tostring(a[1])
      end
      return "|cffaaaaaaTrain:|r " .. (name or "")
    elseif tag == "use" or tag == "destroy" then
      local name = txt
      if name == "" then
        if TG.GetItemNameById then
          name = TG:GetItemNameById(a[1]) or name
        end
        if name == "" and GetItemInfo then
          name = GetItemInfo(a[1]) or name
        end
        if name == "" then
          name = "Item #" .. tostring(a[1] or "?")
        end
      end
      if tag == "destroy" then
        return "|cffff4040Destroy:|r " .. name
      end
      return "|cffaaaaaaUse:|r " .. name
    elseif tag == "kill" or tag == "target" or tag == "mob" then
      return nil
    elseif tag == "cast" or tag == "link" then
      return txt ~= "" and txt or nil
    else
      if txt ~= "" then
        return txt
      end
      return nil
    end
  end
  return nil
end

local function hasWarn(el)
  if not el then
    return false
  end
  return string.find(el.text or "", "|cRXP_WARN_", 1, true) ~= nil
end

local function isAuxStep(step)
  return step and (step.sticky or step.completewith) and true or false
end

local function elToTextNoWarn(el)
  if not hasWarn(el) then
    return elToText(el)
  end
  local raw = el.text or ""
  local cut = string.find(raw, "|cRXP_WARN_", 1, true)
  local tmp = {}
  for key, value in pairs(el) do
    tmp[key] = value
  end
  tmp.text = (cut and cut > 1) and strtrim(string.sub(raw, 1, cut - 1)) or ""
  return elToText(tmp)
end

local function auxTextsOfStep(step, includeAll)
  local out, seen = {}, {}
  if not step or not step.elements then
    return out
  end
  for _, el in ipairs(step.elements) do
    if not (el.t == "cmd" and el.tag == "goto") then
      if includeAll or hasWarn(el) then
        local text = elToText(el)
        if text and text ~= "" and not seen[text] then
          seen[text] = true
          table.insert(out, text)
        end
      end
    end
  end
  return out
end

local function auxStepSignature(step)
  if not step or not step.elements then
    return nil
  end
  local parts = {}
  for _, el in ipairs(step.elements) do
    if el.t == "cmd" then
      local tag = el.tag
      local id = tonumber(el.args and el.args[1])
      if (tag == "complete" or tag == "accept" or tag == "turnin") and id then
        table.insert(parts, tag .. ":" .. id .. ":" .. tostring(el.args[2] or ""))
      elseif tag == "collect" and id then
        table.insert(parts, "collect:" .. id)
      elseif
        (tag == "isOnQuest" or tag == "isQuestTurnedIn" or tag == "isQuestComplete" or tag == "isQuestAvailable") and id
      then
        table.insert(parts, tag .. ":" .. id)
      end
    end
  end
  if table.getn(parts) == 0 then
    return nil
  end
  table.sort(parts)
  return table.concat(parts, "|")
end

local function stepRowText(entry)
  local text = entry and entry.text or ""
  if not entry or entry.state == "note" or entry.state == "none" then
    return text
  end
  if entry.state == true then
    return stripAllColors(text)
  end
  if entry.state == false then
    return text
  end
  return stripAllColors(text)
end

local function markerText(entry)
  local text = entry and entry.text or ""
  if not entry or entry.state == "note" or entry.state == "none" then
    return text
  end
  if entry.state == true then
    return MARK_DONE .. text
  end
  if entry.state == false then
    return MARK_PENDING .. text
  end
  return MARK_UNKNOWN .. text
end

StepText.elToText = elToText
StepText.elToTextNoWarn = elToTextNoWarn
StepText.hasWarn = hasWarn
StepText.isAuxStep = isAuxStep
StepText.auxTextsOfStep = auxTextsOfStep
StepText.auxStepSignature = auxStepSignature
StepText.stepRowText = stepRowText
StepText.markerText = markerText
StepText.questNameFrom = questNameFrom
StepText.parseObjectiveComment = parseObjectiveComment
StepText.stripAllColors = stripAllColors
