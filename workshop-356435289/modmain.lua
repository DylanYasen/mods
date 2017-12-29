PrefabFiles = 
{
        "w_pond",
}

        Assets = 
{
	Asset("ATLAS", "images/inventoryimages/w_pond.xml"),
        Asset( "IMAGE", "minimap/w_pond.tex" ),
        Asset( "ATLAS", "minimap/w_pond.xml" ),	
}

        AddMinimapAtlas("minimap/w_pond.xml")

STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH

GLOBAL.STRINGS.NAMES.W_POND = "Fish Farm"
STRINGS.RECIPE_DESC.W_POND = "I May Just Stay Home More."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.W_POND = "Fish like honey,who knew?"

local easy = (GetModConfigData("fishfarmrecipe")=="easy")

        if easy then
local w_pond = GLOBAL.Recipe("w_pond",
{ 
        Ingredient("boards", 5),
        Ingredient("fish", 2),
        Ingredient("bee", 4)
},
        RECIPETABS.FARM, TECH.NONE,"w_pond_placer" )
        w_pond.atlas = "images/inventoryimages/w_pond.xml"

        else 
local w_pond = GLOBAL.Recipe("w_pond",
{ 
        Ingredient("boards", 5),
        Ingredient("fish", 2),
        Ingredient("bee", 4),
        Ingredient("honeycomb", 1),
        Ingredient("rope", 5)
},
        RECIPETABS.FARM, TECH.SCIENCE_TWO,"w_pond_placer" )
        w_pond.atlas = "images/inventoryimages/w_pond.xml"
end