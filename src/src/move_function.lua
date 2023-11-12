function returnPostionTable(controlGroup, x, y)
    local table = {
    xOnStartMoving = x,
    yOnStartMoving = y,
    oldPanelLeft = controlGroup.Left(),
    oldPanelTop = controlGroup.Top(),
    oldPanelRight = controlGroup.Right(),
    oldPanelBottom = controlGroup.Bottom()
    }
    return table
end

function resizeHorizontalRightToLeft(controlGroup, table, x, y)
    local minWidthPanel = 330
    local currentHeight = controlGroup.Height()
    local currentWidth = controlGroup.Width()
    controlGroup.Left:Set(table.oldPanelLeft)     
    controlGroup.Top:Set(table.oldPanelTop)
    if x > controlGroup.Left()  + minWidthPanel then 
        controlGroup.Right:Set(x)  
    else
        controlGroup.Right:Set(table.oldPanelLeft + minWidthPanel) 
    end
    controlGroup.Bottom:Set(table.oldPanelBottom)
end

function movePanelLeftTopRightBottom(controlGroup, table, x, y)
    local currentHeight = controlGroup.Height()
    local currentWidth = controlGroup.Width()
    controlGroup.Left:Set(table.oldPanelLeft + (x - table.xOnStartMoving))
    local newLeft = controlGroup.Left()   
    controlGroup.Top:Set(table.oldPanelTop + (y - table.yOnStartMoving))
    local newTop = controlGroup.Top() 
    controlGroup.Right:Set(newLeft + currentWidth)  
    controlGroup.Bottom:Set(newTop + currentHeight)
end

function movePanelRightTopLeftBottom(controlGroup, table, x, y)
    local currentHeight = controlGroup.Height()
    local currentWidth = controlGroup.Width()
    controlGroup.Right:Set(table.oldPanelRight + (x - table.xOnStartMoving))
    local newRight = controlGroup.Right()   
    controlGroup.Top:Set(table.oldPanelTop + (y - table.yOnStartMoving))
    local newTop = controlGroup.Top() 
    controlGroup.Left:Set(newRight + currentWidth)  
    controlGroup.Bottom:Set(newTop + currentHeight)
end

function movePanelLeftBottom(controlGroup, table, x, y)
    controlGroup.Left:Set(table.oldPanelLeft + (x - table.xOnStartMoving))
    controlGroup.Bottom:Set(table.oldPanelBottom + (y - table.yOnStartMoving))
end