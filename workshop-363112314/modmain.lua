local function revealer( inst )
	
	inst:DoTaskInTime( 0.001, function() 
	
				
	local minimap = TheSim:FindFirstEntityWithTag("minimap")

	
		if minimap then
			minimap.MiniMap:EnableFogOfWar(false)
		
		
		end
	end)
end



AddPrefabPostInit("forest", revealer )