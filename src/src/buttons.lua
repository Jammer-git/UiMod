local UIUtil = import('/lua/ui/uiutil.lua')
local Button = import('/lua/maui/button.lua').Button
local Tooltip = import('/lua/ui/game/tooltip.lua')

local Prefs = import('/lua/user/prefs.lua')



buttonsTable = {}

function createMoveButton(Parent, startDragging, returnToDragging, button, buttonSize)
    local toolTipTable1 = {text = "Double Click To Lock/Unlock"}
    local toolTipTable2 = {text = "Select and Drag to Position"}
    local toolTipTable3 = {text = "Select and Drag to change Width"}

    factionId = Prefs.GetFromCurrentProfile('skin')

    local buttonType = "move"
    local buttonName = button   
    local buttonSizeX = buttonSize
    local buttonSizeY = buttonSize

    button = createButton(Parent, buttonType, factionId,buttonSizeX, buttonSizeY)

    local buttonTable = {
        buttonName = buttonName,
        button = button
        }
    table.insert(buttonsTable, buttonTable)

	local Handler = function(self, event) end
	if startDragging then
		Handler = function(self, event)
			if event.Type == 'MouseEnter' then
                PlaySound(Sound({Cue = "UI_Tab_Rollover_01", Bank = "Interface"}))
                if button.Disabled == true then 
                    Tooltip.CreateMouseoverDisplay(self, toolTipTable1, 0, true) -- Double Click To Lock/Unlock
                end
                if button.Disabled == false then
                    self:SetTexture(self.mHighlight)                    
                    if buttonName == "Construction.ResizeButton1" then 
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable3, 0, true) -- Select and Drag to change Width
                    else
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable2, 0, true) -- Select and Drag to Position
                    end
                end
			elseif event.Type == 'MouseExit' then
                Tooltip.DestroyMouseoverDisplay()
                if button.Disabled == false then
                    self:SetTexture(self.mDisabled)
                end
			elseif event.Type == 'ButtonPress' then
                if button.Disabled == false then
                    PlaySound(Sound({Cue = "UI_Tab_Click_01", Bank = "Interface"}))
		            self:SetTexture(self.mActive)
                    startDragging(returnToDragging, event)
                else
                    PlaySound(Sound({Cue = "UI_Tab_Click_02", Bank = "Interface"}))
                end
            elseif event.Type == 'ButtonDClick' then
                if button.Disabled == false then
                    LOG("buttons.lua : ".. repr(buttonName) .." = disabled")
                    PlaySound(Sound({Cue = "UI_Tab_Click_02", Bank = "Interface"}))
                    self:SetTexture(self.mNormal)
                    button.Disabled = true
                    Tooltip.DestroyMouseoverDisplay()
                    Tooltip.CreateMouseoverDisplay(self, toolTipTable1, 0, true)                 
                    enableDisableExtraFunctions(button.Disabled, buttonName)
                elseif button.Disabled == true then
                    LOG("buttons.lua : ".. repr(buttonName) .." = enabled")
                    PlaySound(Sound({Cue = "UI_Tab_Click_02", Bank = "Interface"}))
                    self:SetTexture(self.mDisabled)
                    button.Disabled = false
                    Tooltip.DestroyMouseoverDisplay() -- Double Click To Lock/Unlock
                    if buttonName == "Construction.ResizeButton1" then 
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable3, 0, true) -- Select and Drag to change Width
                    else
                        Tooltip.CreateMouseoverDisplay(self, toolTipTable2, 0, true) -- Select and Drag to Position
                    end
                    enableDisableExtraFunctions(button.Disabled, buttonName)
                end
			end
        end
		button.HandleEvent = Handler
	end
	button:EnableHitTest()
	return button
end

function createRotateButton(Parent, startRotate, returnToRotate, button, buttonSize)
    local toolTipTable1 = {text = "Click To Rotate Layouts"}

    local buttonType = "rotate"
    local buttonName = button   
    local buttonSizeX = buttonSize
    local buttonSizeY = buttonSize

    button = createButton(Parent, buttonType, factionId, buttonSizeX, buttonSizeY)

    local buttonTable = {
        buttonName = buttonName,
        button = button
        }
    table.insert(buttonsTable, buttonTable)

	local Handler = function(self, event) end
	if startRotate then
		Handler = function(self, event)
			if event.Type == 'MouseEnter' then

                self:SetTexture(self.mHighlight)
                Tooltip.AddCheckboxTooltip(self, toolTipTable1)  
			elseif event.Type == 'MouseExit' then
                self:SetTexture(self.mNormal)
                Tooltip.DestroyMouseoverDisplay()
			elseif event.Type == 'ButtonPress' then
                PlaySound(Sound({Cue = "UI_Tab_Click_01", Bank = "Interface"}))
                self:SetTexture(self.mActive)                
                startRotate(returnToRotate, event)
                import(UIUtil.GetLayoutFilename('avatars')).LayoutAvatars()
                --import("/lua/ui/game/avatars.lua")
                --local avatars = import("/lua/ui/game/avatars.lua")
                --avatars.CreateIdleTab(EntityCategoryFilterDown(categories.ALLUNITS - categories.GATE, factories), 'factory', expandFunc)
            elseif event.Type == 'ButtonDClick' then

			end
        end
		button.HandleEvent = Handler
	end
	button:EnableHitTest()
	return button
end

function createButton(Parent, buttonType, factionId, buttonSizeX, buttonSizeY)
	button = Button(Parent)
    button.Disabled = true
	button:SetNewTextures(GetButtonTextures(buttonType, factionId))
	button:Enable()
	button.Width:Set(buttonSizeX)
	button.Height:Set(buttonSizeY)    
    button.Depth:Set(function() return Parent.Depth() + 100 end)
    return button
end

function GetButtonTextures(buttonType, factionId)
    if factionId == "cyrban" or "uef" or "aeon" or "seraphim" then 
    else 
        factionId = "uef"
    end
	local prefix = "/mods/CustomizeUI/src/icons/"..buttonType.."_btn/"..factionId.."_btn_"
	return 	
    UIUtil.SkinnableFile(prefix .. "dis.dds"),          --self.mNormal = disabled so its looks turned off by start
    UIUtil.SkinnableFile(prefix .. "down.dds"),         --self.mActive
    UIUtil.SkinnableFile(prefix .. "over.dds"),         --self.mHighlight
    UIUtil.SkinnableFile(prefix .. "up.dds")            --self.mDisabled = enabled
end



function enableDisableExtraFunctions(boolean, buttonName)
    if boolean == false then -- Turn on extra functions
        if buttonName == "Avatars.MoveButton1" then 
            for i, table in buttonsTable do 
                if table.buttonName == "Avatars.RotateButton1" then 
                    table.button:Show()
                end
            end
        end
    else -- Turn off extra functions
        if buttonName == "Avatars.MoveButton1" then 
            for i, table in buttonsTable do 
                if table.buttonName == "Avatars.RotateButton1" then 
                    table.button:Hide()
                end
            end
        end
    end
end

