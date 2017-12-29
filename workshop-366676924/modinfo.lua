name = "DST Always On Tiki Torch"
description = "A decorative tiki totem craftable under the light tab!"
author = "Afro1967"
version = "1.3"

forumthread = "19505-Modders-Your-new-friend-at-Klei!"

priority = 0.346962881
all_clients_require_mod = true
dst_compatible = true
client_only_mod = false

api_version = 10


icon_atlas = "alwaysontikitorch.xml"
icon = "alwaysontikitorch.tex"

configuration_options =
{
	{
		name = "RecipeSkill",
		label = "‎Recipe",
		options =
	{
		{description = "Easy", data = "easy"},
		{description = "Normal", data = "normal"},
		{description = "Hard", data = "hard"},
	},
		default = "normal",
	},
}