local assets =
{
	Asset("ANIM", "anim/campfire_fire.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local heats = { 80, 120, 120 }
local function GetHeatFn(inst)
	return heats[inst.components.firefx.level] or 20
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("campfire_fire")
    inst.AnimState:SetBuild("campfire_fire")
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("fx")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()    

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn
    
    inst:AddComponent("firefx")
    inst.components.firefx.levels =
{
    {anim="level1", sound="dontstarve/common/campfire", radius=3, intensity=.75, falloff=.5, colour = {255/255,255/255,192/255}, soundintensity=.05},
    {anim="level2", sound="dontstarve/common/campfire", radius=5, intensity=.75, falloff=.5, colour = {255/255,255/255,192/255}, soundintensity=.6},
    {anim="level3", sound="dontstarve/common/campfire", radius=7, intensity=.75, falloff=.5, colour = {255/255,255/255,192/255}, soundintensity=1},
}

    inst.AnimState:SetFinalOffset(-1)
    inst.components.firefx:SetLevel(0)
    inst.components.firefx.usedayparamforsound = true
    return inst
end

return Prefab( "common/fx/tikitorchflame", fn, assets) 
