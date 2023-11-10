local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Tooltip = import("/lua/ui/game/tooltip.lua")

local buttons = import("/mods/CustomizeUI/src/buttons.lua")

local Prefs = import('/lua/user/prefs.lua')
local skin = Prefs.GetFromCurrentProfile('skin')


local oldCreateUI = CreateUI
local oldSetLayout = SetLayout
function CreateUI()
	oldCreateUI()
    customizeUiSetup()
end
function SetLayout(layout)
	oldSetLayout(layout)
end

function customizeUiSetup()
    ForkThread(function()  
        WaitSeconds(1.1) 
        controlers = getControls()
        --GetPanelControlers(controlers)
        local currentLayout = UIUtil.currentLayout


        --ConExecute("cam_ShakeMult 0")
        --LOG("gamemail.lua ..")
        --LOG("gamemail.lua ..")
        --LOG("gamemail.lua ..")
        --LOG("gamemail.lua .. Prefs : " ..repr(skin))
        --LOG("gamemail.lua .. Prefs : " ..repr(Prefs))        
    end)   
end

function getControls()
	return 
    {
    --worldview = import('/lua/ui/game/worldview.lua'),
	orders = import('/lua/ui/game/orders.lua'),
	construction = import('/lua/ui/game/construction.lua'),
	multifunction = import('/lua/ui/game/multifunction.lua'),    
	unitview = import('/lua/ui/game/unitview.lua'),
	economy = import('/lua/ui/game/economy.lua'),
	score = import('/lua/ui/game/score.lua'),
	avatars = import('/lua/ui/game/avatars.lua'),
	--tabs = import('/lua/ui/game/tabs.lua'),
	controlgroups = import('/lua/ui/game/controlgroups.lua'),
    objectives2 = import('/lua/ui/game/objectives2.lua')
    }
end


function GetPanelControlers(controlers)
    for i, func in controlers.controlgroups do
        LOG("controlers.. Name " .. repr(i))
        LOG("controlers.. func " .. repr(func))
        local isFuncTable = table.empty2(func)
        if isFuncTable == false then 
            LOG("..........")
            LOG("..........")
            for z, func2 in func do 
                LOG("controls.. MainName " .. repr(i))
                LOG("controls.. SecondName :"..repr(z) .. " func2 :" .. repr(func2))
            end
            LOG("..........")
            LOG("..........")
        end
    end  
    --LOG("controls.Bottom: " ..            repr(controlers.avatars.controls.avatarGroup.Bottom()))
    --LOG("controls.Left: " ..              repr(controlers.avatars.controls.avatarGroup.Left()))
    --LOG("controls.Right: " ..             repr(controlers.avatars.controls.avatarGroup.Right()))
    --LOG("controls.Top: " ..               repr(controlers.avatars.controls.avatarGroup.Top()))
    --LOG("controls.Height: " ..            repr(controlers.avatars.controls.avatarGroup.Height()))
    --LOG("controls.Width: " ..             repr(controlers.avatars.controls.avatarGroup.Width()))
    --LOG("controls.Depth: " ..             repr(controlers.avatars.controls.avatarGroup.Depth()))
    --LOG("controls.HandleEvent: " ..       repr(controlers.avatars.controls.avatarGroup.HandleEvent()))
end





# how does this work ? lazyvar.ExtendedErrorMessages

###############TODO###############

############### General stuff ###############
#[ ]    force  UIUtil.currentLayout to always be "bottom" or els other "Panel_Mini.lua" panels are used and kinda breaks stuff
        #NOTE() currentLayout = if bottom "orders panel is left" if right "orders panel right" if left "orders and construction panel are left Vertical"
#[ ]    ToolTips broken                      
        #NOTE() i does work but you need to exit and enter twice for it to change
        #NOTE() First time entering button does not show tooltip
#[x]    Make Icons UI faction "color" reference change "move buttons" to color of faction 
#[x]    Addback Sound when open close panel
#[x]    Add sound to buttons


############### mod_info.lua ###############
#[x]    Check if placed After Supreme score board fixes certain bugs  

############### Avatars.lua ###############
#[x]    Make Rotation Layout possible
#[x]    Make Rotation Button Texture
#[x]    Reset Avatars when different layout is picked currently       

#[x]    Remove red lines when Layout 1 is selected                    
        #NOTE() group.connector:Hide() is the red lines. group is local tho not sure how to get to that

#[x]    Set Old Collapse Button if layout 2 is selected
#[x]    Make Different Rotate Icon
#[x]    Add layout Horizontal commanders top then factories and engineers below

#[ ]    Set the bracket size when rotate
 
############### UnitView.lua ###############
#[ ]    Make button to hide Detailed Unit view
#[ ]    Make Eye icon for hiding a Panel

############### Construction.lua  ###############

#[ ]    Make vertical layout for Orders panel        # not sure if is needed  
#[ ]    Make vertical layout for construction panel  # not sure if is needed 



############### Score.lua TODO  ###############

############### Objectives.lua TODO  ###############

############### MenuBar TODO  ###############
#[ ]    Add button to reset all panels to center of screen
#[ ]    Add button for No shake setting