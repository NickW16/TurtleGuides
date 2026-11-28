-- automatic quest, vendor, flight, and item actions
local TG = _G.TurtleGuides
local strtrim = TG.Util.strtrim
local Actions = {}
TG.Automation = TG.Automation or {}
TG.Automation.Actions = Actions

TG._lastAutoTurnin = TG._lastAutoTurnin or 0
TG._lastAutoTurninQuest = TG._lastAutoTurninQuest or nil
TG._autoTurninCooldown = 3

local function autoOn()
  return TG.db and TG.db.autoTurnIn
end

local function canAutoTurnin(questId)
  local now = GetTime and GetTime() or 0
  if TG._lastAutoTurninQuest == questId and (now - TG._lastAutoTurnin) < TG._autoTurninCooldown then
    return false
  end
  return true
end

local function recordAutoTurnin(questId)
  TG._lastAutoTurnin = GetTime and GetTime() or 0
  TG._lastAutoTurninQuest = questId
end

local function hasBagSpace()
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      local _, count = GetContainerItemInfo(bag, slot)
      if not count then
        return true
      end
    end
  end
  return false
end

function TG:OnQuestDetail()
  if not autoOn() then
    return
  end
  if AcceptQuest then
    AcceptQuest()
  end
end

function TG:OnQuestProgress()
  if not autoOn() then
    return
  end
  if IsQuestCompletable and IsQuestCompletable() then
    CompleteQuest()
  end
end

function TG:OnQuestComplete()
  if not autoOn() then
    return
  end
  local choices = GetNumQuestChoices and GetNumQuestChoices() or 0
  local questTitle = GetTitleText and GetTitleText() or nil
  if choices <= 1 then
    if choices == 1 then
      local link = GetQuestItemLink and GetQuestItemLink("reward", 1)
      if link and not hasBagSpace() then
        self:Print("Bag full - cannot auto-turnin quest reward. Free up space.")
        return
      end
    end
    if questTitle and not canAutoTurnin(questTitle) then
      self:Print("Auto-turnin on cooldown for: " .. tostring(questTitle))
      return
    end
    if GetQuestReward then
      GetQuestReward(choices == 1 and 1 or 1)
      if questTitle then
        recordAutoTurnin(questTitle)
      end
    end
  else
    self:Print("Multiple quest rewards - please choose manually.")
  end
end

function TG:OnGossipShow()
  if self:AutoSelectTaxiGossip() then
    return
  end
  if not autoOn() then
    return
  end
  local active = {}
  if GetGossipActiveQuests then
    active = { GetGossipActiveQuests() }
  end
  local i, idx = 1, 1
  while active[i] do
    local title = active[i]
    local isComplete = active[i + 3]
    if isComplete then
      if not (title and not canAutoTurnin(title)) and SelectGossipActiveQuest then
        SelectGossipActiveQuest(idx)
        if title then
          recordAutoTurnin(title)
        end
        return
      end
    end
    i = i + 5
    idx = idx + 1
  end
  local available = {}
  if GetGossipAvailableQuests then
    available = { GetGossipAvailableQuests() }
  end
  i, idx = 1, 1
  while available[i] do
    if SelectGossipAvailableQuest then
      SelectGossipAvailableQuest(idx)
      return
    end
    i = i + 6
    idx = idx + 1
  end
end

function TG:OnQuestGreeting()
  if not autoOn() then
    return
  end
  local numActive = GetNumActiveQuests and GetNumActiveQuests() or 0
  local numAvailable = GetNumAvailableQuests and GetNumAvailableQuests() or 0
  for i = 1, numActive do
    local title, isComplete = GetActiveTitle(i)
    if isComplete and SelectActiveQuest then
      if not (title and not canAutoTurnin(title)) then
        SelectActiveQuest(i)
        if title then
          recordAutoTurnin(title)
        end
        return
      end
    end
  end
  for i = 1, numAvailable do
    if SelectAvailableQuest then
      SelectAvailableQuest(i)
      return
    end
  end
end

local function cleanFlightText(text)
  if not text then
    return ""
  end
  if TG.cleanRxpColors then
    text = TG.cleanRxpColors(text)
  end
  text = string.gsub(text, "|T.-|t", "")
  text = string.gsub(text, "%s+", " ")
  return strtrim(text)
end

local function flightDestination(el)
  local dest = cleanFlightText(el.args and el.args[1] or "")
  if dest ~= "" then
    return dest
  end
  local text = cleanFlightText(el.text or "")
  local parsed = string.match(text, "^[Ff]ly%s+to%s+(.+)$")
  return parsed and strtrim(parsed) or text
end

TG.FlightDestination = flightDestination

local function normalizeFlightName(name)
  local value = cleanFlightText(name)
  value = string.gsub(value, "[%-_]+", " ")
  value = string.gsub(value, "%s+", " ")
  return strtrim(string.lower(value))
end

local function taxiNodeName(index)
  if TaxiNodeName then
    local ok, name = pcall(TaxiNodeName, index)
    if ok and name then
      return name
    end
  end
  local button = _G["TaxiButton" .. index]
  local label = button and (button.Text or button.text or _G["TaxiButton" .. index .. "Text"])
  if label and label.GetText then
    return label:GetText()
  end
end

local function taxiNodeUsable(index)
  if not TaxiNodeGetType then
    return true
  end
  local ok, kind = pcall(TaxiNodeGetType, index)
  if not ok or not kind then
    return true
  end
  kind = string.upper(tostring(kind))
  return kind ~= "NONE" and kind ~= "CURRENT" and kind ~= "DISTANT"
end

local function takeTaxiNode(index)
  if TakeTaxiNode then
    TakeTaxiNode(index)
    return true
  end
  local button = _G["TaxiButton" .. index]
  if button and button.Click then
    button:Click()
    return true
  end
  return false
end

local function currentFlightElements()
  local step = TG.CurrentStep and TG:CurrentStep()
  if not step then
    return nil, nil, nil
  end
  local flyEl, fpEl
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (el.tag == "fly" or el.tag == "f") then
      flyEl = flyEl or el
    elseif el.t == "cmd" and el.tag == "fp" then
      fpEl = fpEl or el
    end
  end
  return step, flyEl, fpEl
end

local function currentStepWantsTaxi()
  local step, flyEl, fpEl = currentFlightElements()
  if flyEl or fpEl then
    return step
  end
  return nil
end

function TG:CurrentFlightStep()
  return currentStepWantsTaxi()
end

function TG:CurrentFlyElement()
  local _, flyEl = currentFlightElements()
  return flyEl
end

function TG:StepHasFlightPathElement(step)
  for _, el in ipairs(step and step.elements or {}) do
    if el.t == "cmd" and el.tag == "fp" then
      return true
    end
  end
  return false
end

function TG:ClearAutoFlight()
  self._autoFlightStep = nil
  self._autoFlightElement = nil
  self._autoFlightStarted = nil
  self._autoFlightTried = nil
end

function TG:AutoSelectTaxiGossip()
  if not (TG.db and TG.db.autoTakeFlight) then
    return false
  end
  if IsShiftKeyDown and IsShiftKeyDown() then
    return false
  end
  if not currentStepWantsTaxi() then
    return false
  end
  if not GetGossipOptions then
    return false
  end
  local options = { GetGossipOptions() }
  for i = 1, table.getn(options) - 1, 2 do
    local kind = options[i + 1]
    if kind and string.lower(tostring(kind)) == "taxi" then
      if SelectGossipOption then
        SelectGossipOption((i + 1) / 2)
      end
      return true
    end
  end
  for i, option in ipairs(options) do
    if type(option) == "table" and (option.type == "taxi" or option.icon == 132057) then
      if SelectGossipOption then
        SelectGossipOption(i)
      end
      return true
    end
  end
  return false
end

function TG:AutoTakeFlight(step, el)
  if not (TG.db and TG.db.autoTakeFlight) then
    return false
  end
  if IsShiftKeyDown and IsShiftKeyDown() then
    return false
  end
  local taxiFrame = _G.TaxiFrame
  if not taxiFrame or not taxiFrame.IsShown or not taxiFrame:IsShown() then
    return false
  end
  step = step or (TG.CurrentStep and TG:CurrentStep())
  if not step then
    return false
  end
  local elements = el and { el } or (step.elements or {})
  for _, element in ipairs(elements) do
    if element.t == "cmd" and (element.tag == "fly" or element.tag == "f") then
      local want = normalizeFlightName(flightDestination(element))
      if want ~= "" then
        local total = NumTaxiNodes and NumTaxiNodes() or (NUM_TAXI_BUTTONS or 20)
        local exact, partial
        for i = 1, total do
          if taxiNodeUsable(i) then
            local node = normalizeFlightName(taxiNodeName(i))
            if node ~= "" and node == want then
              exact = i
              break
            elseif not partial and node ~= "" and
              (string.find(node, want, 1, true) or string.find(want, node, 1, true)) then
              partial = i
            end
          end
        end
        local index = exact or partial
        if index then
          return takeTaxiNode(index)
        end
      end
    end
  end
  return false
end

local function currentStepUseItemIds()
  local ids = {}
  local step = TG.CurrentStep and TG:CurrentStep()
  if not step then
    return ids
  end
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and el.tag == "use" then
      local args = table.concat(el.args or {}, " ")
      local id = tonumber(string.match(args, "%d+"))
      if id then
        ids[id] = true
      end
    end
  end
  return ids
end

function TG:AutoUseQuestItems()
  if not (TG.db and TG.db.autoUseQuestItems) then
    return
  end
  local ids = currentStepUseItemIds()
  if not next(ids) then
    return
  end
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      local link = GetContainerItemLink(bag, slot)
      if link then
        local id = tonumber(string.match(link, "item:(%d+)"))
        if id and ids[id] then
          if TG._autoUseStep == TG.currentStepIndex and TG._autoUseItem == id then
            return
          end
          TG._autoUseStep = TG.currentStepIndex
          TG._autoUseItem = id
          UseContainerItem(bag, slot)
          if TG.SignalManualAction then
            TG:SignalManualAction("use")
          end
          return
        end
      end
    end
  end
end

function TG:AutoBuyVendor()
  if not (TG.db and TG.db.autoBuyVendor) then
    return
  end
  if not MerchantFrame or not MerchantFrame:IsShown() then
    return
  end
  local step = TG.CurrentStep and TG:CurrentStep()
  if not step then
    return
  end
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (el.tag == "vendor" or el.tag == "buy") then
      local itemName = strtrim(string.gsub(el.text or "", "|T.-|t", ""))
      for i = 1, GetMerchantNumItems() do
        local name = GetMerchantItemInfo(i)
        if name and itemName ~= "" and string.find(string.lower(name), string.lower(itemName), 1, true) then
          BuyMerchantItem(i, 1)
          self:Print("Auto-bought: " .. name)
          return
        end
      end
    end
  end
end

Actions.canAutoTurnin = canAutoTurnin
Actions.hasBagSpace = hasBagSpace
Actions.currentStepUseItemIds = currentStepUseItemIds
