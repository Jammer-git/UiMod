do -- Updated with new buttons 
    local Prefs = import('/lua/user/prefs.lua')
    local profileName = "CustomizeUi_multifunctionPanel"
    local getSavedPrefs = Prefs.GetFromCurrentProfile(profileName) or {savedPrefs = false}

    local rightGlowOffsetX = 9 
    local bottomGlowOffsetX = 3 

	oldCreate = Create
	function Create(parent)
		oldCreate(parent)
		ForkThread(function()
			WaitSeconds(0.1)
            LOG("Multifunction.lau .getSavedPrefs:  " ..repr(getSavedPrefs))

            local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
            local moveButton = import("/mods/CustomizeUI/src/move_button.lua")
            local collapseArrow = import("/mods/CustomizeUI/src/collapse_arrow.lua")
            --local lastOpen_Close = getLastOpenClose(getSavedPrefs)

            local collapseId, profileName = "Multifunction.CollapseArrow", profileName
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1
            local side, hidden = "left", isHidden(getSavedPrefs)
            local collapseWidth, collapseHeight = 18 * uiScale, 26 * uiScale
            local colapseArrowXoffset, colapseArrowYoffset = -10, 32
            controls.multifunctionCollapseArrow = collapseArrow.create(
                controls.bg, initializeCollapseArrow, controls.bg, 
                collapseId, profileName, 
                factionId, uiScale,
                side, hidden, 
                collapseWidth, collapseHeight
            )
			LayoutHelpers.AtLeftTopIn(controls.multifunctionCollapseArrow, controls.bg, colapseArrowXoffset, colapseArrowYoffset)

            local btnId, profileName = "Multifunction.MoveButton1", profileName
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1  
            local enabled_disabled = "disabled"
            local btnWidth, btnHeight = 22 * uiScale, 22 * uiScale
            local btnXoffset, btnYoffset = -10, 14
            controls.moveButton = moveButton.create(
                controls.bg, initializeMoveButton,  controls.bg, 
                btnId,  profileName, 
                factionId, uiScale,
                enabled_disabled, 
                btnWidth, btnHeight, btnXoffset, btnYoffset
            )
			LayoutHelpers.AtLeftTopIn(controls.moveButton, controls.bg, btnXoffset, btnYoffset)

            WaitSeconds(3.5)
            setPosition(getSavedPrefs)            
            controls.collapseArrow.Height:Set(0)
            controls.collapseArrow.Width:Set(0)
            controls.collapseArrow:Hide() 
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
            controls.bg:Hide()
            controls.bg.panel:Hide()
            controls.bg.leftBrace:Hide()
            controls.bg.leftGlow:Hide()
            controls.bg.rightGlowTop:Hide()
            controls.bg.rightGlowMiddle:Hide()
            controls.bg.rightGlowBottom:Hide()
            controls.multifunctionCollapseArrow:Show()
            if controls.moveButton then 
                controls.moveButton:Hide()
            end              
        elseif hidden == false then
            controls.bg:Show()
            controls.bg.panel:Show()
            controls.bg.leftBrace:Show()
            controls.bg.leftGlow:Show()
            controls.bg.rightGlowTop:Show()
            controls.bg.rightGlowMiddle:Show()
            controls.bg.rightGlowBottom:Show()
            if controls.moveButton then 
                controls.moveButton:Show()
            end   
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

function onButtonMove(self, event, prefix, btn, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")
    local Dragger = import('/lua/maui/dragger.lua').Dragger
    local Tooltip = import('/lua/ui/game/tooltip.lua')
    Tooltip.DestroyMouseoverDisplay() 
    local btnWidthHalf = btnWidth * 0.5
    local btnHeightHalf = btnHeight * 0.5
    local drag = Dragger()
    drag.OnMove = function(dragself, x, y)
        height = controls.bg.Height()
        width = controls.bg.Width()
        controls.bg.Left:Set(x + (btnXoffset + btnWidthHalf))
        local newLeft = controls.bg.Left()
        controls.bg.Top:Set(y - ((btnYoffset + btnHeightHalf) / uiScale))
        local newTop = controls.bg.Top()            
        controls.bg.Right:Set(newLeft + width)  
        controls.bg.Bottom:Set(newTop + height)
        Tooltip.DestroyMouseoverDisplay()  
        btn:SetTexture(prefix..'_btn_down.dds')   
    end
    drag.OnRelease = function(dragself, x, y)
        height = controls.bg.Height()
        width = controls.bg.Width()
        controls.bg.Left:Set(x + (btnXoffset + btnWidthHalf))
        local newLeft = controls.bg.Left()
        controls.bg.Top:Set(y - ((btnYoffset + btnHeightHalf) * uiScale))
        local newTop = controls.bg.Top()            
        controls.bg.Right:Set(newLeft + width)  
        controls.bg.Bottom:Set(newTop + height)
        savePosition.saveToPrefs(profileName, controls.bg, controls.multifunctionCollapseArrow.hidden)
        btn:SetTexture(prefix..'_btn_over.dds')
    end
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function setPosition(table)
    height = controls.bg.Height()
    width = controls.bg.Width()
    if table.savedPrefs == true then 
        controls.bg.Left:Set(table.left)  
        controls.bg.Top:Set(table.top)                      
        controls.bg.Right:Set(table.left + width)        
        controls.bg.Bottom:Set(table.top + height)
        if table.hidden == false then
            controls.bg:Show()
            controls.bg.panel:Show()
            controls.bg.leftBrace:Show()
            controls.bg.leftGlow:Show()
            controls.bg.rightGlowTop:Show()
            controls.bg.rightGlowMiddle:Show()
            controls.bg.rightGlowBottom:Show()
            if controls.moveButton then 
                controls.moveButton:Show()
            end   
        elseif table.hidden == true then
            controls.bg:Hide()
            controls.bg.panel:Hide()
            controls.bg.leftBrace:Hide()
            controls.bg.leftGlow:Hide()
            controls.bg.rightGlowTop:Hide()
            controls.bg.rightGlowMiddle:Hide()
            controls.bg.rightGlowBottom:Hide()
            controls.multifunctionCollapseArrow:Show()
            if controls.moveButton then 
                controls.moveButton:Hide()
            end   
        else 
            controls.bg:Show()
            controls.bg.panel:Show()
            controls.bg.leftBrace:Show()
            controls.bg.leftGlow:Show()
            controls.bg.rightGlowTop:Show()
            controls.bg.rightGlowMiddle:Show()
            controls.bg.rightGlowBottom:Show()
            if controls.moveButton then 
                controls.moveButton:Show()
            end   
        end
    end
end