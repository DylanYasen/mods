print("[TBAU] loading 'woodie_classic' overrides...")
local net_bool = GLOBAL.net_bool
local net_ushortint = GLOBAL.net_ushortint

local function SetDirty(netvar, val)
    netvar:set_local(val)
    netvar:set(val)
end

local function OnBeavernessDirty(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent ~= nil then
        local percent = inst.currentbeaverness:value() / inst.maxbeaverness:value()
        inst._parent:PushEvent("beavernessdelta", { oldpercent = inst._oldbeavernesspercent, newpercent = percent, overtime = not inst.isbeavernesspulse:value() })
        inst._oldbeavernesspercent = percent
    else
        inst._oldbeavernesspercent = 0
    end
    inst.isbeavernesspulse:set_local(false)
end

local function OnIsBeaverModeDirty(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent ~= nil then
        inst._parent:PushEvent("isbeavermodedirty")
    end
end

local function RegisterNetListeners(inst)
    inst._parent = inst.entity:GetParent()
    if not GLOBAL.TheWorld.ismastersim then
        inst.isbeavernesspulse:set_local(false)
        inst:ListenForEvent("beavernessdirty", OnBeavernessDirty)
        inst:ListenForEvent("isbeavermodedirty", OnIsBeaverModeDirty)
    end
end

local function postfn(inst)

    inst._parent = inst.entity:GetParent()
	if not GLOBAL.TheWorld.ismastersim and inst._parent then
		inst.event_listening["beavernessdirty"] = nil --It's a REALLY ugly way to do this, but I don't want to override the entire player_classified
		inst._parent.event_listeners["beavernessdirty"] = nil
	end

	inst.isbeaver = net_bool(inst.GUID, "beaverness.isbeaver", "isbeavermodedirty")
	inst.maxbeaverness = net_ushortint(inst.GUID, "beaverness.max", "beavernessdirty")
    inst.isincooldown = net_bool(inst.GUID, "beaverness.isincooldown", "cooldowndirty")

	inst:DoTaskInTime(0, RegisterNetListeners)

    local OldOnReplicated = inst.OnEntityReplicated
    inst.OnEntityReplicated = function(inst)  
        OldOnReplicated(inst)

        inst._parent = inst.entity:GetParent()
        if inst._parent == nil then
            print("Unable to initialize classified data for player")
        else
            inst._parent:AttachClassified(inst)
            for i, v in ipairs({ "modded_beaverness" }) do
                if inst._parent.replica[v] ~= nil then
                    inst._parent.replica[v]:AttachClassified(inst)
                end
            end
        end

    end
end

AddPrefabPostInit("player_classified", postfn)

AddReplicableComponent("modded_beaverness")

--Drop everything on transformation, still TODO, to be moved to modmain and made configurable
AddStategraphEvent("wilson", GLOBAL.EventHandler("transform_werebeaver",
        function(inst, data)
            if inst.TransformBeaver ~= nil and not inst:HasTag("beaver") then
                --inst.components.inventory:DropEquipped(true)
                inst.components.inventory:DropEverything()
                inst.components.inventory:Close()
                inst:PushEvent("ms_closepopups")
                inst.sg:GoToState("transform_werebeaver")
            end
        end))


AddStategraphState("wilson", GLOBAL.State{
        name = "transform_person",
        tags = { "busy", "pausepredict", "transform", "nomorph" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("death", false)
            inst.components.health:SetInvincible(true)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
            end

            inst.sg:SetTimeout(3)
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/death_beaver")
        end,

        ontimeout = function(inst)

            inst:ScreenFade(false, 2)
            inst:DoTaskInTime(2, function() 
                if inst.TransformBeaver ~= nil and inst:HasTag("beaver") then
                    inst.components.health:SetInvincible(false)
                    inst.components.inventory:Open()
                    if inst.components.playercontroller ~= nil then
                        inst.components.playercontroller:Enable(true)
                    end
                    inst:TransformBeaver(false)
                    --SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    GLOBAL.SpawnPrefab("werebeaver_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    --if not TheWorld.state.isday then
                    --SpawnPrefab("spawnlight_multiplayer").Transform:SetPosition(inst.Transform:GetWorldPosition()) --TODO Hook it up somehow
                    --end
                    inst.components.sanity:SetPercent(.25)
                    inst.components.health:SetPercent(.33)
                    inst.components.hunger:SetPercent(.25)
                    inst.sg:GoToState("wakeup")
                else
                    inst.sg:GoToState("idle")
                end
                inst:ScreenFade(true, 1)
            end)
        end,
    })

--Eater component - updating 'beaverness' references to 'modded_beaverness'
AddComponentPostInit("eater", function(self)
    local oldEat = self.Eat
    function self:Eat(food)
        local shouldEatOld = false
        local shouldEatWood = false
        if self:PrefersToEat(food) then
            if self.inst.components.modded_beaverness ~= nil and food.components.edible.woodiness ~= nil then
                self.inst.components.modded_beaverness:DoDelta(food.components.edible:GetWoodiness(self.inst))
            end
            shouldEatWood = true
            shouldEatOld = oldEat(self, food)
        end
        return shouldEatWood or shouldEatOld
    end
end)

--Status displays - updating 'beaverness' references to 'modded_beaverness'
local BeaverBadge = GLOBAL.require "widgets/beaverbadge"
AddClassPostConstruct("widgets/statusdisplays", function(self)

    function self:SetBeaverMode(beavermode)
        if self.isghostmode or self.beaverness == nil then
            return
        elseif beavermode then
            self.brain:Hide()
            self.heart:Hide()
            self.stomach:Hide()
            --self.beaverness:SetPosition(-40, 20, 0)
            self.beaverness:SetPosition(0, -20, 0)
        else
            self.brain:Show()
            self.heart:Show()
            self.stomach:Show()
            self.beaverness:SetPosition(-80, -40, 0)
        end
    end

    function self:BeavernessCooldownDirty()
        if self.owner.replica.modded_beaverness and self.owner.replica.modded_beaverness:IsInCooldown() then
            self.beaverness:StartWarning(0.5, 0, 1, 1)
        else
            self.beaverness:StopWarning()
        end
    end

    if self.owner:HasTag("modded_beaverness") then
        self:AddBeaverness()

        if (not self.isghostmode) and (self.onbeavernessdelta == nil) then
            self.onbeavernessdelta = function(owner, data) self:BeavernessDelta(data) end
            self.oncooldowndirty = function() self:BeavernessCooldownDirty() end
            self.inst:ListenForEvent("beavernessdelta", self.onbeavernessdelta, self.owner)
            self.inst:ListenForEvent("cooldowndirty", self.oncooldowndirty, self.owner.player_classified)
            self:SetBeavernessPercent(self.owner:GetBeaverness())
            self:BeavernessCooldownDirty()
        end
    end
end)

AddPrefabPostInit("pinecone", function(inst)
    inst:AddComponent("edible")
    inst.components.edible.foodtype = GLOBAL.FOODTYPE.WOOD
    inst.components.edible.woodiness = 2
end)

function GLOBAL.c_setbeaverness(n)
    local player = GLOBAL.ConsoleCommandPlayer()
    if player and player.components.modded_beaverness then player.components.modded_beaverness:SetPercent(n) end
end