PrefabFiles = {}
local beavermode = GetModConfigData("beavermode")
local variants = {
	defplus = "woodie_plus",
	none = "woodie_nobeav",
	classic = "woodie_classic",
}

----------------

if variants[beavermode] then
	print("[TBAU] overriding woodie's prefab: "..variants[beavermode])
	table.insert(PrefabFiles, variants[beavermode])

	local pathname = "scripts/tbau_scripts/"..variants[beavermode]..".lua"
	local check_pathname = env.MODROOT..pathname
	if (GLOBAL.kleiloadlua(check_pathname) ~= nil) and (type(GLOBAL.kleiloadlua(check_pathname) ~= nil) ~= "string") then
		print("[TBAU] loading lua: "..pathname)
		modimport(pathname)
	end
end

GLOBAL.TUNING.BEAVERNESS_COOLDOWN = GetModConfigData("beaver_cooldown")