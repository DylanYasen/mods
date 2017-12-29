   assets =
{
   Asset("ANIM", "anim/alwaysontikitorch.zip"),
   Asset("SOUND", "sound/common.fsb"),
}
   local prefabs = 
{
  "tikitorchflame",
}

local function onhammered(inst, worker)
	  inst.components.lootdropper:DropLoot()
	  inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	  inst:Remove()
end	

local function onhit(inst,worker)
	  inst.AnimState:PlayAnimation("hit")
	  inst.AnimState:PushAnimation("idle")
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pigtorch")
    inst.AnimState:SetBuild("alwaysontikitorch")
    inst.AnimState:PlayAnimation("idle", true)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "alwaysontikitorch.tex" )

    inst:AddTag("campfire")

    if not TheWorld.ismastersim then
    return inst
end

    inst.entity:SetPristine()  

    MakeObstaclePhysics(inst, .33)

    inst:AddComponent("inspectable")

    inst:AddComponent("burnable")
    inst.components.burnable:AddBurnFX("tikitorchflame", Vector3(-7, 45, 0), "fire_marker")

    inst:AddComponent("fueled")
    inst.components.fueled.accepting = false
    inst.components.fueled:SetSections(4)
    inst.components.fueled.maxfuel = 8

    inst.components.fueled:SetUpdateFn( function()
    inst.components.fueled.rate = 0
    if inst.components.burnable and inst.components.fueled then
    inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
    end
end)
    
    inst.components.fueled:SetSectionCallback( function(section)
    if section == 0 then
    --inst.components.burnable:Extinguish()
    else
    if not inst.components.burnable:IsBurning() then inst.components.burnable:Ignite()
end
    inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
    end
end)

    inst.components.fueled:InitializeFuelLevel(2)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY
       
    inst:AddTag("structure")
    inst:AddComponent("lootdropper")

    inst:AddComponent("cooker")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
	
    inst:DoPeriodicTask(1, function(inst)
    if not inst.components.burnable:IsBurning() 
    then inst.components.burnable:Ignite()
end
    if TheWorld.state.isday or TheWorld.state.isdusk 
    then inst.components.fueled:InitializeFuelLevel(1)
    else    
    inst.components.fueled:InitializeFuelLevel(2)
    end
end)

    return inst
end

return Prefab( "common/alwaysontikitorch", fn, assets, prefabs),
    MakePlacer("common/alwaysontikitorch_placer", "pigtorch", "alwaysontikitorch", "idle")