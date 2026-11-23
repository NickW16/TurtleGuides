-- bag and item lookup helpers for the 1.12 client
local TG = _G.TurtleGuides
local strtrim = TG.Util.strtrim
local splitLines = TG.Util.splitLines

function TG:GetItemCount(itemId)
  itemId = tonumber(itemId)
  if not itemId then
    return 0
  end
  local count = 0
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag)
    if slots then
      for slot = 1, slots do
        local link = GetContainerItemLink(bag, slot)
        if link then
          local _, _, id = string.find(link, "item:(%d+)")
          if tonumber(id) == itemId then
            local _, c = GetContainerItemInfo(bag, slot)
            count = count + (c or 1)
          end
        end
      end
    end
  end
  if count == 0 and GetInventoryItemID then
    local last = INVSLOT_LAST_EQUIPPED or 19
    for slot = 1, last do
      local id = GetInventoryItemID("player", slot)
      if tonumber(id) == itemId then
        count = count + 1
        break
      end
    end
  end
  return count
end

function TG:GetItemIdFromLink(link)
  if not link then
    return nil
  end
  local _, _, id = string.find(link, "item:(%d+)")
  return tonumber(id)
end

local ITEM_ID_BY_NAME = {
  ["thick bear fur"] = 6952,
}

local itemIdByNameCache = {}
local guideItemIdByName = nil
local guideItemNameById = nil

local function displayItemName(text)
  text = TG.cleanRxpColors and TG.cleanRxpColors(text or "") or (text or "")
  text = string.gsub(text, "|T.-|t", "")
  text = string.gsub(text, "%s*<<.*$", "")
  text = string.gsub(text, "^%s*[Cc]ollect%s+", "")
  text = string.gsub(text, "^%s*[Ll]oot%s+", "")
  text = string.gsub(text, "%s*%(%s*[xX]?%d+[xX]?%s*%)%s*$", "")
  text = string.gsub(text, "^%[(.-)%]$", "%1")
  return strtrim(text)
end

local function normalizeItemName(text)
  text = TG.cleanRxpColors and TG.cleanRxpColors(text or "") or (text or "")
  text = string.gsub(text, "|T.-|t", "")
  text = string.gsub(text, "%s*<<.*$", "")
  text = string.gsub(text, "^[Cc]ollect%s+", "")
  text = string.gsub(text, "^[Ll]oot%s+", "")
  text = string.gsub(text, "%s*%(%s*[xX]?%d+[xX]?%s*%)%s*$", "")
  text = string.gsub(text, "^%[(.-)%]$", "%1")
  return strtrim(string.lower(text))
end

local function addGuideItemName(text, id)
  id = tonumber(id)
  local name = normalizeItemName(text)
  if id and name ~= "" then
    if not guideItemIdByName[name] then
      guideItemIdByName[name] = id
    end
    local display = displayItemName(text)
    if display ~= "" and not guideItemNameById[id] then
      guideItemNameById[id] = display
    end
  end
end

local function buildGuideItemIdMap()
  if guideItemIdByName then
    return
  end
  local hasGuides = TG.guides and table.getn(TG.guides) > 0
  local hasRaw = TG.rawGuides and table.getn(TG.rawGuides) > 0
  if not hasGuides and not hasRaw then
    return
  end
  guideItemIdByName = {}
  guideItemNameById = {}

  for _, guide in ipairs(TG.guides or {}) do
    for _, step in ipairs(guide.steps or {}) do
      for _, el in ipairs(step.elements or {}) do
        if (el.tag == "collect" or el.tag == "itemcount") and el.objectiveText and el.args then
          addGuideItemName(el.objectiveText, el.args[1])
        end
      end
    end
  end

  if next(guideItemIdByName) == nil and hasRaw then
    for _, entry in ipairs(TG.rawGuides) do
      for _, raw in ipairs(splitLines(entry.text or "")) do
        local line = strtrim(raw)
        local tag, idStr = string.match(line, "^%.(%w+)%s+(%d+)")
        if tag == "collect" or tag == "itemcount" then
          local cpos = string.find(line, "--", 1, true)
          if cpos then
            addGuideItemName(string.sub(line, cpos + 2), idStr)
          end
        end
      end
    end
  end
end

function TG:GetItemIdByName(name)
  name = strtrim(name or "")
  if name == "" then
    return nil
  end
  local key = string.lower(name)
  if ITEM_ID_BY_NAME[key] then
    return ITEM_ID_BY_NAME[key]
  end
  buildGuideItemIdMap()
  if guideItemIdByName and guideItemIdByName[key] then
    return guideItemIdByName[key]
  end
  if itemIdByNameCache[key] ~= nil then
    if itemIdByNameCache[key] == false then
      return nil
    end
    return itemIdByNameCache[key]
  end
  if not pfDB or type(pfDB["items"]) ~= "table" then
    return nil
  end
  local idb = pfDB["items"]
  local function extract(v)
    if type(v) == "string" and v ~= "" and v ~= "_" then
      return v
    end
    if type(v) == "table" then
      local t = v["T"] or v["t"] or v[1]
      if type(t) == "string" and t ~= "" and t ~= "_" then
        return t
      end
    end
    return nil
  end
  local function scan(tbl)
    if type(tbl) ~= "table" then
      return nil
    end
    for id, v in pairs(tbl) do
      local n = extract(v)
      if n and string.lower(n) == key then
        return tonumber(id)
      end
    end
    return nil
  end
  local found = scan(idb["loc"])
  if not found then
    local locale = (GetLocale and GetLocale()) or "enUS"
    local tries = { locale, locale .. "-turtle", "enUS", "enUS-turtle" }
    for _, k in ipairs(tries) do
      found = scan(idb[k])
      if found then
        break
      end
    end
  end
  if not found then
    for k, loc in pairs(idb) do
      if type(k) == "string" and type(loc) == "table" then
        found = scan(loc)
        if found then
          break
        end
      end
    end
  end
  itemIdByNameCache[key] = found or false
  if found then
    return found
  end
  return nil
end

function TG:GetItemCountByName(name)
  name = strtrim(name or "")
  if name == "" then
    return nil
  end
  local id = TG.GetItemIdByName and TG:GetItemIdByName(name)
  if id then
    return TG:GetItemCount(id)
  end
  local count = 0
  local found = false
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag)
    if slots then
      for slot = 1, slots do
        local link = GetContainerItemLink(bag, slot)
        if link then
          local iname = GetItemInfo and GetItemInfo(link)
          if iname and string.lower(iname) == string.lower(name) then
            local _, c = GetContainerItemInfo(bag, slot)
            count = count + (c or 1)
            found = true
          end
        end
      end
    end
  end
  if not found and GetInventoryItemID and GetInventoryItemLink then
    local last = INVSLOT_LAST_EQUIPPED or 19
    for slot = 1, last do
      local link = GetInventoryItemLink("player", slot)
      if link then
        local iname = GetItemInfo and GetItemInfo(link)
        if iname and string.lower(iname) == string.lower(name) then
          count = count + 1
          found = true
          break
        end
      end
    end
  end
  if found then
    return count
  end
  return nil
end

function TG:GetItemNameById(id)
  id = tonumber(id)
  if not id then
    return nil
  end
  if GetItemInfo then
    local iname = GetItemInfo(id)
    if iname and iname ~= "" then
      return iname
    end
  end
  if pfDB and pfDB["items"] then
    local idb = pfDB["items"]
    local function extract(v)
      if type(v) == "string" and v ~= "" and v ~= "_" then
        return v
      end
      if type(v) == "table" then
        local t = v["T"] or v["t"] or v[1]
        if type(t) == "string" and t ~= "" and t ~= "_" then
          return t
        end
      end
      return nil
    end
    if idb["loc"] then
      local t = extract(idb["loc"][id])
      if t then
        return t
      end
    end
    local locale = (GetLocale and GetLocale()) or "enUS"
    local tries = { locale, locale .. "-turtle", "enUS", "enUS-turtle" }
    for _, key in ipairs(tries) do
      local loc = idb[key]
      if type(loc) == "table" then
        local t = extract(loc[id])
        if t then
          return t
        end
      end
    end
    for k, loc in pairs(idb) do
      if type(loc) == "table" and type(k) == "string" then
        local t = extract(loc[id])
        if t then
          return t
        end
      end
    end
  end
  buildGuideItemIdMap()
  if guideItemNameById and guideItemNameById[id] then
    return guideItemNameById[id]
  end
  return nil
end
