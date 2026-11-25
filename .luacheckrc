-- wow 1.12 api and addon globals used by the sources
std = "lua51"
exclude_files = { "archive/**" }

-- unused self is idiomatic in event callbacks
ignore = { "212/self" }

globals = {
  -- api functions
  "AcceptQuest", "BuyMerchantItem", "ClearCursor", "CompleteQuest",
  "ContainerFrame_GetFrameID", "ContainerFrameItemButton_OnClick", "CreateFrame",
  "GetActiveTitle", "GetBindLocation", "GetContainerItemCooldown", "GetContainerItemID",
  "GetContainerItemInfo", "GetContainerItemLink", "GetContainerNumSlots", "GetCursorInfo",
  "GetCursorPosition", "GetGossipActiveQuests", "GetGossipAvailableQuests", "GetItemCooldown",
  "GetInventoryItemID", "GetInventoryItemLink", "GetItemInfo", "GetQuestLink",
  "GetQuestLinkForLogIndex", "GetSpellCooldown",
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
  "C_Map", "C_QuestLog", "ClassTrainerFrame", "CreateVector2D", "DEFAULT_CHAT_FRAME",
  "GameFontHighlightSmall", "GameTooltip", "GetBindingAction", "GetCursorPosition",
  "INVSLOT_LAST_EQUIPPED", "MerchantFrame", "Minimap", "SetBinding", "ToggleDropDownMenu",
  "UIDropDownMenu_AddButton", "UIDropDownMenu_CreateInfo", "UIDropDownMenu_Initialize",
  "UIDropDownMenu_SetText", "UIDropDownMenu_SetWidth", "NUM_TAXI_BUTTONS", "SlashCmdList",
  "TaxiFrame", "UIParent", "WorldMapFrame", "UnitPosition", "arg1", "arg2", "arg3", "arg4",
  "arg5", "event", "this", "table.getn", "math.mod",

  -- addon globals and optional integrations
  "RXPGuides", "SLASH_TURTLEGUIDES1", "SLASH_TURTLEGUIDES2", "STANDARD_TEXT_FONT", "TurtleGuidesCharDB",
  "TurtleGuidesDB", "pfDB", "pfDatabase", "pfQuest_history",
}

files["src/guides/*.lua"] = { ignore = { "613" }, max_line_length = false }
