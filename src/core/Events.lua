-- event frame, event registry, and update dispatcher
local TG = _G.TurtleGuides
local eventFrame = CreateFrame("Frame")
TG.eventFrame = eventFrame
TG.events = {}

function TG:RegisterEvent(ev, fn)
  if not self.events[ev] then
    self.events[ev] = {}
    eventFrame:RegisterEvent(ev)
  end
  if fn then
    table.insert(self.events[ev], fn)
  end
end

function TG:UnregisterEvent(ev)
  self.events[ev] = nil
  eventFrame:UnregisterEvent(ev)
end

eventFrame:SetScript("OnEvent", function()
  local ev = event
  local arg1, arg2, arg3, arg4, arg5 = arg1, arg2, arg3, arg4, arg5
  local handlers = TG.events[ev]
  if handlers then
    for _, fn in ipairs(handlers) do
      fn(ev, arg1, arg2, arg3, arg4, arg5)
    end
  end
  if TG.OnEvent then
    TG:OnEvent(ev, arg1, arg2, arg3, arg4, arg5)
  end
end)

TG.updaters = {}
TG._updaterErrors = TG._updaterErrors or {}

function TG:AddUpdater(name, interval, fn)
  self.updaters[name] = { interval = interval, elapsed = 0, fn = fn }
end

function TG:RemoveUpdater(name)
  self.updaters[name] = nil
end

function TG:MarkUIDirty()
  self._uiDirty = true
end

TG:AddUpdater("uiFlush", 0, function()
  if not TG._uiDirty then
    return
  end
  TG._uiDirty = nil
  if TG.UpdateUI then
    TG:UpdateUI()
  end
end)

eventFrame:SetScript("OnUpdate", function()
  local elapsed = arg1
  local due = {}
  for name, updater in pairs(TG.updaters) do
    updater.elapsed = updater.elapsed + elapsed
    if updater.elapsed >= updater.interval then
      updater.elapsed = 0
      table.insert(due, { name = name, fn = updater.fn, interval = updater.interval })
    end
  end
  for _, item in ipairs(due) do
    local ok, err = pcall(item.fn, item.interval)
    if not ok and not TG._updaterErrors[item.name] then
      TG._updaterErrors[item.name] = true
      if TG.Print then
        TG:Print("updater " .. item.name .. " failed: " .. tostring(err))
      end
    end
  end
end)
