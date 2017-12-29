        PrefabFiles = {
	"alwaysontikitorch", "tikitorchflame",
}

        Assets = 
{
	
	Asset("ATLAS", "images/inventoryimages/alwaysontikitorch.xml"),
        Asset( "IMAGE", "minimap/alwaysontikitorch.tex" ),
        Asset( "ATLAS", "minimap/alwaysontikitorch.xml" ),	
}

        AddMinimapAtlas("minimap/alwaysontikitorch.xml")

        STRINGS = GLOBAL.STRINGS
        RECIPETABS = GLOBAL.RECIPETABS
        Recipe = GLOBAL.Recipe
        Ingredient = GLOBAL.Ingredient
        TECH = GLOBAL.TECH

        GLOBAL.STRINGS.NAMES.ALWAYSONTIKITORCH = "Always On Tikitorch"
        STRINGS.RECIPE_DESC.ALWAYSONTIKITORCH = "Light My Way Baby!"
        GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ALWAYSONTIKITORCH = "The Island Gods Have Blessed Me."

        local easy = (GetModConfigData("RecipeSkill")=="easy")
        local normal = (GetModConfigData("RecipeSkill")=="normal")
        local hard = (GetModConfigData("RecipeSkill")=="hard")

        if easy then local tikirecipe = GLOBAL.Recipe("alwaysontikitorch",
{ 
        Ingredient("log", 1),
        Ingredient("poop", 1), 
},
        RECIPETABS.LIGHT, TECH.NONE, "alwaysontikitorch_placer" )
        tikirecipe.atlas = "images/inventoryimages/alwaysontikitorch.xml"

        else if normal then local tikirecipe = GLOBAL.Recipe("alwaysontikitorch", 
{ 
        Ingredient("boards", 1),
        Ingredient("poop", 5), 
}, 
        RECIPETABS.LIGHT, TECH.SCIENCE_ONE, "alwaysontikitorch_placer" )
        tikirecipe.atlas = "images/inventoryimages/alwaysontikitorch.xml"        

        else if hard then local tikirecipe = GLOBAL.Recipe("alwaysontikitorch", 
{ 
        Ingredient("boards", 2),
        Ingredient("poop", 5), 
        Ingredient("redgem", 1),
}, 
        RECIPETABS.LIGHT, TECH.SCIENCE_TWO, "alwaysontikitorch_placer" )
        tikirecipe.atlas = "images/inventoryimages/alwaysontikitorch.xml"
        end
    end
end

