-- slash command registration and dispatch
local TG = _G.TurtleGuides
SLASH_TURTLEGUIDES1 = "/tg"
SLASH_TURTLEGUIDES2 = "/turtleguides"

local commands = {
  [""] = function()
    if TG.ToggleUI then
      TG:ToggleUI()
    end
  end,
  toggle = function()
    if TG.ToggleUI then
      TG:ToggleUI()
    end
  end,
  guides = function()
    if TG.ShowGuidePicker then
      TG:ShowGuidePicker()
    end
  end,
  picker = function()
    if TG.ShowGuidePicker then
      TG:ShowGuidePicker()
    end
  end,
  arrow = function()
    TG.db.showArrow = not TG.db.showArrow
    TG:Print("Arrow: " .. (TG.db.showArrow and "on" or "off"))
    if TG.UpdateArrowVisibility then
      TG:UpdateArrowVisibility()
    end
  end,
  settings = function()
    if TG.ShowSettings then
      TG:ShowSettings()
    end
  end,
  options = function()
    if TG.ShowSettings then
      TG:ShowSettings()
    end
  end,
  next = function()
    if TG.NextStep then
      TG:NextStep()
    end
  end,
  prev = function()
    if TG.PrevStep then
      TG:PrevStep()
    end
  end,
  find = function()
    if TG.FindMyPlace then
      TG:FindMyPlace()
    end
  end,
  findmyplace = function()
    if TG.FindMyPlace then
      TG:FindMyPlace()
    end
  end,
  suggest = function()
    if TG.ShowSuggestions then
      TG:ShowSuggestions()
    elseif TG.ShowSettings then
      TG:ShowSettings("Guides")
    end
  end,
  recommend = function()
    if TG.ShowSuggestions then
      TG:ShowSuggestions()
    elseif TG.ShowSettings then
      TG:ShowSettings("Guides")
    end
  end,
  debug = function()
    if TG.DebugCurrentStep then
      TG:DebugCurrentStep()
    end
  end,
  debugcopy = function()
    if TG.ShowDebugCopy then
      TG:ShowDebugCopy((TG.cdb and TG.cdb.debug) or "No debug captured yet. Run /tg debug first.")
    end
  end,
  reset = function()
    if TG.ResetGuide then
      TG:ResetGuide()
    end
  end,
  junk = function()
    if TG.MarkJunkUnderCursor then
      TG:MarkJunkUnderCursor()
    end
  end,
  orphans = function()
    if TG.AnnounceOrphanQuests then
      TG:AnnounceOrphanQuests()
    end
  end,
  waypoint = function()
    if TG.PrintWaypointDebug then
      TG:PrintWaypointDebug()
    end
  end,
}

SlashCmdList["TURTLEGUIDES"] = function(msg)
  msg = msg or ""
  local _, _, cmd, rest = string.find(msg, "^(%S*)%s*(.-)%s*$")
  cmd = string.lower(cmd or "")
  local handler = commands[cmd]
  if handler then
    handler(rest)
  else
    TG:Print(
      "Commands: /tg (toggle), /tg guides, /tg suggest (open Guides tab), /tg arrow,"
        .. " /tg settings, /tg next, /tg prev, /tg find, /tg reset, /tg junk, /tg orphans, /tg debug, /tg debugcopy"
    )
  end
end
