do
	local oldSetLayout = SetLayout
	function SetLayout()
		oldSetLayout()
		
		local unitviewctrls = import('/lua/ui/game/unitview.lua').controls
		local control = import('/lua/ui/game/unitviewDetail.lua').View
		LayoutHelpers.AtLeftTopIn(control, unitviewctrls.bg)
	end
end