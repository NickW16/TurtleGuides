-- automation event registration
local TG = _G.TurtleGuides

function TG:InitAutomation()
  self:RegisterEvent("GOSSIP_SHOW", function()
    TG:OnGossipShow()
  end)
  self:RegisterEvent("QUEST_GREETING", function()
    TG:OnQuestGreeting()
  end)
  self:RegisterEvent("QUEST_DETAIL", function()
    TG:OnQuestDetail()
  end)
  self:RegisterEvent("QUEST_PROGRESS", function()
    TG:OnQuestProgress()
  end)
  self:RegisterEvent("QUEST_COMPLETE", function()
    TG:OnQuestComplete()
  end)
  self:RegisterEvent("TAXIMAP_OPENED", function()
    if not (TG.db and TG.db.autoTakeFlight) then
      return
    end
    local step = TG.CurrentFlightStep and TG:CurrentFlightStep()
    if not step then
      return
    end
    TG._autoFlightStep = step
    TG._autoFlightElement = TG.CurrentFlyElement and TG:CurrentFlyElement() or nil
    TG._autoFlightStarted = GetTime and GetTime() or 0
    TG._autoFlightTried = false
    TG:AddUpdater("autoFlight", 0.2, function()
      local captured = TG._autoFlightStep
      if not captured then
        TG:RemoveUpdater("autoFlight")
        return
      end
      if TG._autoFlightElement and not TG._autoFlightTried then
        if TG:AutoTakeFlight(captured, TG._autoFlightElement) then
          TG._autoFlightTried = true
        end
      end
      if UnitOnTaxi and UnitOnTaxi("player") then
        TG:SignalManualAction("fly", captured)
        if TG.StepHasFlightPathElement and TG:StepHasFlightPathElement(captured) then
          TG:SignalManualAction("fp", captured)
        end
        TG:ClearAutoFlight()
        TG:RemoveUpdater("autoFlight")
        return
      end
      local now = GetTime and GetTime() or 0
      if now - TG._autoFlightStarted > 5 then
        if TG._autoFlightElement and not (IsShiftKeyDown and IsShiftKeyDown()) then
          local dest = TG.FlightDestination and TG:FlightDestination(TG._autoFlightElement) or "destination"
          if TG._autoFlightTried then
            TG:Print("Auto flight: taxi did not start for " .. tostring(dest) .. ".")
          else
            TG:Print("Auto flight: no reachable taxi node matched " .. tostring(dest) .. ".")
          end
        end
        TG:ClearAutoFlight()
        TG:RemoveUpdater("autoFlight")
      end
    end)
  end)
  self:RegisterEvent("TAXIMAP_CLOSED", function()
    local captured = TG._autoFlightStep
    if not captured then
      return
    end
    if TG.StepHasFlightPathElement and TG:StepHasFlightPathElement(captured) then
      TG:SignalManualAction("fp", captured)
    end
    if not TG._autoFlightElement and not (UnitOnTaxi and UnitOnTaxi("player")) then
      TG:ClearAutoFlight()
      TG:RemoveUpdater("autoFlight")
    end
  end)
  self:RegisterEvent("MERCHANT_SHOW", function()
    if TG.db and TG.db.autoBuyVendor then
      TG:AddUpdater("autoBuy", 0.5, function()
        TG:AutoBuyVendor()
        TG:RemoveUpdater("autoBuy")
      end)
    end
  end)
  self:RegisterEvent("BAG_UPDATE", function()
    if TG.db and TG.db.autoUseQuestItems then
      TG:AutoUseQuestItems()
    end
  end)
end
