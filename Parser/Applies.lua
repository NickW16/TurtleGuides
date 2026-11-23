-- evaluates guide applicability expressions against an explicit player context
local TG = _G.TurtleGuides
local Applies = {}
TG.Parser = TG.Parser or {}
TG.Parser.Applies = Applies

local strtrim = TG.Util.strtrim
local gmatch = string.gmatch

local LATER_GAMES = {
  TBC = true,
  WOTLK = true,
  CATA = true,
  MOP = true,
  RETAIL = true,
  DF = true,
  SOD = true,
  SOM = true,
  ERA = false,
}

local function evalToken(tok, ctx)
  if tok == "" then
    return true
  end
  local neg = false
  if string.sub(tok, 1, 1) == "!" then
    neg = true
    tok = string.sub(tok, 2)
  end
  local up = string.upper(tok)
  local res = false
  local num = tonumber(tok)
  if num then
    res = ctx.level ~= nil and ctx.level >= num
  elseif up == "CLASSIC" or up == "ERA" or up == "VANILLA" then
    res = true
  elseif LATER_GAMES[up] then
    res = false
  elseif up == "ALLIANCE" or up == "HORDE" or up == "NEUTRAL" then
    res = ctx.faction == tok or ctx.faction == string.sub(up, 1, 1) .. string.lower(string.sub(up, 2))
    if ctx.faction == "Alliance" and up == "ALLIANCE" then
      res = true
    end
    if ctx.faction == "Horde" and up == "HORDE" then
      res = true
    end
  elseif up == ctx.class then
    res = true
  elseif tok == ctx.race or up == string.upper(ctx.race or "") or tok == ctx.race2 then
    res = true
  elseif up == "MALE" then
    res = ctx.sex == 2
  elseif up == "FEMALE" then
    res = ctx.sex == 3
  elseif up == "HARDCORE" then
    res = false
  end
  if neg then
    return not res
  end
  return res
end

function Applies.evaluate(text, ctx)
  if not text or strtrim(text) == "" then
    return true
  end
  ctx = ctx or {}
  text = " " .. text .. " "
  local prev
  for _ = 1, 10 do
    prev = text
    text = string.gsub(text, "(!?)%(%s*(.-)%s*%)", function(op, inner)
      local value = Applies.evaluate(inner, ctx)
      if op == "!" then
        value = not value
      end
      return value and " CLASSIC " or " __NO__ "
    end)
    if text == prev then
      break
    end
  end
  for part in gmatch(text, "[^/]+") do
    local all = true
    local anyTok = false
    for tok in gmatch(part, "[^%s]+") do
      if tok ~= "" then
        anyTok = true
        if not evalToken(tok, ctx) then
          all = false
          break
        end
      end
    end
    if anyTok and all then
      return true
    end
  end
  return false
end
