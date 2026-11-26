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
    tag = TAG_ALIASES[tlow] or tag

    local textInline, objectiveText
    local ppos = string.find(rest, ">>", 1, true)
    if ppos then
      textInline = strtrim(string.sub(rest, ppos + 2))
      rest = strtrim(string.sub(rest, 1, ppos - 1))
    end
    if commentText and commentText ~= "" and (tlow == "complete" or tlow == "collect" or tlow == "itemcount") then
      objectiveText = commentText
    end
    return {
      t = "cmd",
      tag = tag,
      sourceTag = sourceTag,
      args = parseArgs(rest),
      text = textInline,
      objectiveText = objectiveText,
      cond = cond,
    }
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
