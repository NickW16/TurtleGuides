-- guide registry, categories, and picker data
local TG = _G.TurtleGuides
local gmatch = string.gmatch

local function norm(s)
  s = string.lower(tostring(s or ""))
  return string.gsub(s, "[^%w]", "")
end

local function findRange(s)
  local _, _, lo, hi = string.find(s or "", "(%d+)%s*%-%s*(%d+)")
  if lo then
    return tonumber(lo), tonumber(hi)
  end
  return nil, nil
end

function TG:GuideLevelRange(guide)
  local lo, hi = findRange(guide and guide.name)
  if not lo then
    lo, hi = findRange(guide and guide.group)
  end
  if lo and hi then
    return lo, hi
  end
  local _, _, single = string.find((guide and guide.name) or "", "^%s*(%d+)")
  if single then
    local level = tonumber(single)
    return level, level
  end
  return nil, nil
end

local function defaultForMatches(guide, player)
  local metadata = guide.meta or {}
  local df = metadata.defaultfor or metadata.defaultFor or guide.defaultFor
  if not df or df == "" then
    return false
  end
  local race, class = norm(player.race), norm(player.class)
  for token in gmatch(tostring(df), "[^/]+") do
    local value = norm(token)
    if value == race or value == class then
      return true
    end
    if (value == "scourge" and race == "undead") or (value == "undead" and race == "scourge") then
      return true
    end
  end
  return false
end

TG.defaultForMatches = defaultForMatches

function TG:GuideMatchesPlayer(guide, player)
  if not guide then
    return false
  end
  if guide.faction and guide.faction ~= "Neutral" and player.faction and guide.faction ~= player.faction then
    return false
  end
  local metadata = guide.meta or {}
  local df = metadata.defaultfor or metadata.defaultFor or guide.defaultFor
  if df and df ~= "" and not defaultForMatches(guide, player) then
    return false
  end
  return true
end

local function categoryFor(guide)
  local group = string.lower(guide.group or "")
  local name = string.lower(guide.name or "")
  if string.find(group, "turtle") or string.find(name, "turtle") then
    return "Turtle Survival"
  end
  if string.find(group, "survival") or string.find(name, "survival") then
    return "Survival"
  end
  if string.find(group, "speedrun") or string.find(name, "speedrun") then
    return "Speedrun"
  end
  if string.find(group, "%d+%-%d+") or string.find(name, "%d+%-%d+") then
    if string.find(group, "endgame") or string.find(group, "profession") or string.find(group, "attune") then
      return "Other (Classic)"
    end
    return "Speedrun"
  end
  return "Other (Classic)"
end

local function factionOf(guide)
  local metadata = guide.meta or {}
  local text = (guide.group or "")
    .. " "
    .. (guide.name or "")
    .. " "
    .. (metadata.defaultfor or metadata.defaultFor or "")
  if string.find(text, "Alliance") or string.find(text, "%(A%)") then
    return "Alliance"
  end
  if string.find(text, "Horde") or string.find(text, "%(H%)") then
    return "Horde"
  end
  if
    string.find(text, "NightElf")
    or string.find(text, "Human")
    or string.find(text, "Dwarf")
    or string.find(text, "Gnome")
  then
    return "Alliance"
  end
  if
    string.find(text, "Orc")
    or string.find(text, "Troll")
    or string.find(text, "Tauren")
    or string.find(text, "Undead")
    or string.find(text, "Scourge")
  then
    return "Horde"
  end
  return "Neutral"
end

function TG:BuildIndexWith(parseFn)
  self.guides = {}
  self.guideByKey = {}
  self.categories = {
    ["Speedrun"] = {},
    ["Survival"] = {},
    ["Turtle Survival"] = {},
    ["Other (Classic)"] = {},
  }
  for _, entry in ipairs(self.rawGuides or {}) do
    local guide = parseFn(entry.text, entry.source)
    if guide and guide.isClassic then
      guide.category = categoryFor(guide)
      guide.faction = factionOf(guide)
      local key = guide.key
      if self.guideByKey[key] then
        local suffix = 2
        while self.guideByKey[key .. "#" .. suffix] do
          suffix = suffix + 1
        end
        key = key .. "#" .. suffix
        guide.key = key
      end
      table.insert(self.guides, guide)
      self.guideByKey[key] = guide
      if not self.categories[guide.category] then
        self.categories[guide.category] = {}
      end
      table.insert(self.categories[guide.category], guide)
    end
  end

  local function startLevel(name)
    if not name then
      return 999
    end
    local _, _, level = string.find(name, "(%d+)%-%d+")
    if level then
      return tonumber(level) or 999
    end
    local _, _, single = string.find(name, "^(%d+)")
    if single then
      return tonumber(single) or 999
    end
    return 999
  end
  local function sortGuides(a, b)
    local groupA, groupB = a.group or "", b.group or ""
    if groupA ~= groupB then
      return groupA < groupB
    end
    local levelA, levelB = startLevel(a.name), startLevel(b.name)
    if levelA ~= levelB then
      return levelA < levelB
    end
    return (a.name or "") < (b.name or "")
  end
  for _, list in pairs(self.categories) do
    table.sort(list, sortGuides)
  end
  table.sort(self.guides, sortGuides)
end

function TG:BuildGuideIndex()
  self:BuildIndexWith(self.Parser.ParseGuide)
end

function TG:GetGuidesForPicker()
  local player = self:PlayerInfo()
  local out = {}
  local order = { "Speedrun", "Survival", "Turtle Survival", "Other (Classic)" }
  for _, category in ipairs(order) do
    local items = {}
    for _, guide in ipairs(self.categories[category] or {}) do
      local show = true
      if guide.faction == "Alliance" and player.faction == "Horde" then
        show = false
      end
      if guide.faction == "Horde" and player.faction == "Alliance" then
        show = false
      end
      if show then
        table.insert(items, guide)
      end
    end
    if table.getn(items) > 0 or category == "Speedrun" or category == "Survival" or category == "Turtle Survival" then
      table.insert(out, { name = category, guides = items })
    end
  end
  local suggested = self.SuggestGuides and self:SuggestGuides() or {}
  if table.getn(suggested) > 0 then
    local recommended = {}
    for i = 1, math.min(3, table.getn(suggested)) do
      table.insert(recommended, suggested[i].guide)
    end
    table.insert(out, 1, { name = "Recommended for you", guides = recommended })
  end
  return out
end
