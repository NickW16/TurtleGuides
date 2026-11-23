-- wow 1.12 api and addon globals used by the sources
std = "lua51"

-- unused self is idiomatic in event callbacks
ignore = { "212/self" }

globals = {
  -- api functions
  "AcceptQuest", "BuyMerchantItem", "ClearCursor", "CompleteQuest",
  "ContainerFrame_GetFrameID", "ContainerFrameItemButton_OnClick", "CreateFrame",
  "GetActiveTitle", "GetBindLocation", "GetContainerItemInfo", "GetContainerItemLink",
  "GetContainerNumSlots", "GetCursorInfo", "GetCursorPosition", "GetGossipActiveQuests",
  "GetGossipAvailableQuests", "GetInventoryItemID", "GetInventoryItemLink", "GetItemInfo",
  "GetLocale", "GetMapInfo", "GetMerchantItemInfo", "GetMerchantNumItems",
  "GetNumActiveQuests", "GetNumAvailableQuests", "GetNumQuestChoices",
  "GetNumQuestLeaderBoards", "GetNumQuestLogEntries", "GetPlayerFacing",
  "GetPlayerMapPosition", "GetQuestItemLink", "GetQuestLogLeaderBoard", "GetQuestLogTitle",
  "GetQuestReward", "GetScreenHeight", "GetSpellInfo", "GetSubZoneText", "GetTime",
  "GetTitleText", "GetZoneText", "IsAltKeyDown", "IsControlKeyDown", "IsQuestCompletable",
  "SelectActiveQuest", "SelectAvailableQuest", "SelectGossipActiveQuest",
  "SelectGossipAvailableQuest", "SetMapToCurrentZone", "UnitClass", "UnitFactionGroup",
  "UnitLevel", "UnitName", "UnitRace", "UnitSex", "UnitXP", "UnitXPMax", "UseContainerItem",

  -- frames, constants, and implicit event variables
  "DEFAULT_CHAT_FRAME", "GameTooltip", "INVSLOT_LAST_EQUIPPED", "MerchantFrame",
  "Minimap", "NUM_TAXI_BUTTONS", "SlashCmdList", "TaxiFrame", "UIParent", "WorldMapFrame",
  "arg1", "arg2", "arg3", "arg4", "arg5", "event", "this",

  -- addon globals and optional integrations
  "RXPGuides", "SLASH_TURTLEGUIDES1", "SLASH_TURTLEGUIDES2", "TurtleGuidesCharDB",
  "TurtleGuidesDB", "pfDB", "pfQuest_history",
}
