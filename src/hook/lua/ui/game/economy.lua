do -- Setup for economy
    local Prefs = import('/lua/user/prefs.lua')
    local profileName = "CustomizeUi_economyPanel"
    local getSavedPrefs = Prefs.GetFromCurrentProfile(profileName) or {savedTable = false}

	oldCreateUI = CreateUI
	function CreateUI()
		oldCreateUI()
		ForkThread(function()
			WaitSeconds(0.1)
            local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
            local moveButton = import("/mods/CustomizeUI/src/move_button.lua")
            local collapseArrow = import("/mods/CustomizeUI/src/collapse_arrow.lua")

            local collapseId, profileName = "Economy.CollapseArrow", profileName
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1
            local side, hidden = "left", isHidden(getSavedPrefs)
            local collapseWidth, collapseHeight = 18 * uiScale, 26 * uiScale
            local colapseArrowXoffset, colapseArrowYoffset = -10, 32
            GUI.bg.economyCollapseArrow = collapseArrow.create(
                GUI.bg, initializeCollapseArrow, GUI.bg, 
                collapseId, profileName, 
                factionId, uiScale,
                side, hidden, 
                collapseWidth, collapseHeight
            )
			LayoutHelpers.AtLeftTopIn(GUI.bg.economyCollapseArrow, GUI.bg, colapseArrowXoffset, colapseArrowYoffset)


            local btnId, profileName = "Economy.MoveButton1", profileName
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1  
            local enabled_disabled = "disabled"
            local btnWidth, btnHeight = 22 * uiScale, 22 * uiScale
            local btnXoffset, btnYoffset = -10, 14
            GUI.bg.moveButtonEconomy = moveButton.create(
                GUI.bg, initializeMoveButton, GUI.bg, 
                btnId,  profileName, 
                factionId, uiScale,
                enabled_disabled, 
                btnWidth, btnHeight, btnXoffset, btnYoffset
            )
			LayoutHelpers.AtLeftTopIn(GUI.bg.moveButtonEconomy, GUI.bg, btnXoffset, btnYoffset)

            WaitSeconds(3.5)
            setPosition(getSavedPrefs)            
            GUI.collapseArrow.Height:Set(0)
            GUI.collapseArrow.Width:Set(0)
            GUI.collapseArrow:Hide() 
		end)
	end

    function initializeCollapseArrow(self, event, prefix, button, currentOpen_Close, profileName, uiScale)
        onCollapseArrowCheck(self, event, prefix, button, currentOpen_Close, profileName, uiScale)
	end
    function initializeMoveButton(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
        onButtonMove(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    end
end

function isHidden(getSavedPrefs)
    if getSavedPrefs.hidden == false then 
        hidden = false
    elseif getSavedPrefs.hidden == true then
        hidden = true
    else 
        hidden = false
    end
    return hidden
end

function onCollapseArrowCheck(self, event, prefix, btn, hidden, profileName, uiScale)
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")
    local Dragger = import('/lua/maui/dragger.lua').Dragger
    local drag = Dragger()
    drag.OnRelease = function(dragself, x, y)
        if hidden == true then   
            GUI.bg:Hide()
            GUI.bg.economyCollapseArrow:Show()
            GUI.bg.moveButtonEconomy:Hide()             
        elseif hidden == false then
            GUI.bg:Show()
            GUI.bg.moveButtonEconomy:Show()
        end
        if hidden == true then
            btn:SetTexture(prefix..'_tab-open_btn_up.dds')
        elseif hidden == false then
            btn:SetTexture(prefix..'_tab-close_btn_up.dds')            
        end
    end    
    savePosition.saveToPrefs(profileName, GUI.bg, hidden) 
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function onButtonMove(self, event, prefix, btn, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    local moveFunction = import("/mods/CustomizeUI/src/move_function.lua")
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")
    local Dragger = import('/lua/maui/dragger.lua').Dragger
    local Tooltip = import('/lua/ui/game/tooltip.lua')
    local drag = Dragger()
    local setXy = false
    local btnSizeIncrease = 4

    btn.Width:Set(btnWidth + (btnSizeIncrease*uiScale))
	btn.Height:Set(btnHeight + (btnSizeIncrease*uiScale))
    Tooltip.DestroyMouseoverDisplay() 
    LayoutHelpers.AtLeftTopIn(GUI.bg.moveButtonEconomy, GUI.bg, btnXoffset - (btnSizeIncrease*uiScale*0.5), btnYoffset - (btnSizeIncrease*uiScale*0.5))

    drag.OnMove = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(GUI.bg, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftTopRightBottom(GUI.bg, positionsTable, x, y)

        Tooltip.DestroyMouseoverDisplay()  
        btn:SetTexture(prefix..'_btn_down.dds')   
    end
    drag.OnRelease = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(GUI.bg, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftTopRightBottom(GUI.bg, positionsTable, x, y)

        savePosition.saveToPrefs(profileName, GUI.bg, GUI.bg.economyCollapseArrow.hidden)
        btn.Width:Set(btnWidth)
        btn.Height:Set(btnHeight) 
        LayoutHelpers.AtLeftTopIn(GUI.bg.moveButtonEconomy, GUI.bg, btnXoffset, btnYoffset)
        btn:SetTexture(prefix..'_btn_over.dds')
    end
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function setPosition(table, controlGroup)
    height = GUI.bg.Height()
    width = GUI.bg.Width()
    if table.savedPrefs == true then 
        GUI.bg.Left:Set(table.left)  
        GUI.bg.Top:Set(table.top)                      
        GUI.bg.Right:Set(table.left + width)        
        GUI.bg.Bottom:Set(table.top + height)
        if table.hidden == false then 
            GUI.bg:Show()
            GUI.bg.moveButtonEconomy:Show()  
        elseif table.hidden == true then
            GUI.bg:Hide()
            GUI.bg.economyCollapseArrow:Show()
            GUI.bg.moveButtonEconomy:Hide()
        else 
            GUI.bg:Show()
            GUI.bg.economyCollapseArrow:Show()
            GUI.bg.moveButtonEconomy:Show()
        end
    end
end