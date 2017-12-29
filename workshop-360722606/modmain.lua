table.insert(GLOBAL.STRINGS, "DFV_LANG")
table.insert(GLOBAL.STRINGS, "DFV_HUNGER")
table.insert(GLOBAL.STRINGS, "DFV_HEALTH")
table.insert(GLOBAL.STRINGS, "DFV_SANITY")
table.insert(GLOBAL.STRINGS, "DFV_SPOILSOON")
table.insert(GLOBAL.STRINGS, "DFV_SPOILIN")
table.insert(GLOBAL.STRINGS, "DFV_SPOILDAY")
table.insert(GLOBAL.STRINGS, "DFV_MIN")
local DFV_SHOWDUR = not(GetModConfigData("DFV_PercentReplace", true)=="default")
local DFV_FUELEDSET = GetModConfigData("DFV_FueledSettings", true)
local show_damage = (GetModConfigData("DFV_ShowDamage", true)=="default")
local show_uses = (GetModConfigData("DFV_ShowUses", true)=="default")
local show_temp = (GetModConfigData("DFV_ShowTemperature", true)=="default")
local show_insul = (GetModConfigData("DFV_ShowInsulation", true)=="default")
local show_acond = (GetModConfigData("DFV_ShowACondition", true)=="default")
local show_adef = (GetModConfigData("DFV_ShowADefence", true)=="default")
local show_atype = (GetModConfigData("DFV_ShowAType", true)=="default")
local client_pred = not(GetModConfigData("DFV_ClientPrediction")=="default")
local require = GLOBAL.require
local itemvalues = require "components/itemvalues"
local ItemTile = require "widgets/itemtile"
local Inv = require "widgets/inventorybar"
local Text = require "widgets/text" 


 
	local function ItemTileConstruct(self, invitem)
	if GLOBAL.TheNet:GetIsServer() and DFV_SHOWDUR then
		self.inst:ListenForEvent("temperaturedelta",
				function(invitem, data)
					self:SetPercent(0) -- trash value
				end, invitem)
	end
		self.true_percent = 1
		self.tooltip_mod_loaded = 1
	function TimeString(percent, max_time)
		local str = ""
		if DFV_FUELEDSET == "both" or DFV_FUELEDSET == "default" then
			local minutes_left = math.floor((max_time * percent) / 60)
			local seconds_left = math.floor(max_time * percent - minutes_left * 60)
			local zero = ""
			if seconds_left < 10 then
				zero = "0"
			end
			str = "\n" .. minutes_left .. ":" .. zero .. seconds_left
		end
		if DFV_FUELEDSET == "both" or DFV_FUELEDSET == "seg" then
					local total_segments = math.floor(((max_time * percent) / (TUNING.TOTAL_DAY_TIME / 16))*10)/10
					if total_segments > 16 then
						local days = math.floor(total_segments/16)
						local segments = math.floor((total_segments - days*16)*10)/10
						str = str .. "\n" .. days .. " Days ".. segments .. " Segments"
					else
						str = str .. "\n" .. total_segments .. " Segments"
					end
				end
		return str
	end
	
	function SmallTimeString(percent, max_time)
		local str = ""
		if DFV_FUELEDSET == "both" or DFV_FUELEDSET == "default" then
			local minutes_left = math.floor((max_time * percent) / 60)
			local seconds_left = math.floor(max_time * percent - minutes_left * 60)
			local zero = ""
			if seconds_left < 10 then
				zero = "0"
			end
			str = minutes_left .. ":" .. zero .. seconds_left
		end
		return str
	end
	
	function ArmorString(percent,max_cond, def)
		local str = ""
			if show_acond then
					str = str .. "\n" .. "Condition " .. math.floor(percent*max_cond*10)/10
			end
			if show_adef then
				str = str .. "\n" .. "Damage reduction " .. def * 100 .. "%"
			end
		return str
	end
	end
	AddClassPostConstruct("widgets/itemtile", ItemTileConstruct)
 
 
 
 
 
local ItemTile_GetDescriptionString_base = ItemTile.GetDescriptionString or function() return "" end

function ItemTile:OnGainFocus()
	local player = GLOBAL.ThePlayer
	self:UpdateTooltip() 
	self.inst:DoPeriodicTask(1, function()
		if self.focus and self.isupdated then	
			self:UpdateTooltip()
		end
		end)
end



function ItemTile:UpdateTooltip()
	local player = GLOBAL.ThePlayer
	local keydown = false
	if GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_FORCE_INSPECT) then
		keydown = true
	end
	
	self.isupdated = false
	SendModRPCToServer(MOD_RPC[modname]["FIU"], self.item, keydown, DFV_FUELEDSET, show_damage, show_uses, show_temp, show_insul, show_acond, show_adef, show_atype)
	player:ListenForEvent("item_value_updated", function()
		
		local str = self:GetDescriptionString()
		self:SetTooltip(str)
		if self.item:GetIsWet() then
			self:SetTooltipColour(GLOBAL.unpack(GLOBAL.WET_TEXT_COLOUR))
		else
			self:SetTooltipColour(GLOBAL.unpack(GLOBAL.NORMAL_TEXT_COLOUR))
		end
		self.isupdated = true
    end)
	

	
end

function ItemTile:GetDescriptionString()
	
	local player = GLOBAL.ThePlayer
	local strings = GLOBAL.STRINGS

	local str = ItemTile_GetDescriptionString_base(self)
	
	local ModString = player.components.itemvalues.string_dirty:value()
	
	if ModString ~= "" then
		str = str .. ModString 
	end
	
    return str .. "\n\n" .. " "
        
end



function ItemTile:SetPercent(percent)
	self.true_percent = percent
	if not self.percent then
        self.percent = self:AddChild(Text(GLOBAL.NUMBERFONT, 42))
        self.percent:SetPosition(5,-32+15,0)
    end
	if GLOBAL.TheNet:GetIsServer() then
		if self.item.components.finiteuses ~= nil and GLOBAL.TheNet:GetIsServer() and DFV_SHOWDUR then
			self.percent:SetString( self.item.components.finiteuses:GetUses())
		elseif self.item.components.armor ~= nil and GLOBAL.TheNet:GetIsServer() and DFV_SHOWDUR then
			if self.item.components.armor.condition ~= nil then
				self.percent:SetString( math.floor(self.item.components.armor.condition))
			end
		elseif self.item.components.temperature ~= nil  and GLOBAL.TheNet:GetIsServer() and DFV_SHOWDUR then
				self.percent:SetString(math.floor(self.item.components.temperature.current + .5) .. "\176C")
		elseif self.item.components.fueled ~= nil and DFV_FUELEDSET ~= "seg" and GLOBAL.TheNet:GetIsServer() and DFV_SHOWDUR then
			local minutes_left = math.floor((self.item.components.fueled.currentfuel / self.item.components.fueled.rate) / 60)
			local seconds_left = math.floor(self.item.components.fueled.currentfuel - minutes_left * 60)
			local zero = ""
			if seconds_left < 10 then
				zero = "0"
			end
			self.percent:SetString(  minutes_left .. ":" .. zero .. seconds_left)
		else
			local val_to_show = percent*100
			if val_to_show > 0 and val_to_show < 1 then
				val_to_show = 1
			end
			self.percent:SetString(string.format("%2.0f%%", val_to_show))
		end
	elseif DFV_SHOWDUR and client_pred and self.true_percent ~= nil and  self.tooltip_mod_loaded ~= nil then
	-- client
	local str = ""
	local n = self.item.name
	local t = TUNING
		if n == "Axe" then
					str = math.floor(t.AXE_USES * self.true_percent)
			elseif n == "Pickaxe" then
					str = math.floor(t.PICKAXE_USES * self.true_percent)
			elseif n == "Shovel" then
					str = math.floor(t.SHOVEL_USES * self.true_percent)
			elseif n == "Hammer" then
					str = math.floor(t.HAMMER_USES * self.true_percent)
			elseif n == "Pitchfork" then
					str = math.floor(t.PITCHFORK_USES * self.true_percent)
			elseif n == "Bugnet" then
					str = math.floor(t.BUGNET_USES * self.true_percent)
			elseif n == "Spear" then
					str = math.floor(t.SPEAR_USES * self.true_percent)
			elseif n == "Tentacle Spike" then
					str = math.floor(t.SPIKE_USES * self.true_percent)
			elseif n == "Fishing rod" then
					str = math.floor(t.FISHINGROD_USES * self.true_percent)
			elseif n == "Boomerang" then
					str = math.floor(t.BOOMERANG_USES * self.true_percent)
			elseif n == "Nightsword" then
					str = math.floor(t.NIGHTSWORD_USES * self.true_percent)
			elseif n == "Icestaff" then
					str = math.floor(t.ICESTAFF_USES * self.true_percent)
			elseif n == "Firestaff" then
					str = math.floor(t.FIRESTAFF_USES * self.true_percent)
			elseif n == "Telestaff" then
					str = math.floor(t.TELESTAFF_USES * self.true_percent)
			elseif n == "Hambat" then
					str = math.floor(t.HAMBAT_USES * self.true_percent)
			elseif n == "Batbat" then
					str = math.floor(t.BATBAT_USES * self.true_percent)
			elseif n == "Miner hat" then
				str = SmallTimeString(self.true_percent, t.MINERHAT_LIGHTTIME)
			elseif n == "Lantern" then
				str = SmallTimeString(self.true_percent, t.LANTERN_LIGHTTIME)
			elseif n == "Spiderhat" then
				str = SmallTimeString(self.true_percent, t.SPIDERHAT_PERISHTIME)
			elseif n == "One-man Band" then
				str = SmallTimeString(self.true_percent, t.ONEMANBAND_PERISHTIME)
			elseif n == "Umbrella" then
				str = SmallTimeString(self.true_percent, t.UMBRELLA_PERISHTIME)
			elseif n == "Rabbit Earmuffs" then
				str = SmallTimeString(self.true_percent, t.EARMUFF_PERISHTIME)
			elseif n == "Winter Hat" then
				str = SmallTimeString(self.true_percent, t.WINTERHAT_PERISHTIME)
			elseif n == "Beefalo Hat" then
				str = SmallTimeString(self.true_percent, t.BEEFALOHAT_PERISHTIME)
			elseif n == "Breezy Vest" then
				str = SmallTimeString(self.true_percent, t.TRUNKVEST_PERISHTIME)
			elseif n == "Puffy Vest" then
				str = SmallTimeString(self.true_percent, t.TRUNKVEST_PERISHTIME)
			elseif n == "Dapper Vest" then
				str = SmallTimeString(self.true_percent, t.SWEATERVEST_PERISHTIME)
			elseif n == "Tam o' Shanter" then
				str = SmallTimeString(self.true_percent, t.WALRUSHAT_PERISHTIME)
			elseif n == "Feather Hat" then
				str = SmallTimeString(self.true_percent, t.FEATHERHAT_PERISHTIME)
			elseif n == "Top Hat" then
				str = SmallTimeString(self.true_percent, t.TOPHAT_PERISHTIME)
			elseif n == "Grass Suit" then
				str = math.floor(self.true_percent*t.ARMORGRASS)
			elseif n == "Log Suit" then
				str = math.floor(self.true_percent*t.ARMORWOOD)
			elseif n == "Night Armor" then
				str = math.floor(self.true_percent*t.ARMOR_SANITY)
			elseif n == "Football Helmet" then
				str = math.floor(self.true_percent*t.ARMOR_FOOTBALLHAT)
			elseif n == "Beekeeper Hat" then
				str = math.floor(self.true_percent*t.ARMOR_BEEHAT)
			elseif n == "Pan Flute" then
					str = math.floor(t.PANFLUTE_USES * self.true_percent)
			elseif n == "Beefalo Horn" then
					str = math.floor(t.HORN_USES * self.true_percent)
			elseif n == "Torch" then
					str = SmallTimeString(self.true_percent, t.TORCH_FUEL)
			end
			if str ~= "" then
				self.percent:SetString(str)
			else
				local val_to_show = percent*100
				if val_to_show > 0 and val_to_show < 1 then
					val_to_show = 1
				end
				self.percent:SetString(string.format("%2.0f%%", val_to_show))
			end
	else
		local val_to_show = percent*100
				if val_to_show > 0 and val_to_show < 1 then
					val_to_show = 1
				end
				self.percent:SetString(string.format("%2.0f%%", val_to_show))
	end
end

	
local Inv_UpdateCursorText_base = Inv.UpdateCursorText or function() return "" end

function Inv:UpdateCursorText()
 
	local tmp = Inv_UpdateCursorText_base(self)
 
    local inv_item = self:GetCursorItem()
    if inv_item ~= nil and inv_item.replica.inventoryitem == nil then
        inv_item = nil
    end
    
 	if self.open then
	    if inv_item ~= nil then
	    
	        local controller_id = GLOBAL.TheInput:GetControllerID()
			local realfood = nil
			local show_spoil = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_INSPECT)
			
	        local player = GLOBAL.ThePlayer
	        local active_item = player.replica.inventory:GetActiveItem()
	        
	 	    local strings = GLOBAL.STRINGS
			local str = {}
			table.insert(str, self.actionstringbody:GetString())
	
			
			local keydown = GLOBAL.TheInput:IsControlPressed(GLOBAL.CONTROL_INSPECT)
			
			SendModRPCToServer(MOD_RPC[modname]["FIU"], self.item, keydown, DFV_FUELEDSET, show_damage, show_uses, show_temp, show_insul, show_acond, show_adef, show_atype)
			
			local ModString = string.sub(player.components.itemvalues.string_dirty:value(), 2)
			if ModString ~= "" then
				table.insert(str, ModString)
			end
			    	    
			local TIP_YFUDGE = 16
			local W = 68
			local CURSOR_STRING_DELAY = 10
	        local was_shown = self.actionstring.shown
	        local old_string = self.actionstringbody:GetString()
	        local new_string = table.concat(str, '\n')
	        
	        if old_string ~= new_string then
	            self.actionstringbody:SetString(new_string)
	            self.actionstringtime = CURSOR_STRING_DELAY
	            self.actionstring:Show()
	        end
	
	        local w0, h0 = self.actionstringtitle:GetRegionSize()
	        local w1, h1 = self.actionstringbody:GetRegionSize()
	
	        local wmax = math.max(w0, w1)
	
	        local dest_pos = self.active_slot:GetWorldPosition()
	
	        local xscale, yscale, zscale = self.root:GetScale():Get()
	
	        if self.active_slot.side_align_tip then
	            -- in-game containers, chests, fridge
	            self.actionstringtitle:SetPosition(wmax/2, h0/2)
	            self.actionstringbody:SetPosition(wmax/2, -h1/2)
	
	            dest_pos.x = dest_pos.x + self.active_slot.side_align_tip * xscale
	        elseif self.active_slot.top_align_tip then
	            -- main inventory
	            self.actionstringtitle:SetPosition(0, h0/2 + h1)
	            self.actionstringbody:SetPosition(0, h1/2)
	
	            dest_pos.y = dest_pos.y + (self.active_slot.top_align_tip + TIP_YFUDGE) * yscale
	        else
	            -- old default as fallback ?
	            self.actionstringtitle:SetPosition(0, h0/2 + h1)
	            self.actionstringbody:SetPosition(0, h1/2)
	
	            dest_pos.y = dest_pos.y + (W/2 + TIP_YFUDGE) * yscale
	        end
	
	       
	        if dest_pos:DistSq(self.actionstring:GetPosition()) > 1 then
	            self.actionstringtime = CURSOR_STRING_DELAY
	            if was_shown then
	                self.actionstring:MoveTo(self.actionstring:GetPosition(), dest_pos, .1)
	            else
	                self.actionstring:SetPosition(dest_pos)
	                self.actionstring:Show()
	            end
	        end
	
	end
	end
end


AddPlayerPostInit(function(inst) 
	inst:AddComponent("itemvalues")
end)


AddModRPCHandler(modname, "FIU", function(player, item, keydown, DFV_FUELEDSET, show_damage, show_uses, show_temp, show_insul, show_acond, show_adef, show_atype)
	player.components.itemvalues:On_ItemValue_Changed(player, item, keydown, DFV_FUELEDSET, show_damage, show_uses, show_temp, show_insul, show_acond, show_adef, show_atype)
end)
