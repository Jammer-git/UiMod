do -- Setup for Unitview and Abilities
    local Prefs = import('/lua/user/prefs.lua')
    local profileNameUnitview = "CustomizeUi_unitviewPanel"
    getSavedPrefs_1 = Prefs.GetFromCurrentProfile(profileNameUnitview) or {savedPrefs = false}
    local profileNameAbilities = "CustomizeUi_abilitiesPanel"
    getSavedPrefs_2 = Prefs.GetFromCurrentProfile(profileNameAbilities) or {savedPrefs = false}

	oldCreateUI = CreateUI
	function CreateUI()
		oldCreateUI()
		ForkThread(function()
			WaitSeconds(0.1)
            local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
            local moveButton = import("/mods/CustomizeUI/src/move_button.lua")
            local collapseArrow = import("/mods/CustomizeUI/src/collapse_arrow.lua")

            local collapseId, profileName = "unitview.CollapseArrow", profileNameUnitview
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1
            local side, hidden = "left", isHidden(getSavedPrefs_1)
            local collapseWidth, collapseHeight = 18 * uiScale, 26 * uiScale
            local colapseArrowXoffset, colapseArrowYoffset = -8, 41
            controls.unitviewCollapseArrow = collapseArrow.create(
                controls.parent, initializeCollapseArrowUnitview, controls.parent, 
                collapseId, profileName, 
                factionId, uiScale,
                side, hidden, 
                collapseWidth, collapseHeight
                )
			LayoutHelpers.AtLeftTopIn(controls.unitviewCollapseArrow, controls.bg, colapseArrowXoffset, colapseArrowYoffset)

            local btnId, profileName = "unitview.MoveButton", profileNameUnitview
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1  
            local enabled_disabled = "disabled"
            local btnWidth, btnHeight = 20 * uiScale, 20 * uiScale
            local btnXoffset, btnYoffset = -13, 23
            controls.moveButtonUnitview = moveButton.create(
                controls.parent, initializeMoveButtonUnitview, controls.parent, 
                btnId, profileName, 
                factionId, uiScale,
                enabled_disabled, 
                btnWidth, btnHeight, btnXoffset, btnYoffset
            )
			LayoutHelpers.AtLeftTopIn(controls.moveButtonUnitview, controls.bg, btnXoffset, btnYoffset)

            local btnId, profileName = "abilities.MoveButton", profileNameAbilities
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1  
            local enabled_disabled = "disabled"
            local btnWidth, btnHeight = 20 * uiScale, 20 * uiScale
            local btnXoffset, btnYoffset = -18, -16
            controls.moveButtonAbilities = moveButton.create(
                controls.parent, initializeMoveButtonAbilities, controls.parent, 
                btnId, profileName, 
                factionId, uiScale,
                enabled_disabled, 
                btnWidth, btnHeight, btnXoffset, btnYoffset
            )

            LayoutHelpers.AtLeftIn(controls.moveButtonAbilities, controls.abilities, btnXoffset)  
            LayoutHelpers.AtBottomIn(controls.moveButtonAbilities, controls.abilities, btnYoffset)   

            oldControlsBgOnFrame = controls.bg.OnFrame
            controls.bg.OnFrame = function(self, delta)
                oldControlsBgOnFrame(self, delta)
                if self:GetAlpha() < 1 then 
                    controls.moveButtonUnitview:Hide()
                    controls.unitviewCollapseArrow:Hide()
                    LayoutHelpers.AtLeftIn(controls.moveButtonAbilities, controls.abilities, btnXoffset)  
                    LayoutHelpers.AtBottomIn(controls.moveButtonAbilities, controls.abilities, btnYoffset)   
                    controls.moveButtonAbilities:Hide()
                else
                    controls.moveButtonUnitview:Show()
                    controls.unitviewCollapseArrow:Show()
                    LayoutHelpers.AtLeftIn(controls.moveButtonAbilities, controls.abilities, btnXoffset)  
                    LayoutHelpers.AtBottomIn(controls.moveButtonAbilities, controls.abilities, btnYoffset)   
                    controls.moveButtonAbilities:Show()                
                end
            end
            setPosition(getSavedPrefs_1, getSavedPrefs_2, controls.bg, controls.abilities)
		end)
	end

    function initializeCollapseArrowUnitview(self, event, prefix, button, currentOpen_Close, profileName, uiScale)
        onCollapseArrowCheckUnitview(self, event, prefix, button, currentOpen_Close, profileName, uiScale)
	end
    function initializeMoveButtonUnitview(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
        onButtonMoveUnitview(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    end
    function initializeMoveButtonAbilities(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
        onButtonMoveAbilities(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
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

function onCollapseArrowCheckUnitview(self, event, prefix, btn, hidden, profileName, uiScale)
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")
    local Dragger = import('/lua/maui/dragger.lua').Dragger
    local drag = Dragger()
    drag.OnRelease = function(dragself, x, y)
        if hidden == true then     
            setOnFrameSettings(hidden)
            controls.unitviewCollapseArrow:Show()
            controls.moveButtonUnitview:Hide()
            controls.moveButtonAbilities:Hide()     
        elseif hidden == false then
            setOnFrameSettings(hidden) 
            controls.moveButtonUnitview:Show()
            controls.moveButtonAbilities:Show()
        end
        if hidden == true then
            btn:SetTexture(prefix..'_tab-open_btn_up.dds')
        elseif hidden == false then
            btn:SetTexture(prefix..'_tab-close_btn_up.dds')            
        end
    end    
    savePosition.saveToPrefs(profileName, controls.bg, hidden) 
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function setOnFrameSettings(hidden)
    if hidden == true then     
        controls.bg.OnFrame = function(self, delta)
            self:SetAlpha(0, true)
            controls.moveButtonUnitview:Hide()
            controls.unitviewCollapseArrow:Show()
            controls.moveButtonAbilities:Hide()
        end
    elseif hidden == false then
        controls.bg.OnFrame = function(self, delta)
            oldControlsBgOnFrame(self, delta)
            if self:GetAlpha() < 1 then 
                controls.moveButtonUnitview:Hide()
                controls.unitviewCollapseArrow:Hide()
                controls.moveButtonAbilities:Hide()
            else
                controls.moveButtonUnitview:Show()
                controls.unitviewCollapseArrow:Show()
                controls.moveButtonAbilities:Show()                  
            end
        end
    end
end

function onButtonMoveUnitview(self, event, prefix, btn, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
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
    LayoutHelpers.AtLeftTopIn(controls.moveButtonUnitview, controls.bg, btnXoffset - (btnSizeIncrease*uiScale*0.5), btnYoffset - (btnSizeIncrease*uiScale*0.5))

    drag.OnMove = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.bg, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftTopRightBottom(controls.bg, positionsTable, x, y)

        Tooltip.DestroyMouseoverDisplay()  
        btn:SetTexture(prefix..'_btn_down.dds')   
    end
    drag.OnRelease = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.bg, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftTopRightBottom(controls.bg, positionsTable, x, y)

        savePosition.saveToPrefs(profileName, controls.bg, controls.unitviewCollapseArrow.hidden)
        btn.Width:Set(btnWidth)
        btn.Height:Set(btnHeight) 
        LayoutHelpers.AtLeftTopIn(controls.moveButtonUnitview, controls.bg, btnXoffset, btnYoffset)
        btn:SetTexture(prefix..'_btn_over.dds')
    end
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function onButtonMoveAbilities(self, event, prefix, btn, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    local moveFunction = import("/mods/CustomizeUI/src/move_function.lua")   
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")
    local Dragger = import('/lua/maui/dragger.lua').Dragger
    local Tooltip = import('/lua/ui/game/tooltip.lua')
    local drag = Dragger()
    local setXy = false
    local btnSizeIncrease = 2

    Tooltip.DestroyMouseoverDisplay()     
    btn.Width:Set(btnWidth+ (btnSizeIncrease*uiScale))
	btn.Height:Set(btnHeight+ (btnSizeIncrease*uiScale))    

    drag.OnMove = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.abilities, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftBottom(controls.abilities, positionsTable, x, y)

        Tooltip.DestroyMouseoverDisplay()  
        btn:SetTexture(prefix..'_btn_down.dds')   
    end
    drag.OnRelease = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.abilities, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftBottom(controls.abilities, positionsTable, x, y)

        savePosition.saveToPrefs(profileName, controls.abilities, controls.unitviewCollapseArrow.hidden)
        btn.Width:Set(btnWidth)
        btn.Height:Set(btnHeight) 
        btn:SetTexture(prefix..'_btn_over.dds')
    end
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function setPosition(table1, table2, controlGroupBg, controlGroupAbilities)
    if table1.savedPrefs == true then 
        local currentHeight = controlGroupBg.Height()
        local currentWidth = controlGroupBg.Width()
        controlGroupBg.Left:Set(table1.left)
        local newLeft = controlGroupBg.Left()   
        controlGroupBg.Top:Set(table1.top)
        local newTop = controlGroupBg.Top()
        controlGroupBg.Right:Set(newLeft + currentWidth)  
        controlGroupBg.Bottom:Set(newTop + currentHeight)
        setOnFrameSettings(isHidden(table1))
    else
        local currentHeight = controlGroupBg.Height()
        local currentWidth = controlGroupBg.Width()
        controlGroupBg.Left:Set(controlGroupBg.Left() + 15)
        local newLeft = controlGroupBg.Left()   
        controlGroupBg.Top:Set(controlGroupBg.Top())
        local newTop = controlGroupBg.Top() 
        controlGroupBg.Right:Set(newLeft + currentWidth)  
        controlGroupBg.Bottom:Set(newTop + currentHeight)
        setOnFrameSettings(isHidden(table1))
    end
    if table2.savedPrefs == true then 
        controlGroupAbilities.Left:Set(table2.left)
        controlGroupAbilities.Bottom:Set(table2.bottom)
    end
end