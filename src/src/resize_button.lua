local UIUtil = import('/lua/ui/uiutil.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')


-- parent = button child to parent...
-- startFunction = callback to function
-- returnParent = returns parent
-- factionId = Prefs.GetFromCurrentProfile('skin')  local Prefs = import('/lua/user/prefs.lua')
-- enabled_disabled = "enabled" "disabled"          Starts with the function to enabled or disabled
-- width = number * uiScale                         local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1
-- height = number * uiScale                        local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1


local toolTipTable1 = {text = "Double Click To Lock/Unlock"}
local toolTipTable2 = {text = "Select and Drag to Position"}
local toolTipTable3 = {text = "Select and Drag to change Width"}

function create(parent, startFunction, returnParent, btnId, profileName, factionId, uiScale, enabled_disabled, btnWidth, btnHeight, btnXoffset, btnYoffset)
    if factionId == "cyrban" or "uef" or "aeon" or "seraphim" then 
    else 
        factionId = "uef"
    end
    local prefix = "/mods/CustomizeUI/src/icons/move_btn/"..factionId
    local btnIdString = btnId
    btnId = Button(parent)
    btnId.enabled_disabled = enabled_disabled
	btnId:Enable()
    btnId.Width:Set(btnWidth)
	btnId.Height:Set(btnHeight)    
    btnId.Depth:Set(function() return parent.Depth() + 100 end)

    if btnId.open_close == "enabled" then
        btnId:SetTexture(prefix..'_btn_up.dds')
    else
        btnId:SetTexture(prefix..'_btn_dis.dds')
    end

    local Handler = function(self, event) end
    if startFunction then 
        Handler = function(self, event)
            if event.Type == 'MouseEnter' then
                PlaySound(Sound({Cue = "UI_Tab_Rollover_01", Bank = "Interface"}))
                if btnId.enabled_disabled == "enabled" then
                    self:SetTexture(prefix..'_btn_over.dds')
                    if btnIdString == "Construction.ResizeButton1" then 
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable3, 0, true) -- Select and Drag to change Width
                    else
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable2, 0, true) -- Select and Drag to Position
                    end
                else
                    Tooltip.CreateMouseoverDisplay(self, toolTipTable1, 0, true) -- Double Click To Lock/Unlock
                end
            elseif event.Type == 'MouseExit' then
                if btnId.enabled_disabled == "enabled" then
                    self:SetTexture(prefix..'_btn_up.dds')
                end
                Tooltip.DestroyMouseoverDisplay()
            elseif event.Type == 'ButtonPress' then
                if btnId.enabled_disabled == "enabled" then
                    PlaySound(Sound({Cue = "UI_Tab_Click_01", Bank = "Interface"}))                      
                    self:SetTexture(prefix..'_btn_down.dds')
                    startFunction(returnParent, event, prefix, btnId, profileName ,uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
                else
                    PlaySound(Sound({Cue = "UI_Tab_Click_02", Bank = "Interface"}))                        
                end
            elseif event.Type == 'ButtonDClick' then
                if btnId.enabled_disabled == "enabled" then
                    self:SetTexture(prefix..'_btn_dis.dds')
                    LOG("buttons.lua : ".. repr(btnIdString) .." = disabled")
                    PlaySound(Sound({Cue = "UI_Tab_Click_02", Bank = "Interface"}))
                    btnId.enabled_disabled = "disabled"

                    Tooltip.DestroyMouseoverDisplay()
                    Tooltip.CreateMouseoverDisplay(self, toolTipTable1, 0, true)    
                else
                    self:SetTexture(prefix..'_btn_up.dds')
                    LOG("buttons.lua : ".. repr(btnIdString) .." = enabled")
                    PlaySound(Sound({Cue = "UI_Tab_Click_02", Bank = "Interface"}))
                    btnId.enabled_disabled = "enabled"

                    Tooltip.DestroyMouseoverDisplay() -- Double Click To Lock/Unlock
                    if btnIdString == "Construction.ResizeButton1" then 
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable3, 0, true) -- Select and Drag to change Width
                    else
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable2, 0, true) -- Select and Drag to Position
                    end
                end
            end
        end
        btnId.HandleEvent = Handler
    end
	btnId:EnableHitTest()
    return btnId
end
