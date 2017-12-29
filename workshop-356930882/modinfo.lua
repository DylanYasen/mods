-- This information tells other players more about the mod
name = "Infinite Tent (and Siesta) Uses "
description = "Simple mod that makes tents infinitely durable."
author = "Mucker Mayhem"
version = "1.7.1"

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

---- Can specify a custom icon for this mod!
icon_atlas = "modicon.xml"
icon = "modicon.tex"

--This lets the clients know that they need to download the mod before they can join a server that is using it.
--all_clients_require_mod = true

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
server_filter_tags = {"infinite tent uses"}


configuration_options =
{
    {
        name = "uses",
        label = "Tent Uses",
        options = 
        {
            {description = "5", data = 5},
			{description = "6 (default)", data = 6},
            {description = "10", data = 10},
			{description = "15", data = 15},
            {description = "20", data = 20},
			{description = "25", data = 25},
            {description = "30", data = 30},
			{description = "35", data = 35},
			{description = "45", data = 40},
			{description = "45", data = 45},
            {description = "50", data = 50},
			{description = "55", data = 55},
			{description = "60", data = 60},
			{description = "65", data = 65},
            {description = "70", data = 70},
			{description = "75", data = 75},
			{description = "80", data = 80},
			{description = "85", data = 85},
            {description = "90", data = 90},
			{description = "95", data = 95},
			{description = "100", data = 100},
			{description = "Infinite", data = 10000000}
        },
        default = 10000000,
    },
	{
	name = "uses2",
        label = "Siesta Canopy Uses",
        options = 
        {
            {description = "5", data = 5},
			{description = "6 (default)", data = 6},
            {description = "10", data = 10},
			{description = "15", data = 15},
            {description = "20", data = 20},
			{description = "25", data = 25},
            {description = "30", data = 30},
			{description = "35", data = 35},
			{description = "45", data = 40},
			{description = "45", data = 45},
            {description = "50", data = 50},
			{description = "55", data = 55},
			{description = "60", data = 60},
			{description = "65", data = 65},
            {description = "70", data = 70},
			{description = "75", data = 75},
			{description = "80", data = 80},
			{description = "85", data = 85},
            {description = "90", data = 90},
			{description = "95", data = 95},
			{description = "100", data = 100},
			{description = "Infinite", data = 10000000}
        },
        default = 10000000,
	},
}