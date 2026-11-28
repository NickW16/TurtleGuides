-- quest prerequisite hints
local TG = _G.TurtleGuides
local Prereqs = {}
TG.Engine.Prereqs = Prereqs

local function questTitle(self, id)
  if not id then
    return nil
  end
  local title = self.GetQuestTitleById and self:GetQuestTitleById(id)
  if title and title ~= "" then
    return title
  end
  local loc = pfDB and pfDB.quests and pfDB.quests.loc
  local entry = loc and loc[id]
  if type(entry) == "string" and entry ~= "" then
    return entry
  end
  if type(entry) == "table" then
    local value = entry.T or entry.t or entry[1]
    if type(value) == "string" and value ~= "" then
      return value
    end
  end
  return "#" .. tostring(id)
end

function Prereqs.missing(self, id)
  local numeric = tonumber(id)
  if not numeric then
    return {}
  end
  local data = pfDB and pfDB.quests and pfDB.quests.data and pfDB.quests.data[numeric]
  if type(data) ~= "table" then
    return {}
  end
  local missing = {}
  for _, raw in pairs(data.pre or {}) do
    local preId = tonumber(raw)
    if preId then
      local evidence = self.GetQuestEvidence and self:GetQuestEvidence(preId)
      local done = evidence and (evidence.turnedIn == true or (evidence.inLog == true and evidence.complete == true))
        or false
      if pfQuest_history and pfQuest_history[preId] then
        done = true
      end
      if not done then
        table.insert(missing, { id = preId, title = questTitle(self, preId) })
      end
    end
  end
  if data.min then
    local need = tonumber(data.min)
    local level = UnitLevel and UnitLevel("player") or 0
    if need and level < need then
      table.insert(missing, { level = need })
    end
  end
  table.sort(missing, function(a, b)
    return tostring(a.title or a.level) < tostring(b.title or b.level)
  end)
  return missing
end

function TG:GetMissingPrerequisites(id)
  return Prereqs.missing(self, id)
end

function TG:WarnStepPrerequisites(step)
  if not step then
    return
  end
  self._prereqWarned = self._prereqWarned or {}
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (el.tag == "accept" or el.tag == "turnin" or el.tag == "complete") then
      for _, id in ipairs(TG.GetElementQuestIds and TG:GetElementQuestIds(el) or {}) do
        local key = tostring(step) .. ":" .. tostring(id)
        if not self._prereqWarned[key] then
          local missing = Prereqs.missing(self, id)
          if table.getn(missing) > 0 then
            self._prereqWarned[key] = true
            local parts = {}
            for _, item in ipairs(missing) do
              if item.level then
                table.insert(parts, "level " .. tostring(item.level))
              else
                table.insert(parts, item.title or ("#" .. tostring(item.id)))
              end
            end
            self:Print(
              "Missing prerequisites for "
                .. (questTitle(self, id) or ("#" .. tostring(id)))
                .. ": "
                .. table.concat(parts, ", ")
            )
          end
        end
      end
    end
  end
end
