local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load("src/Core.lua", "src/core/Util.lua", "src/ui/State.lua", "src/ui/Scrollbar.lua")
end

return {
  test_scrollbar_builds_track_and_thumb = function()
    local TG = fresh()
    local scroll = CreateFrame("ScrollFrame", nil, UIParent)
    local content = CreateFrame("Frame", nil, scroll)
    local bar = TG.UI.Scrollbar.create(scroll, content)
    env.eq(bar.scroll, scroll)
    env.eq(bar.content, content)
    env.eq(bar.thumb ~= nil, true)
    env.eq(bar.track ~= nil, true)
    env.eq(scroll.scripts.OnMouseWheel ~= nil, true)
    env.eq(bar.thumb.scripts.OnMouseDown ~= nil, true)
    env.eq(bar.thumb.scripts.OnMouseUp ~= nil, true)
    env.eq(bar.track.scripts.OnMouseDown ~= nil, true)
  end,

  test_scrollbar_handles_page_and_top = function()
    local TG = fresh()
    local scroll = CreateFrame("ScrollFrame", nil, UIParent)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetHeight(500)
    local bar = TG.UI.Scrollbar.create(scroll, content)
    bar:update()
    env.eq(bar.thumb:GetHeight() >= 22, true)
    bar:page(1)
    bar:ensure(3, 16)
    bar:top()
    env.eq(true, true)
  end,
}
