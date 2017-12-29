local function onmax(self, max)
    self.inst.replica.modded_beaverness:SetMax(max)
end

local function oncurrent(self, current)
    self.inst.replica.modded_beaverness:SetCurrent(current)
end

local function onisbeaver(self, isbeaver)
    self.inst.replica.modded_beaverness:SetIsBeaver(isbeaver)
end

local function oncooldown(self)
    self.inst.replica.modded_beaverness:SetIsInCooldown(self:IsInCooldown())
end

local Beaverness = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = 0
    self.cooldown = 0
    self.is_beaver = false
    self.should_pair = false
    self.hurtrate = 0
    self.inst:StartUpdatingComponent(self)
end,
nil,
{
    max = onmax,
    current = oncurrent,
    is_beaver = onisbeaver,
    cooldown = oncooldown,
})


function Beaverness:IsBeaver()
    return self.is_beaver
end

function Beaverness:IsInCooldown()
    return self.cooldown > 0
end

function Beaverness:OnSave()    
    return 
    {
        current = self.current,
        cooldown = self.cooldown,
        is_beaver = self.is_beaver
    }
end

function Beaverness:StopTimeEffect()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function Beaverness:StartTimeEffect(dt, delta_b)
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
    self.task = self.inst:DoPeriodicTask(dt, function() 
        self:DoDelta(delta_b, true)
    end)
end

function Beaverness:OnLoad(data)
    if data then
        if data.current then
            self.current = data.current
        end

        if data.is_beaver then
            self.is_beaver = data.is_beaver
        end

        if data.cooldown then
            self.cooldown = data.cooldown
        end
    end

end

function Beaverness:DoDelta(delta, overtime)

    if (self.should_pair or self.cooldown > 0) and delta > 0 then
        self.inst:PushEvent("beavernessdelta_paired")
        return
    end

    local old = self.current
    self.current = math.clamp(self.current+delta, 0, self.max)

    self.inst:PushEvent("beavernessdelta", {oldpercent = old/self.max, newpercent = self.current/self.max, overtime = overtime})

        if self.is_beaver and self.current <= 0 then
            --self.is_beaver = false
            if not self.inst.sg:HasStateTag("transform") then
                self.inst:PushEvent("transform_person")
                self.cooldown = TUNING.BEAVERNESS_COOLDOWN
            end
        elseif not self.is_beaver and self.current >= self.max then
            --self.is_beaver = true
            if not self.inst.sg:HasStateTag("transform") then
                self.inst:PushEvent("transform_werebeaver")
            end
        end
    
end

function Beaverness:GetPercent()
    return self.current / self.max
end

function Beaverness:GetDebugString()
    return string.format("%2.2f / %2.2f", self.current, self.max)
end

function Beaverness:SetPercent(percent)
    self.current = self.max*percent
    self:DoDelta(0)
end

function Beaverness:OnUpdate(dt)
    self.cooldown = self.cooldown - dt
    if self.cooldown < 0 then self.cooldown = 0 end
    if self.cooldown == 0 and TheWorld.state.isfullmoon and not self.is_beaver then
        self:SetPercent(1)
    end
end

return Beaverness