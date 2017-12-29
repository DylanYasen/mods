name = "[DST]+[ROG]The Light Mod"
description = "Respawn portal can spawn light at night and configurable changes for skeleton. Compatible with ROG and default DST."
author = "A-Mod"
version = "1.00"

api_version = 10
forumthread = ""

-- Specify compatibility with the game!
dont_starve_compatible = false
reign_of_giants_compatible = true
dst_compatible = true
client_only_mod = false
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{
    {
        name = "enable_light_near_respawnportal",
        label = "Portal light",
        options =
		{
			{description = "Disable", data = 0},
			{description = "Enable", data = 1},
		},
        default = 1
    },
    {
        name = "disable_skeleton_collision",
        label = "Skeleton collision",
        options =
		{
		{description = "Disable", data = 0},
		{description = "Enable", data = 1},
		},
        default = 0,
    },
    {
        name = "remove_skeleton_on_death",
        label = "Remove skeleton on dead",
        options =
		{
		{description = "Disable", data = 0},
		{description = "Enable", data = 1},
		},
        default = 0,
    }, 
	{
        name = "disable_revive_penalty_onrespawn",
        label = "Revive health penalty",
        options =
		{
		{description = "Disable", data = 0},
		{description = "20hp", data = 20},
		{description = "40hp-default", data = 40},
		{description = "50hp", data = 50},
		},
        default = 0,
    }, 
}