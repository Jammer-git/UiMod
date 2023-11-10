do
    local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
	local Button = import('/lua/maui/button.lua').Button
	local Dragger = import('/lua/maui/dragger.lua').Dragger

	local buttons = import("/mods/CustomizeUI/src/buttons.lua")
    local savePosition = import("/mods/CustomizeUI/src/save_position.lua")

    local profileNameAvatars = "CustomizeUi_avatarsPanel"
    lastSavedPosAvatars = Prefs.GetFromCurrentProfile(profileNameAvatars) or {savedTable = false}
    local profileNameRotationAvatars = "CustomizeUi_avatarsRotationPanel"
    lastSavedPosRotationAvatars = Prefs.GetFromCurrentProfile(profileNameRotationAvatars) or {savedRotation = 1}
    uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1

    local panelHeight = 61 --Default height on Ui 100%
    local uiScalePanelHeight = panelHeight * uiScale
    if uiScalePanelHeight - math.floor(uiScalePanelHeight) < 0.5 then
        roundedValuePanelHeight = math.floor(uiScalePanelHeight)
    else
        roundedValuePanelHeight = math.ceil(uiScalePanelHeight)
    end
    local panelWidth = 200  --Default width on Ui 100%
    local uiScalePanelWidth = panelWidth * uiScale
    if uiScalePanelWidth - math.floor(uiScalePanelWidth) < 0.5 then
        roundedValuePanelWidth = math.floor(uiScalePanelWidth)
    else
        roundedValuePanelWidth = math.ceil(uiScalePanelWidth)
    end

    local buttonSize = 20 * uiScale
    local buttonX_Offset = 4    
    local buttonY_Offset = 33
    local colapseArrowX_Offset = 8
    local colapseArrowY_Offset = 48

    local buttonRotateX_Offset = 4
    local buttonRotateY_Offset = 14
    currentRotationLayout = lastSavedPosRotationAvatars.savedRotation
    local maxRotationLayouts = 3

	local oldCreateAvatarUI = CreateAvatarUI
	function CreateAvatarUI(parent)
	    oldCreateAvatarUI(parent)
		
		ForkThread(function()
			WaitSeconds(0.2)
            controls.collapseArrow.OnCheck = function(self, checked)
                if not controls.avatarGroup:IsHidden() then
                    PlaySound(Sound({Cue = "UI_Score_Window_Close", Bank = "Interface"}))
                    controls.avatarGroup:Hide()
                    self:SetNeedsFrameUpdate(false)
                else
                    PlaySound(Sound({Cue = "UI_Score_Window_Open", Bank = "Interface"}))
                    controls.avatarGroup:Show()
                    controls.avatarGroup:SetNeedsFrameUpdate(true) 
                end
            end
			LayoutHelpers.AtRightTopIn(controls.collapseArrow, controls.avatarGroup, colapseArrowX_Offset, colapseArrowY_Offset)
            local buttonName = "Avatars.MoveButton1"
			controls.avatarGroup.moveButton = buttons.createMoveButton(controls.avatarGroup, startDragging, controls.avatarGroup, buttonName, buttonSize)
    		LayoutHelpers.AtTopIn(controls.avatarGroup.moveButton, controls.avatarGroup, buttonY_Offset)
			LayoutHelpers.AtRightIn(controls.avatarGroup.moveButton, controls.avatarGroup, buttonX_Offset)
            local buttonName = "Avatars.RotateButton1"
			controls.avatarGroup.rotateButton = buttons.createRotateButton(controls.avatarGroup, startRotate, controls.avatarGroup, buttonName, buttonSize)
    		LayoutHelpers.AtTopIn(controls.avatarGroup.rotateButton, controls.avatarGroup, buttonRotateY_Offset)
			LayoutHelpers.AtRightIn(controls.avatarGroup.rotateButton, controls.avatarGroup, buttonRotateX_Offset)

            SetPosition(lastSavedPosAvatars)

            WaitSeconds(3.5)
            controls.avatarGroup.rotateButton:Hide()
		end)
	end

    function startDragging(self, event)
        local oldTop = controls.avatarGroup.Top()
        local oldBottom = controls.avatarGroup.Bottom()
        local currentPanelHeight = oldBottom - oldTop
        local buttonHalfSize = buttonSize*0.5
		local drag = Dragger()
		drag.OnMove = function(dragself, x, y)
			controls.avatarGroup.Right:Set(x + (buttonX_Offset + buttonHalfSize))
            local newRight = controls.avatarGroup.Right()            
			controls.avatarGroup.Top:Set(y - (buttonY_Offset + (buttonHalfSize * (uiScale * 1.2))))
            local newTop = controls.avatarGroup.Top()
			controls.avatarGroup.Left:Set(newRight + roundedValuePanelWidth)
			controls.avatarGroup.Bottom:Set(newTop + currentPanelHeight)
            drag.OnRelease = function(dragself, x, y)
                controls.avatarGroup.Right:Set(x + (buttonX_Offset + buttonHalfSize))
                local newRight = controls.avatarGroup.Right()            
                controls.avatarGroup.Top:Set(y - (buttonY_Offset + (buttonHalfSize * (uiScale * 1.2))))
                local newTop = controls.avatarGroup.Top()
                controls.avatarGroup.Left:Set(newRight + roundedValuePanelWidth)
                controls.avatarGroup.Bottom:Set(newTop + currentPanelHeight)
                savePosition.Save(profileNameAvatars, controls.avatarGroup)
            end
		end
		PostDragger(self:GetRootFrame(), event.KeyCode, drag)
	end

    function startRotate(self, event)
        LOG("Log current Saved Avatars Rotation First: " ..repr(currentRotationLayout))
        if currentRotationLayout < maxRotationLayouts then
            currentRotationLayout = currentRotationLayout + 1
            savePosition.SaveRotation(profileNameRotationAvatars, currentRotationLayout) 
            controls.avatarGroup:SetNeedsFrameUpdate(true) 
        else
            currentRotationLayout = 1
            savePosition.SaveRotation(profileNameRotationAvatars, currentRotationLayout) 
            controls.avatarGroup:SetNeedsFrameUpdate(true) 
        end
        LOG("Log current Saved Avatars Rotation: Last" ..repr(currentRotationLayout))
    end

    function SetPosition(posTable)
        local oldTop = controls.avatarGroup.Top()
        local oldBottom = controls.avatarGroup.Bottom()
        local currentPanelHeight = oldBottom - oldTop
        if posTable.savedTable == true then 
            controls.avatarGroup.Right:Set(posTable.right)  
            controls.avatarGroup.Top:Set(posTable.top)                      
            controls.avatarGroup.Left:Set(posTable.right + roundedValuePanelWidth)        
            controls.avatarGroup.Bottom:Set(posTable.top + currentPanelHeight)
        end
    end


end

function CreateIdleTab(unitData, id, expandFunc)
    local controls = import("/lua/ui/game/avatars.lua").controls
    local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1

    local bg = Bitmap(controls.avatarGroup, UIUtil.SkinnableFile('/game/avatar/avatar-s-e-f_bmp.dds'))
    bg.id = id
    bg.tooltipKey = 'mfd_idle_'..id

    bg.allunits = unitData
    bg.units = unitData

    bg.icon = Bitmap(bg)
    LayoutHelpers.AtLeftTopIn(bg.icon, bg, 7, 8)
    bg.icon:SetSolidColor('00000000')
    LayoutHelpers.SetDimensions(bg.icon, 34, 34)
    bg.icon:DisableHitTest()

    bg.count = UIUtil.CreateText(bg.icon, '', 18, UIUtil.bodyFont)
    bg.count:DisableHitTest()
    bg.count:SetDropShadow(true)
    LayoutHelpers.AtBottomIn(bg.count, bg.icon)
    LayoutHelpers.AtRightIn(bg.count, bg.icon)

    bg.expandCheck = Checkbox(bg,returnCheckTextures())
    setupCheckbox(bg)
    --setupBracket(bg)

    

    bg.expandCheck.OnCheck = function(self, checked)
        if checked then
            if expandedCheck and expandedCheck ~= bg.id and GetCheck(expandedCheck) then
                GetCheck(expandedCheck):SetCheck(false)
            end
            expandedCheck = bg.id
            self.expandList = expandFunc(self, bg.units)
            expandFuncExtraSetting(self, checked, bg)
        else
            expandedCheck = false
            if self.expandList then
                self.expandList:Destroy()
                self.expandList = nil
            end
        end
    end



    bg.curIndex = 1
    bg.HandleEvent = ClickFunc
    bg.Update = function(self, units)
        self.allunits = units
        self.units = {}
        if self.id == 'engineer' then
            local sortedUnits = {}
            sortedUnits[5] = EntityCategoryFilterDown(categories.SUBCOMMANDER, self.allunits)
            sortedUnits[4] = EntityCategoryFilterDown(categories.TECH3 - categories.SUBCOMMANDER, self.allunits)
            sortedUnits[3] = EntityCategoryFilterDown(categories.FIELDENGINEER, self.allunits)
            sortedUnits[2] = EntityCategoryFilterDown(categories.TECH2 - categories.FIELDENGINEER, self.allunits)
            sortedUnits[1] = EntityCategoryFilterDown(categories.TECH1, self.allunits)

            local keyToIcon = {'T1','T2','T2F','T3','SCU'}

            local i = table.getn(sortedUnits)
            local needIcon = true
            while i > 0 do
                if not table.empty(sortedUnits[i]) then
                    if needIcon then
                        -- Idle engineer icons
                        if Factions[currentFaction].IdleEngTextures[keyToIcon[i]] and UIUtil.UIFile(Factions[currentFaction].IdleEngTextures[keyToIcon[i]],true) then
                            self.icon:SetTexture(UIUtil.UIFile(Factions[currentFaction].IdleEngTextures[keyToIcon[i]],true))
                        else
                            self.icon:SetTexture(UIUtil.UIFile(Factions[currentFaction].IdleEngTextures['T2']))
                        end
                        needIcon = false
                    end
                    for _, unit in sortedUnits[i] do
                        table.insert(self.units, unit)
                    end
                end
                i = i - 1
            end
        elseif self.id == 'factory' then
            local categoryTable = {'LAND','AIR','NAVAL'}
            local sortedFactories = {}
            for i, cat in categoryTable do
                sortedFactories[i] = {}
                sortedFactories[i][1] = EntityCategoryFilterDown(categories.TECH1 * categories[cat], self.allunits)
                sortedFactories[i][2] = EntityCategoryFilterDown(categories.TECH2 * categories[cat], self.allunits)
                sortedFactories[i][3] = EntityCategoryFilterDown(categories.TECH3 * categories[cat], self.allunits)
            end

            local i = 3
            local needIcon = true
            while i > 0 do
                for curCat = 1, 3 do
                    if not table.empty(sortedFactories[curCat][i]) then
                        if needIcon then
                            -- Idle factory icons
                            if UIUtil.UIFile(Factions[currentFaction].IdleFactoryTextures[categoryTable[curCat]][i],true) then
                                self.icon:SetTexture(UIUtil.UIFile(Factions[currentFaction].IdleFactoryTextures[categoryTable[curCat]][i],true))
                            else
                                self.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
                            end
                            needIcon = false
                        end
                        for _, unit in sortedFactories[curCat][i] do
                            table.insert(self.units, unit)
                        end
                    end
                end
                i = i - 1
            end
           if needIcon == true then
               local ExpFactories = EntityCategoryFilterDown(categories.EXPERIMENTAL, self.allunits)
               if not table.empty(ExpFactories) then
                   local FactoryUnitId = ExpFactories[1]:GetUnitId()
                   if UIUtil.UIFile('/icons/units/' .. FactoryUnitId .. '_icon.dds', true) then
                       self.icon:SetTexture(UIUtil.UIFile('/icons/units/' .. FactoryUnitId .. '_icon.dds', true))
                   else
                       self.icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
                   end
               end
           end
        end
        self.count:SetText(table.getsize(self.allunits))

        if self.expandCheck.expandList then
            self.expandCheck.expandList:Update(self.allunits)
            
        end
    end

    return bg
end

function returnCheckTextures()
    local prefix = "/mods/CustomizeUI/src/icons/avatar_collapse_btn/avatar_arrow_btn_"
	return 
    UIUtil.SkinnableFile(prefix .. "tab-open.dds"),    
    UIUtil.SkinnableFile(prefix .. "tab-close.dds"),     	
    UIUtil.SkinnableFile(prefix .. "tab-open.dds"),  
    UIUtil.SkinnableFile(prefix .. "tab-close.dds"),     	
    UIUtil.SkinnableFile(prefix .. "tab-open.dds"),
    UIUtil.SkinnableFile(prefix .. "tab-close.dds")
end

function setupCheckbox(bg)
    LayoutHelpers.AtLeftIn(bg.expandCheck, bg, 0)
    LayoutHelpers.AtBottomIn(bg.expandCheck, bg, 0)

    bg.expandCheck.Height:Set(16 * uiScale)
    bg.expandCheck.Width:Set(16 * uiScale)
end



function expandFuncExtraSetting(self, checked, bg)
    if currentRotationLayout == 1 then  --Vertical Layout 
        -- do nothing default setup
    elseif currentRotationLayout == 2 then-- horizontal layout 1
        local expandListOffsetX = 0
        local expandListOffsetY = 0
        if self.expandList.icons[1] == nil then -- factories doesnt have this so we can set different x,y
            --Factories tab
            expandListOffsetX = 65 * uiScale
            expandListOffsetY = 34 * uiScale
        else    
            --Engineers tab

            expandListOffsetX = 58 * uiScale
            expandListOffsetY = 44 * uiScale
        end
        --LOG("avatars.lua .. self.expandList.Depth : " .. repr(self.expandList.Depth()))
        self.expandList.Left:Set(self.expandList:Left() + expandListOffsetX)            
        self.expandList.Top:Set(self.expandList:Top() + expandListOffsetY)
        self.expandList.Right:Set(self.expandList:Left() + self.expandList:Width())
        self.expandList.Bottom:Set(self.expandList:Top() + self.expandList:Height())
        self.expandList.Depth:Set((self.expandList.Depth() - self.expandList.Depth()) + 10)
    elseif currentRotationLayout == 3 then-- horizontal layout 1
        local expandListOffsetX = 0
        local expandListOffsetY = 0
        if self.expandList.icons[1] == nil then -- factories doesnt have this so we can set different x,y
            --Factories tab
            expandListOffsetX = 66 * uiScale
            expandListOffsetY = 71 * uiScale
        else    
            --Engineers tab

            expandListOffsetX = 58 * uiScale
            expandListOffsetY = 95 * uiScale
        end
        --LOG("avatars.lua .. self.expandList.Depth : " .. repr(self.expandList.Depth()))
        self.expandList.Left:Set(self.expandList:Left() + expandListOffsetX)            
        self.expandList.Top:Set(self.expandList:Top() + expandListOffsetY)
        self.expandList.Right:Set(self.expandList:Left() + self.expandList:Width())
        self.expandList.Bottom:Set(self.expandList:Top() + self.expandList:Height())
        self.expandList.Depth:Set((self.expandList.Depth() - self.expandList.Depth()) + 10)
    else
        --if there are more maxRotationLayouts then rotationLayouts then set default
    end 
end