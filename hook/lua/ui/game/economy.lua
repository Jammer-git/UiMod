do
    local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
	local Button = import('/lua/maui/button.lua').Button
	local Dragger = import('/lua/maui/dragger.lua').Dragger

	local buttons = import("/mods/CustomizeUI/src/buttons.lua")
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")

    local profileNameEconomy = "CustomizeUi_economyPanel"
    local lastSavedPosEconomy = Prefs.GetFromCurrentProfile(profileNameEconomy) or {savedTable = false}
    local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1

    local panelHeight = 70 --Default height on Ui 100%
    local uiScalePanelHeight = panelHeight * uiScale
    if uiScalePanelHeight - math.floor(uiScalePanelHeight) < 0.5 then
        roundedValuePanelHeight = math.floor(uiScalePanelHeight)
    else
        roundedValuePanelHeight = math.ceil(uiScalePanelHeight)
    end
    local panelWidth = 322  --Default width on Ui 100%
    local uiScalePanelWidth = panelWidth * uiScale
    if uiScalePanelWidth - math.floor(uiScalePanelWidth) < 0.5 then
        roundedValuePanelWidth = math.floor(uiScalePanelWidth)
    else
        roundedValuePanelWidth = math.ceil(uiScalePanelWidth)
    end

    local buttonSize = 20 * uiScale
    local buttonX_Offset = -11    
    local buttonY_Offset = 15
    local colapseArrowX_Offset = -9
    local colapseArrowY_Offset = 32

	oldCreateUI = CreateUI
	function CreateUI()
		oldCreateUI()
		ForkThread(function()
			WaitSeconds(0.1)
            GUI.collapseArrow.OnCheck = function(self, checked)
                if not GUI.bg:IsHidden() then
                    PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))                    
                    GUI.bg:Hide()
                else
                    PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))
                    GUI.bg:Show()
                end
            end

			LayoutHelpers.AtLeftTopIn(GUI.collapseArrow, GUI.bg, colapseArrowX_Offset, colapseArrowY_Offset)
            local buttonName = "EconomyGui.MoveButton1"
			GUI.bg.moveButton = buttons.createMoveButton(GUI.bg, startDragging, GUI.bg, buttonName, buttonSize)
			LayoutHelpers.AtLeftTopIn(GUI.bg.moveButton, GUI.bg, buttonX_Offset, buttonY_Offset)
            SetPosition(lastSavedPosEconomy)
		end)
	end

    function startDragging(self, event)
        local buttonHalfSize = buttonSize*0.5
		local drag = Dragger()
		drag.OnMove = function(dragself, x, y)
			GUI.bg.Left:Set(x - (buttonX_Offset + buttonHalfSize))
            local newLeft = GUI.bg.Left()
			GUI.bg.Top:Set(y - (buttonY_Offset + buttonHalfSize))
            local newTop = GUI.bg.Top()
			GUI.bg.Right:Set(newLeft + roundedValuePanelWidth)
			GUI.bg.Bottom:Set(newTop + roundedValuePanelHeight)
            drag.OnRelease = function(dragself, x, y)
                GUI.bg.Left:Set(x - (buttonX_Offset + buttonHalfSize))
                local newLeft = GUI.bg.Left()
                GUI.bg.Top:Set(y - (buttonY_Offset + buttonHalfSize))
                local newTop = GUI.bg.Top()
                GUI.bg.Right:Set(newLeft + roundedValuePanelWidth)
                GUI.bg.Bottom:Set(newTop + roundedValuePanelHeight)
                savePosition.Save(profileNameEconomy, GUI.bg)
            end
		end
		PostDragger(self:GetRootFrame(), event.KeyCode, drag)
	end

    function SetPosition(posTable) -- Keep setting the location for a few seconds Ui doesnt load in fast enough
        local count = 0
        ForkThread(function()
            WaitSeconds(2.5)
            while true do 
                if posTable.savedTable == true then 
                    GUI.bg.Left:Set(posTable.left)  
                    GUI.bg.Top:Set(posTable.top)
                    GUI.bg.Right:Set(posTable.left + roundedValuePanelWidth)
                    GUI.bg.Bottom:Set(posTable.top + roundedValuePanelHeight)
                    local newLeft = GUI.bg.Left()    
                end
                if posTable.savedTable == false then 
                    local oldOrdersLeft   = GUI.bg.Left()
                    local oldOrdersTop    = GUI.bg.Top()
                    local oldOrdersRight  = GUI.bg.Right()
                    local oldOrdersBottom = GUI.bg.Bottom()
                    GUI.bg.Left:Set(oldOrdersLeft)  
                    GUI.bg.Top:Set(oldOrdersTop)
                    GUI.bg.Right:Set(oldOrdersLeft + roundedValuePanelWidth)
                    GUI.bg.Bottom:Set(oldOrdersTop + roundedValuePanelHeight)
                    local newLeft = GUI.bg.Left()    
                end

                count = count + 1
                if count == 30 then 
                    break
                end
                WaitSeconds(0.1)
            end
        end)
    end
end

