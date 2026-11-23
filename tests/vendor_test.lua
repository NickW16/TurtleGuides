local env, loadEngine = dofile("tests/engine_base.lua")

local GREY = "|cff9d9d9d|Hitem:42::::::::::::|h[Poor Item]|h|r"

return {
  test_grey_item_is_junk = function()
    local TG = loadEngine()
    env.load("src/vendor/Junk.lua", "src/vendor/Icons.lua", "src/vendor/Hooks.lua")
    TG.cdb = { junk = {} }
    _G.GetContainerItemLink = function()
      return GREY
    end
    env.eq(TG:IsItemJunk(0, 1), true)
  end,

  test_protected_item_is_not_junk = function()
    local TG = loadEngine()
    env.load("src/vendor/Junk.lua", "src/vendor/Icons.lua", "src/vendor/Hooks.lua")
    TG.cdb = { junk = { [42] = false } }
    _G.GetContainerItemLink = function()
      return GREY
    end
    env.eq(TG:IsItemJunk(0, 1), false)
  end,

  test_toggle_junk_item = function()
    local TG = loadEngine()
    env.load("src/vendor/Junk.lua", "src/vendor/Icons.lua", "src/vendor/Hooks.lua")
    TG.cdb = { junk = {} }
    _G.GetContainerItemLink = function()
      return "|cffffffff|Hitem:99::::::::::::|h[Item]|h|r"
    end
    TG:ToggleJunkItem(0, 1)
    env.eq(TG.cdb.junk[99], true)
  end,

  test_junk_count = function()
    local TG = loadEngine()
    env.load("src/vendor/Junk.lua", "src/vendor/Icons.lua", "src/vendor/Hooks.lua")
    TG.cdb = { junk = {} }
    _G.GetContainerNumSlots = function(bag)
      if bag == 0 then
        return 1
      end
      return 0
    end
    _G.GetContainerItemLink = function()
      return GREY
    end
    env.eq(TG:GetJunkCount(), 1)
  end,
}
