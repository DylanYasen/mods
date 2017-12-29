--===============================================================
-- Vars
--===============================================================
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH

require "prefabutil"
--===============================================================
-- Functions
--===============================================================

function SetupNetwork(inst)
	inst.entity:AddNetwork()
end

---------------------------------------------------------
-- Light for Multiplayer Portal

AddPrefabPostInit("multiplayer_portal", function(inst)
	if GetModConfigData("enable_light_near_respawnportal") == 1 then
		inst.entity:AddLight()
		inst.Light:Enable(false)
		inst.Light:SetColour(217/255, 61/255, 69/255)
		inst.Light:SetRadius(5)
		inst.Light:SetFalloff(6)
		inst.Light:SetIntensity(.5)
	
		inst:DoPeriodicTask(1, function(inst)
		if GLOBAL.TheWorld.state.isnight then
				inst.Light:Enable(true)    
			else
				inst.Light:Enable(false)
			end
		end)
	end
end)
------------------------------------------------------------
-- Skeleton

function SkeletonSetup(inst)
	if GetModConfigData("disable_skeleton_collision") == 0 then
		GLOBAL.RemovePhysicsColliders(inst)
	end
	
	if GetModConfigData("remove_skeleton_on_death") == 1 then
		inst.entity:Hide()
		inst:DoTaskInTime(0, inst.Remove)
	end
end
AddPrefabPostInit("skeleton_player", SkeletonSetup)

----------------------------------------------------------------
-- Penalty

if GetModConfigData("disable_revive_penalty_onrespawn") == 0 then
	GLOBAL.TUNING.REVIVE_HEALTH_PENALTY_AS_MULTIPLE_OF_EFFIGY = 0
	GLOBAL.TUNING.EFFIGY_HEALTH_PENALTY = 0
elseif GetModConfigData("disable_revive_penalty_onrespawn") == 20 then
	GLOBAL.TUNING.REVIVE_HEALTH_PENALTY_AS_MULTIPLE_OF_EFFIGY = 1
	GLOBAL.TUNING.EFFIGY_HEALTH_PENALTY = 20
elseif GetModConfigData("disable_revive_penalty_onrespawn") == 40 then
	GLOBAL.TUNING.REVIVE_HEALTH_PENALTY_AS_MULTIPLE_OF_EFFIGY = 1
	GLOBAL.TUNING.EFFIGY_HEALTH_PENALTY = 40
elseif GetModConfigData("disable_revive_penalty_onrespawn") == 50 then
	GLOBAL.TUNING.REVIVE_HEALTH_PENALTY_AS_MULTIPLE_OF_EFFIGY = 1
	GLOBAL.TUNING.EFFIGY_HEALTH_PENALTY = 50
end


--===============================================================