--Klei2lazy4replication
local Beaverness = Class(function(self, inst)
    self.inst = inst

    if TheWorld.ismastersim then
        self.classified = inst.player_classified
    elseif self.classified == nil and inst.player_classified ~= nil then
        self:AttachClassified(inst.player_classified)
    end
end)

--------------------------------------------------------------------------

function Beaverness:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

Beaverness.OnRemoveEntity = Beaverness.OnRemoveFromEntity

function Beaverness:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Beaverness:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

--------------------------------------------------------------------------

function Beaverness:SetCurrent(current)
    if self.classified ~= nil then
        self.classified:SetValue("currentbeaverness", current)
    end
end

function Beaverness:SetMax(max)
    if self.classified ~= nil then
        self.classified:SetValue("maxbeaverness", max)
    end
end

function Beaverness:SetIsBeaver(isbeaver)
    if self.classified ~= nil then
        self.classified.isbeaver:set(isbeaver)
    end
end

function Beaverness:SetIsInCooldown(isincooldown)
    if self.classified ~= nil then
        self.classified.isincooldown:set(isincooldown)
    end
end

function Beaverness:Max()
    if self.inst.components.modded_beaverness ~= nil then
        return self.inst.components.modded_beaverness.max
    elseif self.classified ~= nil then
        return self.classified.maxbeaverness:value()
    else
        return 100
    end
end

function Beaverness:GetPercent()
    if self.inst.components.modded_beaverness ~= nil then
        return self.inst.components.modded_beaverness:GetPercent()
    elseif self.classified ~= nil then
        return self.classified.currentbeaverness:value() / self.classified.maxbeaverness:value()
    else
        return 0
    end
end

function Beaverness:IsBeaver()
    if self.inst.components.modded_beaverness ~= nil then
        return self.inst.components.modded_beaverness:IsBeaver()
    else
        return self.classified ~= nil and self.classified.isbeaver:value()
    end
end

function Beaverness:IsInCooldown()
    if self.inst.components.modded_beaverness ~= nil then
        return self.inst.components.modded_beaverness:IsInCooldown()
    else
        return self.classified ~= nil and self.classified.isincooldown:value()
    end
end

return Beaverness