-- deferred guide loading: header-only index at login, full parse spread over frames
local TG = _G.TurtleGuides
local strtrim = TG.Util.strtrim
local parseApplies = TG.Parser.parseApplies
local finalizeMeta = TG.Parser.FinalizeMeta
local Context = TG.Parser.Context
local MAX_BACKGROUND_BYTES = 120000

local function headerLine(text, pos)
  local start, finish = string.find(text, "\n", pos, true)
  if start then
    return strtrim(string.sub(text, pos, start - 1)), finish + 1
  end
  return strtrim(string.sub(text, pos)), nil
end

local function parseMeta(text, source)
  if not text then
    return nil, "empty"
  end
  local ctx = Context.player()
  local meta = {}
  local applicable = true
  local inHeader = true
  local pos = 1
  while pos do
    local line
    line, pos = headerLine(text, pos)
    local cpos = string.find(line, "%-%-", 1)
    if cpos then
      line = strtrim(string.sub(line, 1, cpos - 1))
    end
    if line ~= "" then
      if inHeader and string.sub(line, 1, 2) == "<<" and not string.find(line, "^step") then
        if not parseApplies(strtrim(string.sub(line, 3)), ctx) then
          applicable = false
        end
      elseif string.find(line, "^#%S+") or (inHeader and string.sub(line, 1, 2) == "<<") then
        if string.sub(line, 1, 2) == "<<" then
          if not parseApplies(strtrim(string.sub(line, 3)), ctx) then
            applicable = false
          end
        else
          local _, _, key, _, value = string.find(line, "^#(%S+)%s*(=?)%s*(.*)$")
          if key then
            value = strtrim(value or "")
            local p = string.find(value, "<<", 1, true)
            if p then
              local cond = strtrim(string.sub(value, p + 2))
              value = strtrim(string.sub(value, 1, p - 1))
              if not parseApplies(cond, ctx) then
                value = nil
              end
            end
            if value ~= nil then
              local lk = string.lower(key)
              meta[lk] = value
              meta[key] = value
            end
          end
        end
      else
        break
      end
    end
  end
  if not applicable then
    return nil, "not applicable"
  end
  local guide = { source = source, meta = meta, steps = {} }
  finalizeMeta(guide, source)
  guide._raw = text
  guide._source = source
  guide._rawBytes = string.len(text)
  return guide
end

TG.ParseGuideMeta = parseMeta

function TG:BuildGuideMetaIndex()
  self:BuildIndexWith(parseMeta)
  for _, guide in ipairs(self.guides or {}) do
    guide._fullyParsed = false
  end
end

function TG:EnsureGuideParsed(guide)
  if not guide or guide._fullyParsed then
    return guide
  end
  local parsed = TG.Parser.ParseGuide(guide._raw, guide._source)
  if parsed then
    guide.meta = parsed.meta
    guide.steps = parsed.steps
    guide.name = parsed.name
    guide.group = parsed.group
    guide.subgroup = parsed.subgroup
    guide.next = parsed.next
    guide.defaultFor = parsed.defaultFor
    guide.version = parsed.version
  end
  guide._fullyParsed = true
  guide._raw = nil
  return guide
end

function TG:StartGuideLoader()
  if self._guideLoader then
    return
  end
  local player = self:PlayerInfo()
  local queue = {}
  for _, guide in ipairs(self.guides or {}) do
    if
      not guide._fullyParsed
      and guide._rawBytes <= MAX_BACKGROUND_BYTES
      and (not self.GuideMatchesPlayer or self:GuideMatchesPlayer(guide, player))
    then
      table.insert(queue, guide)
    end
  end
  if table.getn(queue) == 0 then
    return
  end
  self._guideLoader = { queue = queue, pos = 1 }
  self:AddUpdater("guideLoader", 0, function()
    local loader = self._guideLoader
    if not loader then
      return
    end
    local guide = loader.queue[loader.pos]
    loader.pos = loader.pos + 1
    self:EnsureGuideParsed(guide)
    if loader.pos > table.getn(loader.queue) then
      self._guideLoader = nil
      self:RemoveUpdater("guideLoader")
    end
  end)
end

function TG:LoadAllGuides()
  if self.guides and table.getn(self.guides) > 0 then
    return
  end
  self:BuildGuideMetaIndex()
  local count = 0
  for _ in pairs(self.guideByKey) do
    count = count + 1
  end
  self:Print("Loaded " .. count .. " classic guides.")
  self:StartGuideLoader()
end
