-- parses a single guide line into an element
local TG = _G.TurtleGuides
local Applies = TG.Parser.Applies
local Context = TG.Parser.Context
local strtrim = TG.Util.strtrim
local gmatch = string.gmatch

local TAG_ALIASES = {
  ["goto"] = "goto",
  accept = "accept",
  turnin = "turnin",
  ["turnin!"] = "turnin",
  complete = "complete",
  ["complete!"] = "complete",
  collect = "collect",
  xp = "xp",
  grind = "grind",
  loop = "loop",
  hs = "hs",
  hearth = "hs",
  home = "home",
  fly = "fly",
  f = "fly",
  vendor = "vendor",
  trainer = "train",
  train = "train",
  use = "use",
  target = "mob",
  mob = "mob",
  kill = "mob",
  money = "money",
  isonquest = "isOnQuest",
  isnotonquest = "isNotOnQuest",
  isquestturnedin = "isQuestTurnedIn",
  isquestavailable = "isQuestAvailable",
  isquestcomplete = "isQuestComplete",
}

local REVERSE_TAGS = {
  isquestnotcomplete = "isQuestComplete",
  isquestnotavailable = "isQuestAvailable",
}

local QUEST_ID_TAGS = {
  accept = true,
  turnin = true,
  complete = true,
  collect = true,
}

local QUEST_CONDITION_TAGS = {
  isOnQuest = true,
  isNotOnQuest = true,
  isQuestTurnedIn = true,
  isQuestAvailable = true,
  isQuestComplete = true,
}

function TG.Parser.applies(text)
  return Applies.evaluate(text, Context.player())
end

function TG.Parser.parseApplies(text, ctx)
  return Applies.evaluate(text, ctx or Context.player())
end

local function parseArgs(argstr)
  local args = {}
  if not argstr then
    return args
  end
  for arg in gmatch(argstr, "[^,]+") do
    table.insert(args, strtrim(arg))
  end
  return args
end

local function addQuestId(ids, value, skipIfMissing)
  local id = tonumber(value)
  if not id then
    return false
  end
  if id < 0 then
    skipIfMissing.value = true
    id = -id
  end
  table.insert(ids, id)
  return true
end

local function parseQuestMetadata(el, tag, args, sourceTag)
  local ids = {}
  local skipIfMissing = { value = false }
  local reverse = false
  local tlow = string.lower(tag)

  if REVERSE_TAGS[tlow] then
    tag = REVERSE_TAGS[tlow]
    reverse = true
  elseif tag == "collect" then
    if args[3] then
      addQuestId(ids, args[3], skipIfMissing)
    end
  elseif QUEST_ID_TAGS[tlow] and args[1] then
    addQuestId(ids, args[1], skipIfMissing)
  elseif QUEST_CONDITION_TAGS[tag] then
    for _, arg in ipairs(args) do
      local low = string.lower(tostring(arg))
      if low == "reverse" or low == "!" then
        reverse = true
      elseif low == "skip" then
        skipIfMissing.value = true
      else
        addQuestId(ids, arg, skipIfMissing)
      end
    end
  end

  if string.sub(sourceTag, -1) == "!" then
    skipIfMissing.value = true
  end

  el.tag = tag
  el.questIds = ids
  el.skipIfMissing = skipIfMissing.value
  el.reverse = reverse
end

function TG.Parser.parseElementLine(line, commentText)
  line = strtrim(line)
  if line == "" then
    return nil
  end

  local cond
  local base = line
  local cpos = string.find(line, "<<", 1, true)
  if cpos then
    cond = strtrim(string.sub(line, cpos + 2))
    base = strtrim(string.sub(line, 1, cpos - 1))
  end
  if cond == "" then
    cond = nil
  end
  if cond and not TG.Parser.applies(cond) then
    return false
  end

  if string.sub(base, 1, 1) == "." then
    local _, _, tag, rest = string.find(base, "^%.(%S+)%s*(.*)$")
    tag = tag or ""
    rest = rest or ""
    local tlow = string.lower(tag)
    local sourceTag = tlow
    if not REVERSE_TAGS[tlow] then
      tag = TAG_ALIASES[tlow] or tag
    end

    local textInline, objectiveText
    local ppos = string.find(rest, ">>", 1, true)
    if ppos then
      textInline = strtrim(string.sub(rest, ppos + 2))
      rest = strtrim(string.sub(rest, 1, ppos - 1))
    end
    if commentText and commentText ~= "" and (tlow == "complete" or tlow == "collect" or tlow == "itemcount") then
      objectiveText = commentText
    end
    local el = {
      t = "cmd",
      tag = tag,
      sourceTag = sourceTag,
      args = parseArgs(rest),
      text = textInline,
      objectiveText = objectiveText,
      cond = cond,
    }
    parseQuestMetadata(el, tag, el.args, sourceTag)
    return el
  end

  if string.sub(base, 1, 1) == "#" then
    local _, _, key, value = string.find(base, "^#(%S+)%s*(.*)$")
    return { t = "tag", key = key or "", value = strtrim(value or ""), cond = cond }
  end

  if string.sub(base, 1, 2) == ">>" then
    return { t = "text", text = strtrim(string.sub(base, 3)), cond = cond }
  end
  if string.sub(base, 1, 1) == "+" then
    return { t = "text", text = strtrim(string.sub(base, 2)), kind = "note", cond = cond }
  end
  if string.sub(base, 1, 1) == "*" then
    return { t = "text", text = strtrim(string.sub(base, 2)), kind = "info", cond = cond }
  end
  return { t = "text", text = base, cond = cond }
end
