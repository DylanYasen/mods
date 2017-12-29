name = "The Beaver Among Us!"
description = "Woodie, the most customizable lumberjack on the market!\n\n\nVersion PRE 2.0.2"
author = "PrzemoLSZ"
version = "PRE 2.0.2"

forumthread = ""

api_version = 10

dont_starve_compatible = false
dst_compatible = true

configuration_options=
{
	{
		name="beavermode",
		label="Beaverness mechanics",
		hover = "",
		options=
		{	
			{description = "Default", data="def", hover = "[Default] The default werebeaver mechanic."},
			{description = "Default Plus", data="defplus", hover = "For those who find the werebeaver too weak.\n\n*Woodie turns into werebeaver at 0 beaverness (no more 'wood starvation') and transforms back at 100 beaverness.\n*The werebeaver is immune to frezzing, overheating an has absolute waterproofness.\n*It has 80% damage absorption (like a log suit) and deals 51 damage (like a tentacle spike).\n*While Woodie is in beaver mode, beaverness slowly increases. Taking damage speeds this process up."},
			{description = "None", data="none", hover = "Not everybody can handle being true canadian lumberjack.\n\n*Woodie's curse is gone.\n*Woodie loses sanity when chopping down trees, and gains it back by planting them."},
			{description = "Classic", data="classic", hover = "Remember those times when you could literraly bash through everything as a beaver?\nYeah, like a few weeks ago... I'll tell you what, you can still do that!\n\n*Woodie's log meter fills up after chopping down too many trees or during full moon.\n*When it hits 100, Woodie turns into werebeaver. Once the beaverness is at 0 again, he transforms back.\n*Normally, beaverness slowly decreases over time. Taking damage while in beaver form speeds this process up.\n*As the werebeaver, you can eat wood-ish items (logs, pinecones, etc.)\nto stay in the werebeaver form for longer periods of time.\n*Werebeaver has 80% damage absorption, deals 51 damage, his teeth can be used\nto chop down trees, mine rocks, dig and hammer things.\n*Woodie drops his inventory when transforming."},
			{description = "Personality", data="personality", hover = "TODO, coming soon!"},
		},
		default="def"
	},
	{
		name="beaver_cooldown",
		label="Beaver's cooldown",
		hover = "The time that has to pass before Woodie is able\nto transform into the beaver again ('Classic' & 'Personality' modes only).",
		options=
		{	
			{description = "None", data=0, hover = "[Default] No cooldown."},
			{description = "60s", data=60, hover = "Just one minute"},
			{description = "120s", data=120, hover = "2 minutes"},
			{description = "240s", data=240, hover = "Half a day, 4 minutes."},
			{description = "480s", data=480, hover = "One day, 8 minutes."},
		},
		default=0
	},
}

all_clients_require_mod = true
clients_only_mod = false

icon_atlas = "dstwoodie_ingame.xml"
icon = "dstwoodie_ingame.tex"

server_filter_tags = {"woodie"}
