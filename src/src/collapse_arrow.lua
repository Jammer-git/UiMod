local UIUtil = import('/lua/ui/uiutil.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')

-- parent = button child to parent...
-- startFunction = callback to function
-- returnParent = returns parent
-- factionId = Prefs.GetFromCurrentProfile('skin')  local Prefs = import('/lua/user/prefs.lua')
-- side = "right" "left" "top"
-- open_close = "open" "close"                      Start with the function to Close or Open
-- width = number * uiScale                         local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1
-- height = number * uiScale                        local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1
-- default = width 18 , height = 26



function create(parent, startFunction, returnParent, btnId, profileName, factionId, uiScale, side, hidden, width, height)
    if factionId == "cyrban" or "uef" or "aeon" or "seraphim" then 
    else 
        factionId = "uef"
    end
    LOG("Collapse_arrow.lua .. btnId: .. "..repr(btnId).." left right :" ..repr(side).." hidden :" ..repr(hidden) )
    local prefix = "/mods/CustomizeUI/src/icons/collapse_btn_"..side.."/"..factionId
    local btnIdString = btnId
    btnId = Button(parent)
    btnId.hidden = hidden
	btnId:Enable()
    btnId.Width:Set(width)
	btnId.Height:Set(height)    
    btnId.Depth:Set(function() return parent.Depth() + 100 end)

    btnId.setHiddenTexture = function(self)
        if btnId.hidden == false then
            self:SetTexture(prefix..'_tab-close_btn_up.dds')
        else
            self:SetTexture(prefix..'_tab-open_btn_up.dds')
        end
    end

    btnId:setHiddenTexture()

    local Handler = function(self, event) end
    if startFunction then 
        Handler = function(self, event)
            if event.Type == 'MouseEnter' then
                LOG("Collapse_arrow.lua .. btnId: .. "..repr(btnIdString).." left right :" ..repr(side).." hidden :" ..repr(btnId.hidden) )
                PlaySound(Sound({Cue = "UI_Tab_Rollover_01", Bank = "Interface"}))
                if btnId.hidden == false then
                    self:SetTexture(prefix..'_tab-close_btn_over.dds')
                else
                    self:SetTexture(prefix..'_tab-open_btn_over.dds')
                end
            elseif event.Type == 'MouseExit' then
                if btnId.hidden == false then
                    self:SetTexture(prefix..'_tab-close_btn_up.dds')
                else
                    self:SetTexture(prefix..'_tab-open_btn_up.dds')
                end
            elseif event.Type == 'ButtonPress' then
                if btnId.hidden == false then
                    PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))                        
                    self:SetTexture(prefix..'_tab-close_btn_down.dds') 
                    btnId.hidden = true
                    startFunction(returnParent, event, prefix, btnId , true, profileName, uiScale)
                elseif btnId.hidden == true then
                    PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))                        
                    self:SetTexture(prefix..'_tab-open_btn_down.dds')
                    btnId.hidden = false
                    startFunction(returnParent, event, prefix, btnId , false, profileName, uiScale)
                end
            end
        end
        btnId.HandleEvent = Handler
    end
	btnId:EnableHitTest()
    return btnId
end
