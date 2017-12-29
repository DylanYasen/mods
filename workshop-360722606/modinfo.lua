-- This information tells other players more about the mod
name = "Detailed Tooltips"
description = "Enhances tooltips to display values for: weapon base damage, tool durability, armor condition, armor protection type, and armor damage reduction. Client Bruteforce is in testing. Some things likely won't work, and crashes will likely happen. Use at your own risk."
author = "Daynar, gregdwilson"
version = "1.5a"

forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

all_clients_require_mod = true 

-- Can specify a custom icon for this mod!
icon_atlas = "weparmtooltips.xml"
icon = "weparmtooltips.tex"

-- Specify the priority
priority=3

configuration_options =
{
	
	{
		name = "DFV_ClientPrediction",
		label = "Enable client bruteforce for item tile percent",
		options =	{
						{description = "Off", data = "default"},
						{description = "On", data = "On"},
					},

		default = "default",
	},
	
	{
		name = "DFV_PercentReplace",
		label = "Replace icon %",
		options =	{
						{description = "Off", data = "default"},
						{description = "On", data = "On"},
					},

		default = "default",
	},
	
	{
		name = "DFV_ShowDamage",
		label = "Show damage",
		options =	{
						{description = "On", data = "default"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
	{
		name = "DFV_ShowUses",
		label = "Show uses",
		options =	{
						{description = "On", data = "default"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
	{
		name = "DFV_FueledSettings",
		label = "Fueled items time format",
		options =	{
						{description = "Min:Sec", data = "default"},
						{description = "Clock segments", data = "seg"},
						{description = "Both", data = "both"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
	{
		name = "DFV_ShowTemperature",
		label = "Show temperature",
		options =	{
						{description = "On", data = "default"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
	{
		name = "DFV_ShowACondition",
		label = "Show armour condition",
		options =	{
						{description = "On", data = "default"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
	{
		name = "DFV_ShowADefence",
		label = "Show armour defence",
		options =	{
						{description = "On", data = "default"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
	{
		name = "DFV_ShowAType",
		label = "Show armour type",
		options =	{
						{description = "On", data = "default"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
	{
		name = "DFV_ShowInsulation",
		label = "Show insulation",
		options =	{
						{description = "On", data = "default"},
						{description = "Off", data = "off"},
					},

		default = "default",
	},
}