-- formats guide elements and wraps plain lines for the compact windows
local TG = _G.TurtleGuides
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

function Text.element(el)
  if not el then
    return nil
  end
  if el.t == "text" then
    local text = strip(el.text)
    return text ~= "" and text or nil
  end
  if el.t ~= "cmd" then
    return nil
  end
  local tag = el.tag or ""
  local args = el.args or {}
  local text = strip(el.text)
  if tag == "accept" then
    return "Accept: " .. questName(args[1], el.text)
  elseif tag == "turnin" then
    return "Turn in: " .. questName(args[1], el.text)
  elseif tag == "complete" then
    if text ~= "" then
      return "Complete: " .. text
    end
    if el.objectiveText and strip(el.objectiveText) ~= "" then
      return "Complete: " .. strip(el.objectiveText)
    end
    return "Complete: " .. questName(args[1], el.text)
  elseif tag == "collect" then
    local id = tonumber(args[1])
    local need = tonumber(args[2]) or 1
    local have = (id and TG.GetItemCount) and TG:GetItemCount(id) or 0
    return "Collect: " .. itemName(id, el.text) .. " " .. countText(have, need)
  elseif tag == "itemcount" then
    if text ~= "" then
      return "Have: " .. text
    end
    return "Have: " .. itemName(args[1])
  elseif tag == "goto" then
    return text ~= "" and text or nil
  elseif tag == "xp" then
    local level = tonumber(args[1])
    if text ~= "" then
      return text
    end
    if TG.ParseXpArg then
      local _, parsedLevel = TG:ParseXpArg(args[1])
      level = parsedLevel or level
    end
    return level and ("Reach level " .. level) or "Gain experience"
  elseif tag == "hs" or tag == "hearth" then
    return text ~= "" and ("Hearth: " .. text) or "Hearthstone"
  elseif tag == "fly" or tag == "f" then
    return "Fly: " .. (text ~= "" and text or table.concat(args, " "))
  elseif tag == "home" then
    return "Set hearthstone" .. (text ~= "" and (": " .. text) or "")
  elseif tag == "vendor" then
    return "Vendor" .. (text ~= "" and (": " .. text) or "")
  elseif tag == "trainer" or tag == "train" then
    if text == "" then
      local spellId = tonumber(args[1])
      if spellId and GetSpellInfo then
        text = GetSpellInfo(spellId) or ""
      end
    end
    return "Train: " .. (text ~= "" and text or ("Spell " .. tostring(args[1] or "?")))
  elseif tag == "use" or tag == "destroy" then
    local label = (tag == "use") and "Use: " or "Destroy: "
    return label .. itemName(args[1], el.text)
  elseif tag == "cast" or tag == "link" then
    return text ~= "" and text or nil
  end
  return text ~= "" and text or nil
end

function Text.entries(step)
  local out = {}
  if not step then
    return out
  end
  local function add(text, state, el)
    if text and text ~= "" then
      table.insert(out, { text = text, state = state, el = el })
    end
  end
  local elements = step.elements or {}
  if step.sticky or step.completewith then
    for _, el in ipairs(elements) do
      if not (el.t == "cmd" and el.tag == "goto") then
        add(Text.element(el), "note")
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
          local trackable = el.t == "cmd" and TG.IsElementTrackable and TG:IsElementTrackable(el) or false
          local state = trackable and TG:IsElementDone(el) or "note"
          add(elText, state, trackable and el or nil)
        end
      end
    end
  end
  if table.getn(out) == 0 then
    add("Continue", "note")
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

local function widthOf(font, text)
  font:SetText(text)
  if font.GetStringWidth then
    return font:GetStringWidth() or 0
  end
  return string.len(text) * 5
end

local function wrapLine(font, text, maxWidth, result)
  local current = ""
  for word in string.gmatch(text, "%S+") do
    local candidate = (current == "") and word or (current .. " " .. word)
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
        for i = 1, string.len(word) do
          local char = string.sub(word, i, i)
          local nextChunk = chunk .. char
          if chunk ~= "" and widthOf(font, nextChunk) > maxWidth then
            table.insert(result, chunk)
            chunk = char
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
  Text.applyFont(font, fontSize or 10)
  local plain = strip(text)
  if plain == "" then
    return "", 1
  end
  if not maxWidth or maxWidth < 1 then
    return plain, 1
  end
  local result = {}
  for line in string.gmatch(plain .. "\n", "([^\n]*)\n") do
    wrapLine(font, line, maxWidth, result)
  end
  if table.getn(result) == 0 then
    table.insert(result, "")
  end
  return table.concat(result, "\n"), table.getn(result)
end

function Text.lineHeight(fontSize)
  local font = getMeasureFont()
  local size = Text.size(fontSize or 10)
  Text.applyFont(font, fontSize or 10)
  font:SetText("X")
  local height = font.GetStringHeight and font:GetStringHeight() or 0
  return math.max(height, size + 3)
end
