-- non-destructive guide suggestions
local TG = _G.TurtleGuides

local function norm(s)
  s = string.lower(tostring(s or ""))
  return string.gsub(s, "[^%w]", "")
end

function TG:SuggestGuides()
  local player = self:PlayerInfo()
  local level = tonumber(player.level) or UnitLevel("player") or 1
  local here = norm(GetZoneText and GetZoneText() or "")
  local list = {}
  for _, guide in ipairs(self.guides or {}) do
    if self:GuideMatchesPlayer(guide, player) then
      local lo, hi = self:GuideLevelRange(guide)
      if lo and hi and level >= lo and level < math.max(hi, lo + 1) then
        local score, why = 0, {}
        if TG.defaultForMatches and TG.defaultForMatches(guide, player) then
          score = score + 5
          table.insert(why, "for your race/class")
        end
        local name = norm((guide.name or "") .. " " .. (guide.group or ""))
        if here ~= "" and string.find(name, here, 1, true) then
          score = score + 3
          table.insert(why, "in your zone")
        end
        if guide.category == "Turtle Survival" then
          score = score + 1
          table.insert(why, "Turtle guide")
        end
        score = score - (level - lo) * 0.1
        table.insert(list, { guide = guide, score = score, why = why, lo = lo, hi = hi })
      end
    end
  end
  if table.getn(list) == 0 then
    local best
    for _, guide in ipairs(self.guides or {}) do
      if self:GuideMatchesPlayer(guide, player) then
        local lo, hi = self:GuideLevelRange(guide)
        if lo and lo > level and (not best or lo < best.lo) then
          best = { guide = guide, score = 0, why = { "next level range" }, lo = lo, hi = hi }
        end
      end
    end
    if best then
      table.insert(list, best)
    end
  end
  table.sort(list, function(a, b)
    return a.score > b.score
  end)
  return list
end

function TG:PrintSuggestions()
  local player = self:PlayerInfo()
  local list = self:SuggestGuides()
  if table.getn(list) == 0 then
    self:Print("Suggested guide: none found for level " .. tostring(player.level) .. ".")
    return list
  end
  self:Print("Suggested guides for level " .. tostring(player.level) .. ":")
  for i = 1, math.min(3, table.getn(list)) do
    local suggestion = list[i]
    local why = table.getn(suggestion.why) > 0 and (", " .. table.concat(suggestion.why, ", ")) or ""
    self:Print(
      i
        .. ". "
        .. (suggestion.guide.group or "")
        .. " - "
        .. (suggestion.guide.name or "")
        .. " (levels "
        .. suggestion.lo
        .. "-"
        .. suggestion.hi
        .. why
        .. ")"
    )
  end
  self:Print("Use /tg guides to load one. Nothing was switched automatically.")
  return list
end
