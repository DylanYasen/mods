local MakePlayerCharacter = require("prefabs/player_common")
local easing = require("easing")

local prefabs =
{
    "shovel_dirt",
    "werebeaver_transform_fx",
}

local starting_inv =
{
    "lucy",
}

local assets =
{
    Asset("ANIM", "anim/woodie.zip"),
    Asset("SOUND", "sound/woodie.fsb"),

    Asset("ANIM", "anim/werebeaver_build.zip"),
    Asset("ANIM", "anim/werebeaver_basic.zip"),
    Asset("ANIM", "anim/werebeaver_groggy.zip"),
    Asset("ANIM", "anim/player_woodie.zip"),
    Asset("ATLAS", "images/woodie.xml"),
    Asset("IMAGE", "images/woodie.tex"),

    Asset("ANIM", "anim/ghost_woodie_build.zip"),
}

local function CanShaveTest(inst)
    return false, "REFUSE"
end

local function OnResetBeard(inst)
    inst.components.beard.bits = 3
end

local function sanityfn(inst)
    if inst.sg:HasStateTag("chopping") then
        return TUNING.BEAVER_SANITY_PENALTY
    end
    return 0
end

local function IsLucy(item)
    return item.prefab == "lucy"
end

local function onworked(inst, data)
    if data.target ~= nil and data.target.components.workable ~= nil then
        local equipitem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equipitem ~= nil and (equipitem.prefab == "axe" or equipitem.prefab == "goldenaxe") then
            local itemuses = equipitem.components.finiteuses ~= nil and equipitem.components.finiteuses:GetUses() or nil
            if itemuses == nil or itemuses > 0 then
                --Don't make Lucy if we already have one
                if inst.components.inventory:FindItem(IsLucy) == nil then
                    local lucy = SpawnPrefab("lucy")
                    lucy.components.possessedaxe.revert_prefab = equipitem.prefab
                    lucy.components.possessedaxe.revert_uses = itemuses
                    equipitem:Remove()
                    inst.components.inventory:Equip(lucy)
                    if lucy.components.possessedaxe.transform_fx ~= nil then
                        local fx = SpawnPrefab(lucy.components.possessedaxe.transform_fx)
                        if fx ~= nil then
                            fx.entity:AddFollower()
                            fx.Follower:FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
                        end
                    end
                end
            end
        end
    end
end

local function ondeployitem(inst, data)
    if data.prefab == "pinecone" or data.prefab == "acorn" then
        --inst.components.sanity:DoDelta(TUNING.SANITY_TINY)
        inst.components.sanity:DoDelta(TUNING.SANITY_PER_CONE_WOODIE)
    end
end


local function onrespawnedfromghost(inst)
    inst:ListenForEvent("working", onworked)
    inst:ListenForEvent("deployitem", ondeployitem)
end

local function common_postinit(inst)
    inst:AddTag("woodcutter")
    inst:AddTag("polite")
    inst:AddTag("ghostwithhat")

    --bearded (from beard component) added to pristine state for optimization
    inst:AddTag("bearded")
end

local function master_postinit(inst)
    -- Give Woodie a beard so he gets some insulation from winter cold
    -- (Value is Wilson's level 2 beard.)
    inst:AddComponent("beard")
    inst.components.beard.canshavetest = CanShaveTest
    inst.components.beard.onreset = OnResetBeard
    inst.components.beard:EnableGrowth(false)
    OnResetBeard(inst)

    inst.components.sanity.custom_rate_fn = sanityfn

    inst:ListenForEvent("ms_respawnedfromghost", onrespawnedfromghost)
    onrespawnedfromghost(inst)
end

return MakePlayerCharacter("woodie", prefabs, assets, common_postinit, master_postinit, starting_inv)