name = "DST Fish Farm"
description = "The Fish Farm is a self sustaining food source."
author = "Afro1967"
version = "1.5"

forumthread = "19505-Modders-Your-new-friend-at-Klei!"

priority = 0.346962883
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

api_version = 10

icon_atlas = "w_pond.xml"
icon = "w_pond.tex"

configuration_options =
{
	{
		name = "fishfarmrecipe",
		label = "Advanced Farm Recipe",
		options =
	{
		{description = "Easy", data = "easy"},
		{description = "Hard", data = "hard"},
	},
		default = "easy",
	},
}	