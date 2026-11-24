-- deterministic text wrapping and height measurement for the 1.12 client
local TG = _G.TurtleGuides
local TextWrap = {}
TG.UI.TextWrap = TextWrap

local measureFont

local function stripCodes(text)
  text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
  text = string.gsub(text, "|H.-|h", "")
  text = string.gsub(text, "|h", "")
  text = string.gsub(text, "|r", "")
  return text
end

local function getMeasureFont()
  if measureFont then
    return measureFont
  end
  local holder = CreateFrame("Frame", nil, UIParent)
  holder:Hide()
  measureFont = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  measureFont:SetFont(STANDARD_TEXT_FONT, 10)
  if measureFont.SetNonSpaceWrap then
    measureFont:SetNonSpaceWrap(true)
  end
  return measureFont
end

local function measure(text)
  local font = getMeasureFont()
  local plain = stripCodes(text)
  font:SetText(plain)
  if not font.GetStringWidth then
    return string.len(plain) * 5
  end
  return font:GetStringWidth() or 0
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
    local s, e = string.find(text, "%S+", pos)
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

local function wrapSegment(segment, maxWidth)
  local words = wordsOf(segment)
  if table.getn(words) == 0 then
    return { "" }
  end
  local lines, current = {}, ""
  for _, word in ipairs(words) do
    local candidate = (current == "") and word or (current .. " " .. word)
    if measure(candidate) <= maxWidth then
      current = candidate
    else
      if current ~= "" then
        table.insert(lines, current)
      end
      if measure(word) <= maxWidth then
        current = word
      else
        local chunk = ""
        for _, ch in ipairs(charsOf(word)) do
          local nextChunk = chunk .. ch
          if chunk ~= "" and measure(nextChunk) > maxWidth then
            table.insert(lines, chunk)
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
    table.insert(lines, current)
  end
  if table.getn(lines) == 0 then
    table.insert(lines, "")
  end
  return lines
end

function TextWrap.wrap(text, maxWidth, fontSize)
  local font = getMeasureFont()
  font:SetFont(STANDARD_TEXT_FONT, fontSize or 10, "")
  if not text or text == "" then
    return "", 1
  end
  if not maxWidth or maxWidth < 1 then
    return text, 1
  end
  local result = {}
  for _, segment in ipairs(splitLines(text)) do
    for _, line in ipairs(wrapSegment(segment, maxWidth)) do
      table.insert(result, line)
    end
  end
  return table.concat(result, "\n"), table.getn(result)
end

function TextWrap.lineHeight(fontSize)
  local size = fontSize or 10
  local font = getMeasureFont()
  font:SetFont(STANDARD_TEXT_FONT, size, "")
  font:SetText("X")
  local height = font.GetStringHeight and font:GetStringHeight() or nil
  -- keep a safe minimum because 1.12 line height excludes spacing
  return math.max(height or 0, size + 4)
end

function TextWrap.wrapAndHeight(text, maxWidth, fontSize)
  local wrapped, lines = TextWrap.wrap(text, maxWidth, fontSize)
  return wrapped, math.ceil(lines * TextWrap.lineHeight(fontSize))
end
