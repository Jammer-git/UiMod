local UIUtil = import("/lua/ui/uiutil.lua")
local LayoutHelpers = import("/lua/maui/layouthelpers.lua")



function SetLayout()
    local controls = import("/lua/ui/game/avatars.lua").controls

    LayoutHelpers.AtRightTopIn(controls.avatarGroup, controls.parent, 0, 200)
    LayoutHelpers.SetDimensions(controls.avatarGroup, 200, 0)

    controls.bgTop:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_t.dds'))
    controls.bgStretch:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_m.dds'))
    controls.bgBottom:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_b.dds'))

    LayoutHelpers.AtTopIn(controls.collapseArrow, controls.avatarGroup, 22)
    LayoutHelpers.AtRightIn(controls.collapseArrow, controls.parent, -3)

    LayoutHelpers.AtRightIn(controls.bgTop, controls.avatarGroup)
    LayoutHelpers.AtRightIn(controls.bgBottom, controls.avatarGroup)

    LayoutHelpers.AnchorToTop(controls.bgTop, controls.avatarGroup, -70)
    controls.bgBottom.Top:Set(function() return math.max(controls.bgTop.Bottom(), controls.avatarGroup.Bottom() + 0) end)
    LayoutHelpers.AnchorToBottom(controls.bgStretch, controls.bgTop)
    LayoutHelpers.AnchorToTop(controls.bgStretch, controls.bgBottom)
    LayoutHelpers.AtRightIn(controls.bgStretch, controls.bgTop, 7)

    LayoutHelpers.DepthOverParent(controls.collapseArrow, controls.bgTop)
    controls.collapseArrow:SetTexture(UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_up.dds'))
    controls.collapseArrow:SetNewTextures(UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_up.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_up.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_over.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_over.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_dis.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_dis.dds'))

    LayoutAvatars()
end

function LayoutAvatars()
    --LOG("avatars_mini.lua Check currentLayout .. " ..repr(GetCurrentRotation()))
    if GetCurrentRotation() == 1 then 
        Layout1() -- default vertical layout
    elseif GetCurrentRotation() == 2 then 
        Layout2() -- horizontal layout 1
    elseif GetCurrentRotation() == 3 then 
        Layout3() -- horizontal layout 2
    else
        Layout1() --if there are more maxRotationLayouts then rotationLayouts then set default
    end
end

function GetCurrentRotation()
    local Prefs = import('/lua/user/prefs.lua')
    local profileNameRotationAvatars = "CustomizeUi_avatarsRotationPanel"
    local lastSavedPosRotationAvatars = Prefs.GetFromCurrentProfile(profileNameRotationAvatars) or {savedRotation = 1}
    local currentRotation = lastSavedPosRotationAvatars.savedRotation
    return currentRotation
end



function Layout1() -- default vertical layout
    local controls = import("/lua/ui/game/avatars.lua").controls

    local rightOffset, topOffset, space = 14, 14, -5

    local prevControl2 = false
    local height = 0
    for _, control in controls.avatars do
        if prevControl2 then
            LayoutHelpers.AnchorToBottom(control, prevControl2, space)
            --control.Top:Set(function() return prevControl2.Bottom() + space end)
            LayoutHelpers.AtRightIn(control, prevControl2)
            height = height + (control.Bottom() - prevControl2.Bottom())
        else
            LayoutHelpers.AtRightTopIn(control, controls.avatarGroup, rightOffset, topOffset)
            height = control.Height()
        end
        prevControl2 = control
    end
    if controls.idleEngineers then
        if prevControl2 then
            controls.idleEngineers.prevControl2 = prevControl2
            LayoutHelpers.AnchorToBottom(controls.idleEngineers, controls.idleEngineers.prevControl2, space)
            LayoutHelpers.AtRightIn(controls.idleEngineers, controls.idleEngineers.prevControl2)
            height = height + (controls.idleEngineers.Bottom() - controls.idleEngineers.prevControl2.Bottom())
        else
            LayoutHelpers.AtRightTopIn(controls.idleEngineers, controls.avatarGroup, rightOffset, topOffset)
            height = controls.idleEngineers.Height()
        end
        prevControl2 = controls.idleEngineers
    end
    if controls.idleFactories then
        if prevControl2 then
            controls.idleFactories.prevControl2 = prevControl2
            LayoutHelpers.AnchorToBottom(controls.idleFactories, controls.idleFactories.prevControl2, space)
            LayoutHelpers.AtRightIn(controls.idleFactories, controls.idleFactories.prevControl2)
            height = height + (controls.idleFactories.Bottom() - controls.idleFactories.prevControl2.Bottom())
        else
            LayoutHelpers.AtRightTopIn(controls.idleFactories, controls.avatarGroup, rightOffset, topOffset)
            height = controls.idleFactories.Height()
        end
    end

    controls.avatarGroup.Height:Set(function() return height - LayoutHelpers.ScaleNumber(5) end)
end

function Layout2() -- horizontal layout 1
    local Prefs = import('/lua/user/prefs.lua')
    local controls = import("/lua/ui/game/avatars.lua").controls

    local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1

    local rightOffset, topOffset, space = 14, 14, -5


    -- Doesnt need manual scaling
    local defaultAvatarHeight = 46 --Default 46
    local defaultAvatarWidth = 54  --Default 54
    local defaultIdleEngineersHeight = 46 --Default 46
    local defaultIdleEngineersWidth = 54 --Default 62


    local prevControl2 = false
    for _, control in controls.avatars do
        if prevControl2 then
            LayoutHelpers.AtRightTopIn(control, controls.avatarGroup, rightOffset + defaultAvatarWidth, topOffset)
            rightOffset = rightOffset + defaultAvatarWidth
        else
            LayoutHelpers.AtRightTopIn(control, controls.avatarGroup, rightOffset, topOffset)
        end
        prevControl2 = control
    end
    if controls.idleEngineers then 
        if prevControl2 then
            controls.idleEngineers.prevControl2 = prevControl2
            LayoutHelpers.AtRightTopIn(controls.idleEngineers, controls.avatarGroup, rightOffset + defaultIdleEngineersWidth, topOffset)

            rightOffset = rightOffset + defaultIdleEngineersWidth
        else
            LayoutHelpers.AtRightTopIn(controls.idleEngineers, controls.avatarGroup, rightOffset, topOffset)
        end
        prevControl2 = controls.idleEngineers
    end
    if controls.idleFactories then
        if prevControl2 then
            controls.idleFactories.prevControl2 = prevControl2
            LayoutHelpers.AtRightTopIn(controls.idleFactories, controls.avatarGroup, rightOffset + defaultIdleEngineersWidth, topOffset)
            rightOffset = rightOffset + defaultIdleEngineersWidth
        else
            LayoutHelpers.AtRightTopIn(controls.idleFactories, controls.avatarGroup, rightOffset, topOffset)
        end
        prevControl2 = controls.idleFactories
    end
end

function Layout3() -- horizontal layout 2
    local Prefs = import('/lua/user/prefs.lua')
    local controls = import("/lua/ui/game/avatars.lua").controls

    local uiScale = Prefs.GetFromCurrentProfile('options').ui_scale or 1

    local rightOffset1, topOffset1, space = 15, 7, -5
    local rightOffset2, topOffset2, space2 = 18, 65, -5

    -- Doesnt need manual scaling
    local defaultAvatarHeight = 46 --Default 46
    local defaultAvatarWidth = 54  --Default 54
    local defaultIdleEngineersHeight = 46 --Default 46
    local defaultIdleEngineersWidth = 54 --Default 62

    local prevControl1 = false
    local prevControl2 = false    
    local height = 0
    for _, control in controls.avatars do
        if prevControl1 then
            LayoutHelpers.AtRightTopIn(control, controls.avatarGroup, rightOffset1 + defaultAvatarWidth, topOffset1)
            rightOffset1 = rightOffset1 + defaultAvatarWidth
        else
            LayoutHelpers.AtRightTopIn(control, controls.avatarGroup, rightOffset1, topOffset1)
        end
        prevControl1 = control
    end
    if controls.idleEngineers then
        if prevControl2 then
            LayoutHelpers.AtRightTopIn(controls.idleEngineers, controls.avatarGroup, rightOffset2, topOffset2)
            rightOffset2 = rightOffset2 + defaultIdleEngineersWidth
        else
            LayoutHelpers.AtRightTopIn(controls.idleEngineers, controls.avatarGroup, rightOffset2, topOffset2)
        end
        prevControl2 = controls.idleEngineers
    end
    if controls.idleFactories then
        if prevControl2 then
            controls.idleFactories.prevControl2 = prevControl2
            LayoutHelpers.AtRightTopIn(controls.idleFactories, controls.avatarGroup, rightOffset2 + defaultIdleEngineersWidth, topOffset2)
            rightOffset2 = rightOffset2 + defaultIdleEngineersWidth
        else
            LayoutHelpers.AtRightTopIn(controls.idleFactories, controls.avatarGroup, rightOffset2, topOffset2)
        end
        prevControl2 = controls.idleFactories
    end
end
