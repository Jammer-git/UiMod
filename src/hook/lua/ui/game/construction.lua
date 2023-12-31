do
    local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
	local Button = import('/lua/maui/button.lua').Button
	local Dragger = import('/lua/maui/dragger.lua').Dragger

	local buttons = import("/mods/CustomizeUI/src/buttons.lua")
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")

    local profileNameOrders = "CustomizeUi_constructionOrdersPanel"
    local lastSavedPosOrders = Prefs.GetFromCurrentProfile(profileNameOrders) or {savedTable = false}

    local profileNameConstruction = "CustomizeUi_constructionPanel"
    local getSavedPrefsConstruction = Prefs.GetFromCurrentProfile(profileNameConstruction) or {savedTable = false}

    local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1

    -- OrdersPanel
    local ordersPanelHeight = 118 --Default height on Ui 100%
    local ordersUiScalePanelHeight = ordersPanelHeight * uiScale
    if ordersUiScalePanelHeight - math.floor(ordersUiScalePanelHeight) < 0.5 then
        roundedValueOrdersPanelHeight = math.floor(ordersUiScalePanelHeight)
    else
        roundedValueOrdersPanelHeight = math.ceil(ordersUiScalePanelHeight)
    end
    local ordersPanelWidth = 390  --Default width on Ui 100%
    local ordersUiScalePanelWidth = ordersPanelWidth * uiScale
    if ordersUiScalePanelWidth - math.floor(ordersUiScalePanelWidth) < 0.5 then
        roundedValueOrdersPanelWidth = math.floor(ordersUiScalePanelWidth)
    else
        roundedValueOrdersPanelWidth = math.ceil(ordersUiScalePanelWidth)
    end

    -- ConstructionPanel
    local constructionPanelHeight = 138 --Default height on Ui 100%
    local constructionUiScalePanelHeight = constructionPanelHeight * uiScale
    if constructionUiScalePanelHeight - math.floor(constructionUiScalePanelHeight) < 0.5 then
        roundedValueConstructionPanelHeight = math.floor(constructionUiScalePanelHeight)
    else
        roundedValueConstructionPanelHeight = math.ceil(constructionUiScalePanelHeight)
    end
    local minConstructionPanelSize = 500

    --UnitViewPanel -- not use in this file but we need width for intial setup
    local unitViewPanelWidth = 330  --Default width on Ui 100%
    local uiScaleUnitViewPanelWidth = unitViewPanelWidth * uiScale
    if uiScaleUnitViewPanelWidth - math.floor(uiScaleUnitViewPanelWidth) < 0.5 then
        roundedValueUnitViewPanelWidth = math.floor(uiScaleUnitViewPanelWidth)
    else
        roundedValueUnitViewPanelWidth = math.ceil(uiScaleUnitViewPanelWidth)
    end


    local buttonSize = 20 * uiScale
    local ordersButtonX_Offset = -13  
    local ordersButtonY_Offset = 26

    local constructionButtonX_Offset = 75  
    local constructionButtonY_Offset = 3

    local resizeButtonX_Offset = -14
    local resizeButtonY_Offset = 44


	oldCreateUI = CreateUI
	function CreateUI()
		oldCreateUI()
		ForkThread(function()
			WaitSeconds(0.1)
            orders = import('/lua/ui/game/orders.lua')
            local buttonName = "Construction.Orders.MoveButton1"
			ordersControl.moveButton = buttons.createMoveButton(ordersControl, startDraggingOrdersPanel, ordersControl, buttonName, buttonSize)
			LayoutHelpers.AtLeftTopIn(ordersControl.moveButton, ordersControl, ordersButtonX_Offset, ordersButtonY_Offset)

            local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
            local moveButton = import("/mods/CustomizeUI/src/move_button.lua")
            local collapseArrow = import("/mods/CustomizeUI/src/collapse_arrow.lua")

            local btnId, profileName = "Construction.MoveButton1", profileNameConstruction
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1  
            local enabled_disabled = "disabled"
            local btnWidth, btnHeight = 22 * uiScale, 22 * uiScale
            local btnXoffset, btnYoffset = 73, 1
            controls.constructionGroup.moveButtonConstruction = moveButton.create(
                controls.constructionGroup, initializeMoveButtonConstruction, controls.constructionGroup, 
                btnId,  profileName, 
                factionId, uiScale,
                enabled_disabled, 
                btnWidth, btnHeight, btnXoffset, btnYoffset
            )
			LayoutHelpers.AtLeftTopIn(controls.constructionGroup.moveButtonConstruction, controls.constructionGroup, btnXoffset, btnYoffset)

            local btnId, profileName = "Construction.ResizeButton1", profileNameConstruction
            local factionId, uiScale = Prefs.GetFromCurrentProfile('skin'), Prefs.GetFromCurrentProfile('options').ui_scale or 1  
            local enabled_disabled = "disabled"
            local btnWidth, btnHeight = 22 * uiScale, 22 * uiScale
            local btnXoffset, btnYoffset = -14, 44
            controls.constructionGroup.risizeButtonConstruction = moveButton.create(
                controls.constructionGroup, initializeResizeButtonConstruction, controls.constructionGroup, 
                btnId,  profileName, 
                factionId, uiScale,
                enabled_disabled, 
                btnWidth, btnHeight, btnXoffset, btnYoffset
            )
			LayoutHelpers.AtRightTopIn(controls.constructionGroup.risizeButtonConstruction, controls.constructionGroup, btnXoffset, btnYoffset)

            --local buttonName = "Construction.MoveButton1"
            --controls.constructionGroup.moveButton = buttons.createMoveButton(controls.constructionGroup, startDraggingConstructionPanel, controls.constructionGroup, buttonName, buttonSize)
			--LayoutHelpers.AtLeftTopIn(controls.constructionGroup.moveButton, controls.constructionGroup, constructionButtonX_Offset, constructionButtonY_Offset)
           -- local buttonName = "Construction.ResizeButton1"
           -- controls.constructionGroup.resizeButton = buttons.createMoveButton(controls.constructionGroup, startDraggingWidth, controls.constructionGroup, buttonName, buttonSize)
			--LayoutHelpers.AtRightTopIn(controls.constructionGroup.resizeButton, controls.constructionGroup, resizeButtonX_Offset, resizeButtonY_Offset)
            setPosition(getSavedPrefsConstruction, controls.constructionGroup)
		end)
	end

    function initializeMoveButtonConstruction(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
        onButtonMoveConstruction(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    end

    function initializeResizeButtonConstruction(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
        onButtonResizeConstruction(self, event, prefix, button, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    end

    function startDraggingOrdersPanel(self, event)
        local buttonHalfSize = buttonSize*0.5
		local drag = Dragger()
		drag.OnMove = function(dragself, x, y)
			orders.controls.bg.Left:Set(x - (ordersButtonX_Offset + buttonHalfSize))
            local newLeft = orders.controls.bg.Left()
			orders.controls.bg.Top:Set(y - (ordersButtonY_Offset + (buttonHalfSize * uiScale)))
            local newTop = orders.controls.bg.Top()
			orders.controls.bg.Right:Set(newLeft + roundedValueOrdersPanelWidth)
			orders.controls.bg.Bottom:Set(newTop + roundedValueOrdersPanelHeight)
            drag.OnRelease = function(dragself, x, y)
                orders.controls.bg.Left:Set(x - (ordersButtonX_Offset + buttonHalfSize))
                local newLeft = orders.controls.bg.Left()
                orders.controls.bg.Top:Set(y - (ordersButtonY_Offset + (buttonHalfSize * uiScale)))
                local newTop = orders.controls.bg.Top()
                orders.controls.bg.Right:Set(newLeft + roundedValueOrdersPanelWidth)
                orders.controls.bg.Bottom:Set(newTop + roundedValueOrdersPanelHeight)
                savePosition.Save(profileNameOrders, orders.controls.bg)
            end
		end
		PostDragger(self:GetRootFrame(), event.KeyCode, drag)
	end

    function startDraggingConstructionPanel(self, event)
        local buttonHalfSize = buttonSize*0.5
    
        local oldConstructionGroupLeft = controls.constructionGroup.Left()
        local oldConstructionGroupRight = controls.constructionGroup.Right()

		local drag = Dragger()
		drag.OnMove = function(dragself, x, y)
			controls.constructionGroup.Left:Set(x - (constructionButtonX_Offset + (buttonHalfSize * (uiScale * uiScale * 1.2))))
            local newLeft = controls.constructionGroup.Left()
            local differenceLeft = oldConstructionGroupLeft - newLeft
			controls.constructionGroup.Top:Set(y - (constructionButtonY_Offset + buttonHalfSize))
            local newTop = controls.constructionGroup.Top()
			controls.constructionGroup.Right:Set(oldConstructionGroupRight - differenceLeft)
			controls.constructionGroup.Bottom:Set(newTop + roundedValueConstructionPanelHeight)
            drag.OnRelease = function(dragself, x, y)
                controls.constructionGroup.Left:Set(x - (constructionButtonX_Offset + (buttonHalfSize * (uiScale * uiScale * 1.2))))
                local newLeft = controls.constructionGroup.Left()
                local differenceLeft = oldConstructionGroupLeft - newLeft
                controls.constructionGroup.Top:Set(y - (constructionButtonY_Offset + buttonHalfSize))
                local newTop = controls.constructionGroup.Top()
                controls.constructionGroup.Right:Set(oldConstructionGroupRight - differenceLeft)
                controls.constructionGroup.Bottom:Set(newTop + roundedValueConstructionPanelHeight)
                savePosition.Save(profileNameConstruction, controls.constructionGroup)
            end
		end
		PostDragger(self:GetRootFrame(), event.KeyCode, drag)
	end

    function startDraggingWidth(self, event)
        local buttonHalfSize = buttonSize*0.5
    
        local oldConstructionGroupPanelLeft = controls.constructionGroup.Left()
        local oldConstructionGroupPanelTop = controls.constructionGroup.Top()
        local oldConstructionGroupPanelRight = controls.constructionGroup.Right()
        local oldConstructionGroupPanelBottom = controls.constructionGroup.Bottom()
    
        local drag = Dragger()
        drag.OnMove = function(self, x, y)
                controls.constructionGroup.Left:Set(oldConstructionGroupPanelLeft)
                controls.constructionGroup.Top:Set(oldConstructionGroupPanelTop)
                if x > (controls.constructionGroup.Left() + minConstructionPanelSize) then
                    controls.constructionGroup.Right:Set(x)
                else
                    controls.constructionGroup.Right:Set(oldOrdersPanelLeft + minConstructionPanelSize) 
                end
                controls.constructionGroup.Bottom:Set(oldConstructionGroupPanelBottom)
            drag.OnRelease = function(dragself, x, y)
                controls.constructionGroup.Left:Set(oldConstructionGroupPanelLeft)
                controls.constructionGroup.Top:Set(oldConstructionGroupPanelTop)
                if x > (controls.constructionGroup.Left() + minConstructionPanelSize) then
                    controls.constructionGroup.Right:Set(x)
                else
                    controls.constructionGroup.Right:Set(oldOrdersPanelLeft + minConstructionPanelSize) 
                end
                controls.constructionGroup.Bottom:Set(oldConstructionGroupPanelBottom)
                savePosition.Save(profileNameConstruction, controls.constructionGroup)
            end
        end
        PostDragger(self:GetRootFrame(), event.KeyCode, drag)
    end

    function SetPosition(posTable1 ,posTable2)
        if posTable1.savedTable == true then -- Orders Panel
            orders.controls.bg.Left:Set(posTable1.left)  
            orders.controls.bg.Top:Set(posTable1.top)
            orders.controls.bg.Right:Set(posTable1.left + ordersUiScalePanelWidth)
            orders.controls.bg.Bottom:Set(posTable1.top + ordersUiScalePanelHeight)  
        end
        if posTable2.savedTable == true then -- Construction Panel
            controls.constructionGroup.Left:Set(posTable2.left)
            local oldOrdersPanelLeft = controls.constructionGroup.Left()
            controls.constructionGroup.Top:Set(posTable2.top)
            if posTable2.right > (controls.constructionGroup.Left() + minConstructionPanelSize) then
                controls.constructionGroup.Right:Set(posTable2.right)
            else
                controls.constructionGroup.Right:Set(oldOrdersPanelLeft + minConstructionPanelSize) 
            end
            controls.constructionGroup.Bottom:Set(posTable2.top + roundedValueConstructionPanelHeight)
        end
        if posTable1.savedTable == false then -- Orders Panel
            local oldOrdersLeft   = orders.controls.bg.Left()
            local oldOrdersTop    = orders.controls.bg.Top()
            local oldOrdersRight  = orders.controls.bg.Right()
            local oldOrdersBottom = orders.controls.bg.Bottom()
            orders.controls.bg.Left:Set(oldOrdersLeft + roundedValueUnitViewPanelWidth)  
            orders.controls.bg.Top:Set(oldOrdersTop)
            orders.controls.bg.Right:Set(oldOrdersRight + roundedValueUnitViewPanelWidth)
            orders.controls.bg.Bottom:Set(oldOrdersTop + ordersUiScalePanelHeight)  
        end
        if posTable2.savedTable == false then -- Construction Panel
            local oldConstructionTop    = controls.constructionGroup.Top()
            controls.constructionGroup.Left:Set(orders.controls.bg.Left() + roundedValueOrdersPanelWidth)
            local oldConstructionPanelLeft = controls.constructionGroup.Left()
            controls.constructionGroup.Top:Set(oldConstructionTop)
            controls.constructionGroup.Right:Set(oldConstructionPanelLeft + minConstructionPanelSize)
            controls.constructionGroup.Bottom:Set(oldConstructionTop + roundedValueConstructionPanelHeight)
        end
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

function onButtonMoveConstruction(self, event, prefix, btn, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
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
    LayoutHelpers.AtLeftTopIn(controls.constructionGroup.moveButtonConstruction, controls.constructionGroup, btnXoffset - (btnSizeIncrease*uiScale*0.5), btnYoffset - (btnSizeIncrease*uiScale*0.5))

    drag.OnMove = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.constructionGroup, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftTopRightBottom(controls.constructionGroup, positionsTable, x, y)

        Tooltip.DestroyMouseoverDisplay()  
        btn:SetTexture(prefix..'_btn_down.dds')   
    end
    drag.OnRelease = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.constructionGroup, x, y)
            setXy = true 
        end
        moveFunction.movePanelLeftTopRightBottom(controls.constructionGroup, positionsTable, x, y)

        savePosition.saveToPrefs(profileName, controls.constructionGroup, controls.constructionGroup.hidden)
        btn.Width:Set(btnWidth)
        btn.Height:Set(btnHeight) 
        LayoutHelpers.AtLeftTopIn(controls.constructionGroup.moveButtonConstruction, controls.constructionGroup, btnXoffset, btnYoffset)
        btn:SetTexture(prefix..'_btn_over.dds')
    end
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function onButtonResizeConstruction(self, event, prefix, btn, profileName, uiScale, btnWidth, btnHeight, btnXoffset, btnYoffset)
    local moveFunction = import("/mods/CustomizeUI/src/move_function.lua")
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")
    local Dragger = import('/lua/maui/dragger.lua').Dragger
    local Tooltip = import('/lua/ui/game/tooltip.lua')
    local drag = Dragger()
    local setXy = false
    local btnSizeIncrease = 2

    btn.Width:Set(btnWidth + (btnSizeIncrease*uiScale))
	btn.Height:Set(btnHeight + (btnSizeIncrease*uiScale))
    Tooltip.DestroyMouseoverDisplay() 
    

    drag.OnMove = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.constructionGroup, x, y)
            setXy = true 
        end
        moveFunction.resizeHorizontalRightToLeft(controls.constructionGroup, positionsTable, x, y)

        Tooltip.DestroyMouseoverDisplay()  
        btn:SetTexture(prefix..'_btn_down.dds')   
    end
    drag.OnRelease = function(dragself, x, y)
        if setXy == false then 
            positionsTable = moveFunction.returnPostionTable(controls.constructionGroup, x, y)
            setXy = true 
        end
        moveFunction.resizeHorizontalRightToLeft(controls.constructionGroup, positionsTable, x, y)

        savePosition.saveToPrefs(profileName, controls.constructionGroup, controls.constructionGroup.hidden)
        btn.Width:Set(btnWidth)
        btn.Height:Set(btnHeight) 
        btn:SetTexture(prefix..'_btn_over.dds')
    end
    PostDragger(self:GetRootFrame(), event.KeyCode, drag)
end

function setPosition(table, controlGroup)
    height = controls.constructionGroup.Height()
    width = controls.constructionGroup.Width()
    if table.savedPrefs == true then 
        controls.constructionGroup.Left:Set(table.left)  
        controls.constructionGroup.Top:Set(table.top)                      
        controls.constructionGroup.Right:Set(table.right)        
        controls.constructionGroup.Bottom:Set(table.top + height)
    end
end