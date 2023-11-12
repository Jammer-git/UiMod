do
    local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
	local Button = import('/lua/maui/button.lua').Button
	local Dragger = import('/lua/maui/dragger.lua').Dragger
    local Prefs = import('/lua/user/prefs.lua')

	local buttons = import("/mods/CustomizeUI/src/buttons.lua")
    local collapseArrow = import("/mods/CustomizeUI/src/collapse_arrow.lua")
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")

    local profileName = "CustomizeUi_objectives2Panel"
    local lastSavedPos = Prefs.GetFromCurrentProfile(profileName) or {savedTable = false}
    local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1

    closedOrOpen = "close"
    savedBgPosTable = {}
    hideTable= {savedTable = true, left = -1000, top = -1000, right = -1000, bottom = -1000}

	oldCreateUI = CreateUI
	function CreateUI(inParent)
        oldCreateUI(inParent)
        ForkThread(function()
			WaitSeconds(0.1)
            skin = Prefs.GetFromCurrentProfile('skin')
          
            controls.collapseArrow:Hide()
            ---------------- Collapse Button ----------------
            collapseId, factionId, side, open_Close = "Objectives2.CollapseArrow", skin, "right", closedOrOpen
            collapseWidth, collapseHeight, colapseArrowXoffset, colapseArrowYoffset = 18 * uiScale, 26 * uiScale, 10, 48
            controls.newCollapseArrow = collapseArrow.create(controls.bg, startNewCollapseArrow, controls.bg, collapseId, factionId, side, open_Close, collapseWidth, collapseHeight)
            LayoutHelpers.AtRightTopIn(controls.newCollapseArrow, controls.bg, colapseArrowXoffset, colapseArrowYoffset)
            ------------------ Move Button ------------------
            btnId, factionId, enabled_disabled = "Controlgroups.MoveButton1", skin, "disabled"
            btnWidth, btnHeight, btnXoffset, btnYoffset = 22 * uiScale, 22 * uiScale, 3, 28
            local buttonName = "Objectives2.MoveButton1"
            controls.bg.moveButton = buttons.createMoveButton(controls.bg, startDragging, controls.bg, buttonName, btnWidth)
			LayoutHelpers.AtRightTopIn(controls.bg.moveButton, controls.bg, btnXoffset, btnYoffset)
            setPosition(lastSavedPos)
        end)
    end


    function startNewCollapseArrow(self, event, currentOpen_Close)
		local drag = Dragger()
        drag.OnRelease = function(dragself, x, y)
            if currentOpen_Close == "close" then    
                local arrowPos = getCurrentPosCollapseArrow(controls.newCollapseArrow)
                getBgPosition()
                setPosition(hideTable)     
                controls.newCollapseArrow.Width:Set(width) 
                controls.newCollapseArrow.Height:Set(height)           
                controls.newCollapseArrow.Right:Set(arrowPos.right)  
                controls.newCollapseArrow.Top:Set(arrowPos.top)                      
                controls.newCollapseArrow.Left:Set(arrowPos.left)        
                controls.newCollapseArrow.Bottom:Set(arrowPos.bottom)
                open_Close = "open"
            end
            if currentOpen_Close == "open" then
                open_Close = "close"
                controls.newCollapseArrow:Destroy()
                setPosition(savedBgPosTable)                 
                controls.newCollapseArrow = collapseArrow.create(controls.bg, startNewCollapseArrow, controls.bg, collapseId, factionId, side, open_Close, collapseWidth, collapseHeight)
                LayoutHelpers.AtRightIn(controls.newCollapseArrow, controls.bg, colapseArrowYoffset)
                LayoutHelpers.AtTopIn(controls.newCollapseArrow, controls.bg, colapseArrowXoffset)
            end
        end     
		PostDragger(self:GetRootFrame(), event.KeyCode, drag)
	end

    function startDragging(self, event)
        local btnWidthHalf = btnWidth * 0.5
        local btnHeightHalf = btnHeight * 0.5
		local drag = Dragger()
		drag.OnMove = function(dragself, x, y)
            currentHeight = controls.bg.Height()
            currentWidth = controls.bg.Width()
			controls.bg.Right:Set(x)
            local newRight = controls.bg.Right()
			controls.bg.Top:Set(y - (btnYoffset + (btnHeightHalf * 1.2)))
            local newTop = controls.bg.Top()            
            controls.bg.Left:Set(newRight + currentWidth)  
            controls.bg.Bottom:Set(newTop + currentHeight)      
		end
        drag.OnRelease = function(dragself, x, y)
            currentHeight = controls.bg.Height()
            currentWidth = controls.bg.Width()
            controls.bg.Right:Set(x + (btnYoffset + (btnWidthHalf / (uiScale * 1.2))))
            local newRight = controls.bg.Right()
            controls.bg.Top:Set(y - (btnYoffset + (btnHeightHalf * 1.2)))
            local newTop = controls.bg.Top()            
            controls.bg.Left:Set(newRight + currentWidth)  
            controls.bg.Bottom:Set(newTop + currentHeight)
            savePosition.Save(profileName, controls.bg)
        end
		PostDragger(self:GetRootFrame(), event.KeyCode, drag)
	end
end

function getCurrentPosCollapseArrow(self)
    local table = {left = self.Left(), top = self.Top(), right = self.Right(), bottom = self.Bottom(), width = self.Width(), height = self.Height()}
    return table
end

function getBgPosition()
    savedBgPosTable = {savedTable = true, right = controls.bg.Right(), top = controls.bg.Top(), left = controls.bg.Left(), bottom = controls.bg.Bottom()}
end

function setPosition(posTable)
    currentHeight = controls.bg.Height()
    currentWidth = controls.bg.Width()
    if posTable.savedTable == true then 
        controls.bg.Right:Set(posTable.right)  
        controls.bg.Top:Set(posTable.top)                      
        controls.bg.Left:Set(posTable.right + currentWidth)        
        controls.bg.Bottom:Set(posTable.top + currentHeight)
    end
end
