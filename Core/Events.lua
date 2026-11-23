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

function TG:AddUpdater(name, interval, fn)
  self.updaters[name] = { interval = interval, elapsed = 0, fn = fn }
end

function TG:RemoveUpdater(name)
  self.updaters[name] = nil
end

eventFrame:SetScript("OnUpdate", function()
  local elapsed = arg1
  for _, updater in pairs(TG.updaters) do
    updater.elapsed = updater.elapsed + elapsed
    if updater.elapsed >= updater.interval then
      updater.elapsed = 0
      updater.fn(updater.interval)
    end
  end
end)
