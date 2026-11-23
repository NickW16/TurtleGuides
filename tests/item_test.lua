local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("Core.lua", "Core/Util.lua", "Compat/Text.lua", "Compat/Item.lua")
end

local function withBags()
  _G.GetContainerNumSlots = function(bag)
    if bag == 0 then
      return 2
    end
    return 0
  end
  _G.GetContainerItemLink = function(_, slot)
    if slot == 1 then
      return "|Hitem:42::::::::::::|h[Thing]|h"
    end
    if slot == 2 then
      return "|Hitem:99::::::::::::|h[Other]|h"
    end
  end
  _G.GetContainerItemInfo = function(_, slot)
    if slot == 1 then
      return nil, 3
    end
    return nil, 1
  end
end

return {
  test_item_id_from_link = function()
    local TG = fresh()
    env.eq(TG:GetItemIdFromLink("|Hitem:1234::::::::::::|h[x]|h"), 1234)
  end,

  test_item_count_from_bags = function()
    local TG = fresh()
    withBags()
    env.eq(TG:GetItemCount(42), 3)
    env.eq(TG:GetItemCount(99), 1)
  end,

  test_item_count_from_equipped = function()
    local TG = fresh()
    _G.GetInventoryItemID = function(_, slot)
      if slot == 1 then
        return 42
      end
    end
    env.eq(TG:GetItemCount(42), 1)
  end,

  test_built_in_item_name = function()
    local TG = fresh()
    env.eq(TG:GetItemIdByName("Thick Bear Fur"), 6952)
  end,

  test_guide_comment_names_build_lookup = function()
    local TG = fresh()
    TG.guides = {
      { steps = { { elements = { { tag = "collect", objectiveText = "Collect Gladius (1)", args = { "12345" } } } } } },
    }
    env.eq(TG:GetItemIdByName("Gladius"), 12345)
    env.eq(TG:GetItemNameById(12345), "Gladius")
  end,

  test_count_by_name_uses_resolved_id = function()
    local TG = fresh()
    withBags()
    env.eq(TG:GetItemCountByName("Thick Bear Fur"), 0)
  end,
}
