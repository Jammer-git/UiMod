do -- Setup for Control Groups 
    local Prefs = import('/lua/user/prefs.lua')
    local profileName = "CustomizeUi_controlgroupsPanel"
    getSavedPrefs = Prefs.GetFromCurrentProfile(profileName) or {savedPrefs = false}

	oldCreateUI = CreateUI
    function CreateUI(mapGroup)
        oldCreateUI(mapGroup)
        ForkThread(function()
			WaitSeconds(0.1)
            controls.collapseArrow:Hide() 

            local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
            local moveButton = import("/mods/CustomizeUI/src/move_button.lua")
            local collapseArrow = import("/mods/CustomizeUI/src/collapse_arrow.lua")

            local collapseId, profileName = "Controlgroups.CollapseArrow", profileName
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1
            local side, hidden = "right", isHidden(getSavedPrefs)
            local collapseWidth, collapseHeight = 18 * uiScale, 26 * uiScale
            local colapseArrowXoffset, colapseArrowYoffset = 10, 48
            controls.controlgroupsCollapseArrow = collapseArrow.create(
                controls.parent, initializeCollapseArrow, controls.parent, 
                collapseId, profileName, 
                factionId, uiScale,
                side, hidden, 
                collapseWidth, collapseHeight
                )
			LayoutHelpers.AtRightTopIn(controls.controlgroupsCollapseArrow, controls.bgTop, colapseArrowXoffset, colapseArrowYoffset)

            local btnId, profileName = "Controlgroups.MoveButton1", profileName
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1  
            local enabled_disabled = "disabled"
            local btnWidth, btnHeight = 22 * uiScale, 22 * uiScale
            local btnXoffset, btnYoffset = 3, 29
            controls.moveButtonControlgroups = moveButton.create(
                controls.parent, initializeMoveButton, controls.parent, 
                btnId, profileName, 
                factionId, uiScale,
                enabled_disabled, 
                btnWidth, btnHeight, btnXoffset, btnYoffset
            )
			LayoutHelpers.AtRightTopIn(controls.moveButtonControlgroups, controls.bgTop, btnXoffset, btnYoffset)
            setPosition(getSavedPrefs)
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
            controls.container:Hide()  
            controls.controlgroupsCollapseArrow:Show()
            controls.moveButtonControlgroups:Hide()      
        elseif hidden == false then
            controls.container:Show()
            controls.moveButtonControlgroups:Show() 
        end
        if hidden == true then
            btn:SetTexture(prefix..'_tab-open_btn_up.dds')
        elseif hidden == false then
            btn:SetTexture(prefix..'_tab-close_btn_up.dds')            
        end
    end    
    savePosition.saveToPrefs(profileName, controls.container, hidden) 
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
    LayoutHelpers.AtRightTopIn(controls.moveButtonControlgroups, controls.bgTop, btnXoffset - (btnSizeIncrease*uiScale*0.5), btnYoffset - (btnSizeIncrease*uiScale*0.5))
    
    drag.OnMove = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.container, x, y)
            setXy = true 
        end
        moveFunction.movePanelRightTopLeftBottom(controls.container, positionsTable, x, y)
        Tooltip.DestroyMouseoverDisplay()  
        btn:SetTexture(prefix..'_btn_down.dds')   
    end
    drag.OnRelease = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.container, x, y)
            setXy = true 
        end
        moveFunction.movePanelRightTopLeftBottom(controls.container, positionsTable, x, y)

        savePosition.saveToPrefs(profileName, controls.container, controls.controlgroupsCollapseArrow.hidden)
        btn.Width:Set(btnWidth)
        btn.Height:Set(btnHeight) 
        LayoutHelpers.AtRightTopIn(controls.moveButtonControlgroups, controls.bgTop, btnXoffset, btnYoffset)
        btn:SetTexture(prefix..'_btn_over.dds')
    end
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function setPosition(table)
    height = controls.container.Height()
    width = controls.container.Width()
    if table.savedPrefs == true then 
        controls.container.Right:Set(table.right)  
        controls.container.Top:Set(table.top)                      
        controls.container.Left:Set(table.right + width)        
        controls.container.Bottom:Set(table.top + height)
        if table.hidden == false then 
            controls.container:Show() 
            controls.moveButtonControlgroups:Show() 
        elseif table.hidden == true then
            controls.container:Hide()
            controls.controlgroupsCollapseArrow:Show() 
            controls.moveButtonControlgroups:Hide()  
        else 
            controls.container:Show()
            controls.controlgroupsCollapseArrow:Show() 
            controls.moveButtonControlgroups:Show()   
        end
    end
end