-- shared ui frame references and row buffers
local TG = _G.TurtleGuides
local State = { mainFrame = nil, pickerFrame = nil, settingsFrame = nil }
TG.UI = TG.UI or {}
TG.UI.State = State

State.stepLines = {}
State.stepRows = {}
State.upcomingLines = {}
