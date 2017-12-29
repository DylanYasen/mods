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
    Asset("IMAGE", "images/colour_cubes/beaver_vision_cc.tex"),

    Asset("ANIM", "anim/ghost_woodie_build.zip"),
}

local BEAVERVISION_COLOURCUBES =
{
    day = "images/colour_cubes/beaver_vision_cc.tex",
    dusk = "images/colour_cubes/beaver_vision_cc.tex",
    night = "images/colour_cubes/beaver_vision_cc.tex",
    full_moon = "images/colour_cubes/beaver_vision_cc.tex",
}

--------------------------------------------------------------------------

local BEAVER_DIET =
{
    FOODTYPE.WOOD,
}

local BEAVER_LMB_ACTIONS =
{
    "CHOP",
    "MINE",
    "DIG",
}

local BEAVER_RMB_ACTIONS =
{
    "HAMMER",
}

local BEAVER_ACTION_TAGS = {}

for i, v in ipairs(BEAVER_LMB_ACTIONS) do
    table.insert(BEAVER_ACTION_TAGS, v.."_workable")
end

for i, v in ipairs(BEAVER_DIET) do
    table.insert(BEAVER_ACTION_TAGS, "edible_"..v)
end

local BEAVER_TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "catchable" }

local function CannotExamine(inst)
    return false
end

local function BeaverActionString(inst, action)
    return (action.action == ACTIONS.EAT and STRINGS.ACTIONS.EAT)
        or STRINGS.ACTIONS.GNAW
end

local function GetBeaverAction(target)
    for i, v in ipairs(BEAVER_LMB_ACTIONS) do
        if target:HasTag(v.."_workable") then
            return ACTIONS[v]
        end
    end
    for i, v in ipairs(BEAVER_DIET) do
        if target:HasTag("edible_"..v) then
            return ACTIONS["EAT"]
        end
    end
end

local function BeaverActionButton(inst, force_target)
    if not inst.components.playercontroller:IsDoingOrWorking() then
        if force_target == nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, inst.components.playercontroller.directwalking and 3 or 6, nil, BEAVER_TARGET_EXCLUDE_TAGS, BEAVER_ACTION_TAGS)
            for i, v in ipairs(ents) do
                if v ~= inst and v.entity:IsVisible() and CanEntitySeeTarget(inst, v) then
                    local action = GetBeaverAction(v)
                    if action ~= nil then
                        return BufferedAction(inst, v, action)
                    end
                end
            end
        elseif inst:GetDistanceSqToInst(force_target) <= (inst.components.playercontroller.directwalking and 9 or 36) then
            local action = GetBeaverAction(force_target)
            if action ~= nil then
                return BufferedAction(inst, force_target, action)
            end
        end
    end
end

local function LeftClickPicker(inst, target)
    if target ~= nil and target ~= inst then
        if inst.replica.combat:CanTarget(target) then
            return (not target:HasTag("player") or inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK))
                and inst.components.playeractionpicker:SortActionList({ ACTIONS.ATTACK }, target, nil)
                or nil
        end
        for i, v in ipairs(BEAVER_LMB_ACTIONS) do
            if target:HasTag(v.."_workable") then
                return inst.components.playeractionpicker:SortActionList({ ACTIONS[v] }, target, nil)
            end
        end
        for i, v in ipairs(BEAVER_DIET) do
            if target:HasTag("edible_"..v) then
                return inst.components.playeractionpicker:SortActionList({ ACTIONS.EAT }, target, nil)
            end
        end
        for i, v in ipairs(BEAVER_RMB_ACTIONS) do
            if target:HasTag(v.."_workable") then
                return inst.components.playeractionpicker:SortActionList({ ACTIONS[v] }, target, nil)
            end
        end
    end
end

local function RightClickPicker(inst, target)
    return {}
end

local function SetBeaverActions(inst, enable)
    if enable then
        inst.ActionStringOverride = BeaverActionString
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = BeaverActionButton
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
            inst.components.playeractionpicker.rightclickoverride = RightClickPicker
        end
    else
        inst.ActionStringOverride = nil
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = nil
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = nil
            inst.components.playeractionpicker.rightclickoverride = nil
        end
    end
end

local function SetBeaverVision(inst, enable)
    if enable then
        inst.components.playervision:ForceNightVision(true)
        inst.components.playervision:SetCustomCCTable(BEAVERVISION_COLOURCUBES)
    else
        inst.components.playervision:ForceNightVision(false)
        inst.components.playervision:SetCustomCCTable(nil)
    end
end

local function SetBeaverMode(inst, isbeaver)
    if isbeaver then
        TheWorld:PushEvent("enabledynamicmusic", false)
        if not TheFocalPoint.SoundEmitter:PlayingSound("beavermusic") then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/music/music_hoedown", "beavermusic")
        end

        inst.HUD.controls.status:SetBeaverMode(true)
        if inst.HUD.beaverOL ~= nil then
            inst.HUD.beaverOL:Show()
        end

        if not TheWorld.ismastersim then
            inst.CanExamine = CannotExamine
            SetBeaverActions(inst, true)
            SetBeaverVision(inst, true)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.1
            end
        end

        inst.ActionStringOverride = function() return STRINGS.ACTIONS.GNAW end
    else
        TheWorld:PushEvent("enabledynamicmusic", true)
        TheFocalPoint.SoundEmitter:KillSound("beavermusic")

        inst.HUD.controls.status:SetBeaverMode(false)
        if inst.HUD.beaverOL ~= nil then
            inst.HUD.beaverOL:Hide()
        end

        if not TheWorld.ismastersim then
            inst.CanExamine = inst.replica.modded_beaverness:IsBeaver() and CannotExamine or nil
            SetBeaverActions(inst, false)
            SetBeaverVision(inst, false)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
            end
        end

        inst.ActionStringOverride = nil
    end
end

local function SetGhostMode(inst, isghost)
    if isghost then
        SetBeaverMode(inst, false)
        inst._SetGhostMode(inst, true)
    else
        inst._SetGhostMode(inst, false)
        SetBeaverMode(inst, inst.replica.modded_beaverness:IsBeaver())
    end
end

local function OnBeaverModeDirty(inst)
    if inst.HUD ~= nil and not inst:HasTag("playerghost") then
        SetBeaverMode(inst, inst.replica.modded_beaverness:IsBeaver())
    end
end

local function OnPlayerDeactivated(inst)
    inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
    if not TheWorld.ismastersim then
        inst:RemoveEventCallback("isbeavermodedirty", OnBeaverModeDirty)
    end
    TheFocalPoint.SoundEmitter:KillSound("beavermusic")
end

local function OnPlayerActivated(inst)
    if inst.HUD.beaverOL == nil then
        inst.HUD.beaverOL = inst.HUD.overlayroot:AddChild(Image("images/woodie.xml", "beaver_vision_OL.tex"))
        inst.HUD.beaverOL:SetVRegPoint(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetHRegPoint(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetVAnchor(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetHAnchor(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetScaleMode(SCALEMODE_FILLSCREEN)
        inst.HUD.beaverOL:SetClickable(false)
    end
    inst:ListenForEvent("onremove", OnPlayerDeactivated)
    if not TheWorld.ismastersim then
        inst:ListenForEvent("isbeavermodedirty", OnBeaverModeDirty)
    end
    OnBeaverModeDirty(inst)
end

local function IsLucy(item)
    return item.prefab == "lucy"
end

local function onworked(inst, data)
    if data.target ~= nil and data.target.components.workable ~= nil then
        if data.target.components.workable.action == ACTIONS.CHOP and (not inst.components.modded_beaverness:IsBeaver()) then
            inst.components.modded_beaverness:DoDelta(3)

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
end

local function onredirect(inst, delta)
    if delta < 0 then
        inst.sg:PushEvent("attacked")
        inst.components.modded_beaverness:DoDelta(delta*(1-inst.components.health.absorb))
    end
end

local function onbeavernesschange(inst)
    if inst.sg:HasStateTag("nomorph") or
        inst.sg:HasStateTag("silentmorph") or
        inst:HasTag("playerghost") or
        inst.components.health:IsDead() or
        not inst.entity:IsVisible() then
        return
    end

    if inst.components.modded_beaverness:IsBeaver() then
        if inst.components.modded_beaverness:GetPercent() <= 0 then
        end
    elseif inst.components.modded_beaverness:GetPercent() >= 1 then
    end
end

local function onnewstate(inst)
    if inst._wasnomorph ~= (inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")) then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            onbeavernesschange(inst)
        end
    end
end

--------------------------------------------------------------------------

local function SetBeaverWorker(inst, enable)
    if enable then
        if inst.components.worker == nil then
            inst:AddComponent("worker")
            inst.components.worker:SetAction(ACTIONS.CHOP, 4)
            inst.components.worker:SetAction(ACTIONS.MINE, 1)
            inst.components.worker:SetAction(ACTIONS.DIG, 1)
            inst.components.worker:SetAction(ACTIONS.HAMMER, 1)
        end
    elseif inst.components.worker ~= nil then
        inst:RemoveComponent("worker")
    end
end

local function SetBeaverSounds(inst, enable)
    if enable then
        inst.hurtsoundoverride = "dontstarve/characters/woodie/hurt_beaver"
    else
        inst.hurtsoundoverride = nil
    end
end

--------------------------------------------------------------------------

local function onbecamehuman(inst)
    if inst.prefab ~= nil and inst.sg.currentstate.name ~= "reviver_rebirth" then
        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild(inst.skin_name or inst.prefab)
    end

    inst.components.modded_beaverness:StartTimeEffect(2, -1)

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.health:SetAbsorptionAmount(0)
    inst.components.health.redirect = nil
    inst.components.sanity.ignore = false
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.pinnable.canbepinned = true
    inst.components.hunger:Resume()
    inst.components.moisture:SetInherentWaterproofness(0)
    inst.components.temperature:SetTemp(nil)
    inst.components.talker:StopIgnoringAll("becamebeaver")
    inst.components.catcher:SetEnabled(true)

    inst.CanExamine = nil

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(true)
    end

    SetBeaverWorker(inst, false)
    SetBeaverActions(inst, false)
    SetBeaverSounds(inst, false)
    SetBeaverVision(inst, false)

    if inst:HasTag("beaver") then
        inst:RemoveTag("beaver")
        inst.Network:RemoveUserFlag(USERFLAGS.CHARACTER_STATE_1)
        inst.components.modded_beaverness.is_beaver = false
        inst:PushEvent("stopbeaver")
        OnBeaverModeDirty(inst)
    end
end

local function onbecamebeaver(inst)
    if inst.sg.currentstate.name ~= "reviver_rebirth" then
        inst.AnimState:SetBank("werebeaver")
        inst.AnimState:SetBuild("werebeaver_build")
    end

    inst.hurtsoundoverride = "dontstarve/characters/woodie/hurt_beaver"

    local dt = 3
    local BEAVER_DRAIN_TIME = 120
    inst.components.modded_beaverness:StartTimeEffect(dt, (-100/BEAVER_DRAIN_TIME)*dt)
    inst.components.health:SetPercent(1)
    inst.components.sanity:SetPercent(1)
    inst.components.hunger:SetPercent(1)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.1
    inst.components.combat:SetDefaultDamage(TUNING.SPIKE_DAMAGE)
    inst.components.health:SetAbsorptionAmount(TUNING.ARMORWOOD_ABSORPTION)
    inst.components.health.redirect = onredirect
    inst.components.sanity.ignore = true
    inst.components.eater:SetDiet(BEAVER_DIET, BEAVER_DIET)
    inst.components.pinnable.canbepinned = false
    inst.components.hunger:Pause()
    inst.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
    inst.components.temperature:SetTemp(20)
    inst.components.talker:IgnoreAll("becamebeaver")
    inst.components.catcher:SetEnabled(false)

    inst.CanExamine = CannotExamine

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(false)
    end

    SetBeaverWorker(inst, true)
    SetBeaverActions(inst, true)
    SetBeaverSounds(inst, true)
    SetBeaverVision(inst, true)

    if not inst:HasTag("beaver") then
        inst:AddTag("beaver")
        inst.Network:AddUserFlag(USERFLAGS.CHARACTER_STATE_1)
        inst.components.modded_beaverness.is_beaver = true
        inst:PushEvent("startbeaver")
        OnBeaverModeDirty(inst)
    end
end

local function onrespawnedfromghost(inst)
    inst.components.modded_beaverness:StartTimeEffect(2, -1)

    if inst._wasnomorph == nil then
        inst._wasnomorph = inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")
        inst:ListenForEvent("working", onworked)
        inst:ListenForEvent("beavernessdelta", onbeavernesschange)
        inst:ListenForEvent("newstate", onnewstate)
    end

    if inst.components.modded_beaverness:IsBeaver() then
        inst.components.inventory:Close()
        onbecamebeaver(inst)
    else
        onbecamehuman(inst)
    end

    inst:DoTaskInTime(0, function() inst.components.modded_beaverness:DoDelta(0) end)
end

local function onbecameghost(inst)

    inst.components.modded_beaverness:StopTimeEffect()

    if inst._wasnomorph ~= nil then
        inst._wasnomorph = nil
        inst:RemoveEventCallback("working", onworked)
        inst:RemoveEventCallback("beavernessdelta", onbeavernesschange)
        inst:RemoveEventCallback("newstate", onnewstate)
    end

    SetBeaverWorker(inst, false)
    SetBeaverActions(inst, false)
    SetBeaverSounds(inst, false)
    SetBeaverVision(inst, false)
end

local function TransformBeaver(inst, isbeaver)
    if isbeaver then
        onbecamebeaver(inst)
    else
        onbecamehuman(inst)
    end
end

local function onentityreplicated(inst)
    if inst.sg ~= nil and inst:HasTag("beaver") then
        inst.sg:GoToState("idle")
    end
end

local function onpreload(inst, data)
    if data ~= nil and data.isbeaver_classic then
        onbecamebeaver(inst)
        inst.sg:GoToState("idle")
    end
end

local function onload(inst)
    if inst.components.modded_beaverness:IsBeaver() and not inst:HasTag("playerghost") then
        inst.components.inventory:Close()
    end
end

local function onsetskin(inst)
    if inst.components.modded_beaverness:IsBeaver() and not inst:HasTag("playerghost") then
        inst.AnimState:SetBuild("werebeaver_build")
    end
end

local function onsave(inst, data)
    data.isbeaver_classic = inst.components.modded_beaverness:IsBeaver() or nil
end

local function GetBeaverness(inst)
    if inst.components.modded_beaverness ~= nil then
        return inst.components.modded_beaverness:GetPercent()
    elseif inst.replica.modded_beaverness ~= nil then
        return inst.replica.modded_beaverness:GetPercent()
    else return 0 end
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    inst:AddTag("woodcutter")
    inst:AddTag("polite")
    inst:AddTag("ghostwithhat")

    inst:AddTag("modded_beaverness")

    inst.GetBeaverness = GetBeaverness
    inst.beaverbadge_ignore_full_moon = true

    inst:ListenForEvent("playeractivated", OnPlayerActivated)
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)

    if inst.ghostenabled then
        inst._SetGhostMode = inst.SetGhostMode
        inst.SetGhostMode = SetGhostMode
    end

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = onentityreplicated
    end
end

local function master_postinit(inst)

    inst:AddComponent("modded_beaverness")

    inst._wasnomorph = nil
    inst.TransformBeaver = TransformBeaver

    inst:ListenForEvent("ms_respawnedfromghost", onrespawnedfromghost)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    onrespawnedfromghost(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnPreLoad = onpreload
    inst.OnSetSkin = onsetskin

end

return MakePlayerCharacter("woodie", prefabs, assets, common_postinit, master_postinit, starting_inv)
