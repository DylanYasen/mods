local strings = STRINGS


local ItemValues = Class(function(self, inst)
	self.inst = inst
	self.string = ""
	self.item = nil
	self.itemupdate= net_event(self.inst.GUID, "item_value_updated")
	self.string_dirty = net_string(self.inst.GUID, "item_string", "item_string_changed_dirty")
end,
nil,
{
})
	



function ItemValues:On_ItemValue_Changed(player, item, keydown, DFV_FUELEDSET, show_damage, show_uses, show_temp, show_insul, show_acond, show_adef, show_atype)
	if item ~= nil then --abort function if item does not exists seemed to be caused by controller ui
	self.string = ""	
	if item.components.weapon ~= nil and (show_damage or keydown) then
				self.string = self.string .. "\n" .. "Damage " .. item.components.weapon.damage
			end
			if item.components.finiteuses ~= nil and (show_uses or keydown) then
				self.string = self.string .. "\n" .. "Uses left " .. item.components.finiteuses:GetUses()
			end 
			if item.components.temperature ~= nil and (show_temp or keydown) then
				self.string = self.string .. "\n" .. math.floor(item.components.temperature.current*10)/10 .. "\176C"
			end
			if item.components.fueled ~= nil then
				if item.name == "Thermal Stone" then
					self.string = self.string .. "\n" .. item.components.fueled:GetPercent() * TUNING.HEATROCK_NUMUSES .. " durability"
				else
				if DFV_FUELEDSET == "both" or DFV_FUELEDSET == "default" then
					local minutes_left = math.floor((item.components.fueled.currentfuel / item.components.fueled.rate) / 60)
					local seconds_left = math.floor(item.components.fueled.currentfuel - minutes_left * 60)
					local zero = ""
					if seconds_left < 10 then
						zero = "0"
					end
					self.string = self.string .. "\n" .. minutes_left .. ":" .. zero .. seconds_left
				end
				if DFV_FUELEDSET == "both" or DFV_FUELEDSET == "seg" then
					local total_segments = math.floor(((item.components.fueled.currentfuel / item.components.fueled.rate) / (TUNING.TOTAL_DAY_TIME / 16))*10)/10
					if total_segments > 16 then
						local days = math.floor(total_segments/16)
						local segments = math.floor((total_segments - days*16)*10)/10
						self.string = self.string .. "\n" .. days .. " Days ".. segments .. " Segments"
					else
						self.string = self.string .. "\n" .. total_segments .. " Segments"
					end
				end
				end
			end
			if item.components.armor ~= nil then
				if item.components.armor.condition ~= nil and (show_acond or keydown) then
					self.string = self.string .. "\n" .. "Condition " .. math.floor(item.components.armor.condition)
				end
				if item.components.armor.tags ~= nil and (show_atype or keydown) then
					for k,v in pairs(item.components.armor.tags) do
						self.string = self.string .. "\n" .. "Shields " .. v .. " damage"
					end
				end
				if show_adef then
					self.string = self.string .. "\n" .. "Damage reduction " .. item.components.armor.absorb_percent * 100 .. "%"
				end
			end
			if item.components.insulator ~= nil and (show_insul or keydown) then
				self.string = self.string .. "\n" .. math.floor(item.components.insulator.insulation) .. " insulation"
			end
	

	self.string_dirty:set(self.string)
	self.itemupdate:push()

	end
end




return ItemValues