-- bag click hook for marking junk with Ctrl or Alt and right click
local TG = _G.TurtleGuides
local hooked = false

function TG:HookBagClicks()
  if hooked then
    return
  end
  if type(ContainerFrameItemButton_OnClick) ~= "function" then
    return
  end
  hooked = true
  local original = ContainerFrameItemButton_OnClick
  ContainerFrameItemButton_OnClick = function(button, ignoreModifiers)
    local btn = this
    if type(button) ~= "string" and button ~= nil then
      btn = button
    end
    local mouseButton = button
    if type(mouseButton) ~= "string" then
      mouseButton = arg1
    end
    local isRightClick = mouseButton == "RightButton"
    local ctrlOrAlt = IsControlKeyDown() or IsAltKeyDown()

    if isRightClick and ctrlOrAlt then
      local parent, bag, slot
      if btn and type(btn) == "table" then
        if type(btn.GetParent) == "function" then
          parent = btn:GetParent()
        end
        if type(btn.GetID) == "function" then
          slot = btn:GetID()
        end
      end
      if parent then
        if type(ContainerFrame_GetFrameID) == "function" then
          bag = ContainerFrame_GetFrameID(parent)
        elseif type(parent.GetID) == "function" then
          bag = parent:GetID()
        end
      end
      if bag ~= nil and slot and slot > 0 then
        TG:ToggleJunkItem(bag, slot)
        return
      end
    end
    return original(button, ignoreModifiers)
  end
end
