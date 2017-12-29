require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/w_pond.zip"),
    Asset("ANIM", "anim/bee_box.zip"),
}

local prefabs =
{
	"fish",
} 

local levels = 
{
    { amount=3, idle="honey3", hit="hit_honey3" },
    { amount=2, idle="honey2", hit="hit_honey2" },
    { amount=1, idle="honey1", hit="hit_honey1" },
    { amount=0, idle="bees_loop", hit="hit_idle" },
}

local function OnIsDay(inst, isday)
    if not isday then
        if inst.components.harvestable and inst.components.harvestable.growtime then
            inst.components.harvestable:StopGrowing()
        end
        if inst.components.childspawner then
            inst.components.childspawner:StopSpawning()
        end
    elseif not TheWorld.state.iswinter then
        if inst.components.harvestable and inst.components.harvestable.growtime then
            inst.components.harvestable:StartGrowing()
        end
        if inst.components.childspawner then
            inst.components.childspawner:StartSpawning()
        end
    end
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("bees_loop")
	inst.AnimState:PushAnimation("bees_loop", false)
end

local function setlevel(inst, level)
    if not inst.anims then
        inst.anims = {idle = level.idle, hit = level.hit}
    else
        inst.anims.idle = level.idle
        inst.anims.hit = level.hit
    end
    inst.AnimState:PlayAnimation(inst.anims.idle)
end

local function updatelevel(inst)
    for k,v in pairs(levels) do
        if inst.components.harvestable.produce >= v.amount then
            setlevel(inst, v)
            break
        end
    end
end

local function onharvest(inst, picker)
	--print(inst, "onharvest")
    updatelevel(inst)
	if inst.components.childspawner and not TheWorld.state.iswinter then
	    inst.components.childspawner:ReleaseAllChildren(picker)
	end
end

local function onchildgoinghome(inst, data)
    if data.child and data.child.components.pollinator and data.child.components.pollinator:HasCollectedEnough() then
        if inst.components.harvestable then
            inst.components.harvestable:Grow()
        end
    end
end

local function onsleep(inst)
    if inst.components.harvestable then
        inst.components.harvestable:SetGrowTime(TUNING.BEEBOX_HONEY_TIME)
        inst.components.harvestable:StartGrowing()
    end
end

local function stopsleep(inst)
    if inst.components.harvestable then
        inst.components.harvestable:SetGrowTime(nil)
        inst.components.harvestable:StopGrowing()
    end
end

local function OnLoad(inst, data)
	--print(inst, "OnLoad")
	updatelevel(inst)
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("bees_loop")
	inst.AnimState:PushAnimation("bees_loop", false)
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/bee/bee_box_LP", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function GetStatus(inst)
    if inst.components.harvestable and inst.components.harvestable:CanBeHarvested() then
    return "READY"
    end
end

local function SeasonalSpawnChanges(inst, season)
    if inst.components.childspawner then
        if season == SEASONS.SPRING then
            inst.components.childspawner:SetRegenPeriod(TUNING.BEEBOX_REGEN_TIME / TUNING.SPRING_COMBAT_MOD)
            inst.components.childspawner:SetSpawnPeriod(TUNING.BEEBOX_RELEASE_TIME / TUNING.SPRING_COMBAT_MOD)
            inst.components.childspawner:SetMaxChildren(TUNING.BEEBOX_BEES * TUNING.SPRING_COMBAT_MOD)
        else
            inst.components.childspawner:SetRegenPeriod(TUNING.BEEBOX_REGEN_TIME)
            inst.components.childspawner:SetSpawnPeriod(TUNING.BEEBOX_RELEASE_TIME)
            inst.components.childspawner:SetMaxChildren(TUNING.BEEBOX_BEES)
        end
    end
end
local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .7)

    inst.MiniMapEntity:SetIcon("w_pond.tex")

    inst.AnimState:SetBank("w_pond")
    inst.AnimState:SetBuild("w_pond")
    inst.AnimState:PlayAnimation("bees_loop")

    inst:AddTag("structure")
    inst:AddTag("playerowned")

    MakeSnowCoveredPristine(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("harvestable")
    inst.components.harvestable:SetUp("fish", 3, nil, onharvest, updatelevel)
    inst:ListenForEvent("childgoinghome", onchildgoinghome)   
    
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "bee"
	inst.components.childspawner:SetRegenPeriod(TUNING.BEEBOX_REGEN_TIME)
	inst.components.childspawner:SetSpawnPeriod(TUNING.BEEBOX_RELEASE_TIME)
	inst.components.childspawner:SetMaxChildren(TUNING.BEEBOX_BEES)  
    
	if TheWorld.state.isday and TheWorld.state.issummer then
		inst.components.childspawner:StartSpawning()
	end

    inst:WatchWorldState("isday", OnIsDay)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:ListenForEvent("entitysleep", onsleep)
	inst:ListenForEvent("entitywake", stopsleep)
	
    updatelevel(inst)

    MakeHauntableWork(inst)
    
	MakeSnowCovered(inst)
	inst:ListenForEvent("onbuilt", onbuilt)

	inst.OnLoad = OnLoad
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	return inst
end

return Prefab("common/w_pond", fn, assets, prefabs),	
	   MakePlacer( "common/w_pond_placer", "w_pond", "w_pond", "bees_loop" ) 
