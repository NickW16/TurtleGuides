-- formats guide elements and wraps plain lines for the compact windows
local TG = _G.TurtleGuides
local Icons = TG.UI.Icons
local trim = TG.Util.strtrim
local Text = {}
TG.UI = TG.UI or {}
TG.UI.Text = Text

local function strip(text)
  if not text or text == "" then
    return ""
  end
  if TG.cleanRxpColors then
    text = TG.cleanRxpColors(text)
  end
  text = string.gsub(text, "|T.-|t", "")
  text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
  text = string.gsub(text, "|cRXP_%w+_", "")
  text = string.gsub(text, "|r", "")
  return trim(text)
end

Text.strip = strip

local ITEM_COLOR = "|cffffd100"

local function display(text)
  if not text or text == "" then
    return ""
  end
  if TG.cleanRxpColors then
    text = TG.cleanRxpColors(text)
  end
  text = string.gsub(text, "|T.-|t", "")
  text = string.gsub(text, "%[([^%]]+)%]", function(name)
    if string.find(name, "|cff", 1, true) or string.find(name, "|cRXP_", 1, true) then
      return "[" .. name .. "]"
    end
    if not string.find(name, "%a") then
      return "[" .. name .. "]"
    end
    return "[" .. ITEM_COLOR .. name .. "|r]"
  end)
  return trim(text)
end

local function colorName(name, color)
  if not name or name == "" then
    return name
  end
  if string.find(name, "|cff", 1, true) or string.find(name, "|cRXP_", 1, true) then
    return name
  end
  return color .. name .. "|r"
end

local function questName(id, text)
  local name = strip(text)
  name = string.gsub(name, "^Accept%s+", "")
  name = string.gsub(name, "^Turn in%s+", "")
  name = string.gsub(name, "^Turn In%s+", "")
  name = string.gsub(name, "^Complete%s+", "")
  name = trim(name)
  if name ~= "" then
    return name
  end
  local num = tonumber(id)
  if num and TG.GetQuestTitleById then
    local title = TG:GetQuestTitleById(num)
    if title and title ~= "" then
      return title
    end
  end
  return "Quest " .. tostring(id or "?")
end

local function itemName(id, text)
  local name = strip(text)
  if name ~= "" then
    return name
  end
  local num = tonumber(id)
  if num and TG.GetItemNameById then
    name = TG:GetItemNameById(num) or ""
  end
  if name == "" and num and GetItemInfo then
    name = GetItemInfo(num) or ""
  end
  if name == "" then
    name = "Item #" .. tostring(id or "?")
  end
  return name
end

local function countText(have, need)
  local value = math.min(have or 0, need or 0)
  return value .. "/" .. tostring(need or 0)
end

local function questObjectiveProgress(el)
  local objNum = tonumber(el.args and el.args[2])
  if not objNum then
    return nil
  end
  local title, id
  if TG.ResolveQuestTitle then
    title, id = TG:ResolveQuestTitle(el)
  end
  local objectives
  if title and TG.GetQuestObjectives then
    objectives = TG:GetQuestObjectives(title)
  end
  if (not objectives or not objectives[objNum]) and id and TG.GetQuestObjectivesById then
    objectives = TG:GetQuestObjectivesById(id)
  end
  local objective = objectives and objectives[objNum]
  local logHave, logNeed = string.match(objective and objective.text or "", "(%d+)%s*/%s*(%d+)")
  logHave, logNeed = tonumber(logHave), tonumber(logNeed)
  local bagHave, bagNeed
  if TG.GetObjectiveItemProgress then
    bagHave, bagNeed = TG:GetObjectiveItemProgress(el)
  end
  if bagHave and bagNeed then
    if logHave and logNeed then
      return math.max(logHave, bagHave), logNeed
    end
    return bagHave, bagNeed
  end
  if not logHave then
    return nil
  end
  return logHave, logNeed
end

local function withObjectiveProgress(text, el)
  local have, need = questObjectiveProgress(el)
  local guideNeed = tonumber(string.match(strip(text), "%(x?(%d+)%)"))
  need = need or guideNeed
  if not need then
    return text
  end
  have = math.min(have or 0, need)
  if el and el._tgManualDone then
    have = need
  end
  local progress = "(" .. have .. "/" .. need .. ")"
  local pattern
  if string.find(text, "%(x%d+%)") then
    pattern = "%(x%d+%)"
  elseif string.find(text, "%(%d+%)") then
    pattern = "%(%d+%)"
  end
  if pattern then
    return string.gsub(text, pattern, progress, 1)
  end
  return text .. "  " .. progress
end

function Text.element(el)
  if not el then
    return nil
  end
  if el.t == "text" then
    local text = display(el.text)
    return text ~= "" and text or nil
  end
  if el.t ~= "cmd" then
    return nil
  end
  local tag = el.tag or ""
  local args = el.args or {}
  local inline = display(el.text)
  if tag == "target" or tag == "mob" or tag == "kill" then
    return inline ~= "" and inline or nil
  end
  if tag == "train" or tag == "trainer" then
    return inline ~= "" and inline or nil
  end
  if tag == "collect" then
    local id = tonumber(args[1])
    local need = tonumber(args[2]) or 1
    local have = (id and TG.GetItemCount) and TG:GetItemCount(id) or 0
    return "Collect: " .. colorName(itemName(id, el.text), ITEM_COLOR) .. "  " .. countText(have, need)
  end
  if inline ~= "" then
    return inline
  end
  if tag == "accept" then
    return "Accept: " .. questName(args[1])
  elseif tag == "turnin" then
    return "Turn in: " .. questName(args[1])
  elseif tag == "complete" then
    if el.objectiveText and strip(el.objectiveText) ~= "" then
      return withObjectiveProgress(display(el.objectiveText), el)
    end
    return "Complete: " .. questName(args[1])
  elseif tag == "itemcount" then
    return "Have: " .. colorName(itemName(args[1]), ITEM_COLOR)
  elseif tag == "xp" then
    local level = tonumber(args[1])
    if TG.ParseXpArg then
      local _, parsedLevel = TG:ParseXpArg(args[1])
      level = parsedLevel or level
    end
    return level and ("Reach level " .. level) or "Gain experience"
  elseif tag == "hs" or tag == "hearth" then
    return "Hearthstone"
  elseif tag == "fly" or tag == "f" then
    return "Fly: " .. table.concat(args, " ")
  elseif tag == "home" then
    return "Set hearthstone"
  elseif tag == "vendor" then
    return "Vendor"
  elseif tag == "use" or tag == "destroy" then
    local label = (tag == "use") and "Use: " or "Destroy: "
    return label .. colorName(itemName(args[1]), ITEM_COLOR)
  end
  return nil
end

function Text.entries(step)
  local out = {}
  if not step then
    return out
  end
  local function add(text, state, el, element)
    if text and text ~= "" then
      local raw = element and element.text or text
      local contentIcons = Icons.contents(text)
      local contentIcon = contentIcons[1] and contentIcons[1].texture or Icons.content(raw)
      local icon = (element and Icons.forElement(element)) or Icons.forText(text)
      if element and element.t == "cmd" and element.tag == "complete" then
        icon = nil
      end
      local previous = out[table.getn(out)]
      local iconColor
      if icon == Icons.COMPLETE_ICON then
        iconColor = Icons.COMPLETE_COLOR
      end
      local child = false
      local plainText = strip(text)
      local prevPlain = previous and strip(previous.text) or ""
      if previous and (string.sub(prevPlain, -1) == ":" or previous.child) and string.sub(plainText, 1, 1) == "[" then
        child = true
      end
      table.insert(out, {
        text = text,
        state = state,
        el = el,
        icon = icon,
        iconColor = iconColor,
        contentIcon = contentIcon,
        contentIcons = contentIcons,
        bulletIcon = icon and Icons.isBullet(icon) or false,
        child = child,
      })
    end
  end
  local elements = step.elements or {}
  if step.sticky or step.completewith then
    local seen = {}
    for _, el in ipairs(elements) do
      local elText = Text.element(el)
      local key = strip(elText)
      if elText and key ~= "" and not seen[key] then
        seen[key] = true
        local trackable = TG.IsElementTrackable and TG:IsElementTrackable(el) or false
        local state = "note"
        if trackable then
          state = TG.IsElementDone and TG:IsElementDone(el) or false
        end
        add(elText, state, trackable and el or nil, el)
      end
    end
  else
    local hasOther = false
    for _, el in ipairs(elements) do
      if not (el.t == "cmd" and el.tag == "goto") and Text.element(el) then
        hasOther = true
      end
    end
    for _, el in ipairs(elements) do
      local isGoto = el.t == "cmd" and el.tag == "goto"
      if not isGoto or not hasOther then
        local elText = Text.element(el)
        if elText then
          local trackable = TG.IsElementTrackable and TG:IsElementTrackable(el) or false
          local state = "note"
          if trackable then
            state = TG.IsElementDone and TG:IsElementDone(el) or false
          end
          add(elText, state, trackable and el or nil, el)
        end
      end
    end
  end
  if table.getn(out) == 0 then
    for _, el in ipairs(elements) do
      if el.t == "cmd" then
        local text = Text.element(el)
        if text then
          add(text, "note", nil, el)
          break
        end
      end
    end
  end
  if table.getn(out) == 0 then
    for _, el in ipairs(elements) do
      if el.t == "cmd" and el.tag == "goto" and el.args and el.args[1] then
        add("Go to " .. tostring(el.args[1]), "note", nil, el)
        break
      end
    end
  end
  return out
end

local fontStrings = {}

function Text.size(base)
  local scale = tonumber(TG.db and TG.db.fontScale) or 1.0
  return math.max(8, math.floor((base or 10) * scale + 0.5))
end

function Text.applyFont(fs, base)
  if fs then
    fs:SetFont(STANDARD_TEXT_FONT, Text.size(base), "")
  end
  return fs
end

function Text.register(fs, base)
  Text.applyFont(fs, base)
  table.insert(fontStrings, { fs = fs, base = base or 10 })
  return fs
end

function Text.refresh()
  Text.widthCache = {}
  for _, entry in ipairs(fontStrings) do
    Text.applyFont(entry.fs, entry.base)
  end
end

local measureFont

local function getMeasureFont()
  if not measureFont then
    local holder = CreateFrame("Frame", nil, UIParent)
    holder:Hide()
    measureFont = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Text.applyFont(measureFont, 10)
  end
  return measureFont
end

local function stripCodes(text)
  if not text or text == "" then
    return ""
  end
  text = string.gsub(text, "|cRXP_%w+_", "")
  text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
  text = string.gsub(text, "|r", "")
  text = string.gsub(text, "|T.-|t", "")
  return text
end

local measureSize = 10
Text.widthCache = {}

local function widthOf(font, text)
  local measured = stripCodes(text)
  local key = tostring(measureSize) .. "|" .. measured
  local cached = Text.widthCache[key]
  if cached then
    return cached
  end
  font:SetText(measured)
  local value
  if font.GetStringWidth then
    value = font:GetStringWidth() or 0
  else
    value = string.len(measured) * 5
  end
  Text.widthCache[key] = value
  return value
end

local function splitLines(text)
  local lines = {}
  local start = 1
  while true do
    local s, e = string.find(text, "\n", start)
    if not s then
      table.insert(lines, string.sub(text, start))
      break
    end
    table.insert(lines, string.sub(text, start, s - 1))
    start = e + 1
  end
  return lines
end

local function wordsOf(text)
  local words = {}
  local pos = 1
  local length = string.len(text)
  while pos <= length do
    local s, e = string.find(text, "%S+%s*", pos)
    if not s then
      break
    end
    table.insert(words, string.sub(text, s, e))
    pos = e + 1
  end
  return words
end

local function charsOf(text)
  local chars = {}
  for i = 1, string.len(text) do
    table.insert(chars, string.sub(text, i, i))
  end
  return chars
end

local function wrapSegment(font, segment, maxWidth, result)
  local words = wordsOf(segment)
  if table.getn(words) == 0 then
    table.insert(result, "")
    return
  end
  local current = ""
  for _, word in ipairs(words) do
    local candidate = current .. word
    if widthOf(font, candidate) <= maxWidth then
      current = candidate
    else
      if current ~= "" then
        table.insert(result, current)
      end
      if widthOf(font, word) <= maxWidth then
        current = word
      else
        local chunk = ""
        for _, ch in ipairs(charsOf(stripCodes(word))) do
          local nextChunk = chunk .. ch
          if chunk ~= "" and widthOf(font, nextChunk) > maxWidth then
            table.insert(result, chunk)
            chunk = ch
          else
            chunk = nextChunk
          end
        end
        current = chunk
      end
    end
  end
  if current ~= "" then
    table.insert(result, current)
  end
end

function Text.wrap(text, maxWidth, fontSize)
  local font = getMeasureFont()
  measureSize = fontSize or 10
  Text.applyFont(font, measureSize)
  local plain = Icons.clean(text)
  if plain == "" then
    return "", 1
  end
  local displayText = text or ""
  displayText = string.gsub(displayText, "|T.-|t", "")
  if not maxWidth or maxWidth < 1 then
    return trim(displayText), 1
  end
  local result = {}
  for _, segment in ipairs(splitLines(displayText)) do
    wrapSegment(font, segment, maxWidth, result)
  end
  if table.getn(result) == 0 then
    table.insert(result, "")
  end
  return table.concat(result, "\n"), table.getn(result)
end

function Text.width(text, fontSize)
  local font = getMeasureFont()
  Text.applyFont(font, fontSize or 10)
  font:SetText(Icons.measure(text))
  return (font.GetStringWidth and font:GetStringWidth()) or 0
end

function Text.lineHeight(fontSize)
  local font = getMeasureFont()
  local size = Text.size(fontSize or 10)
  Text.applyFont(font, fontSize or 10)
  font:SetText("X")
  local height = font.GetStringHeight and font:GetStringHeight() or 0
  return math.max(height, size + 3)
end
