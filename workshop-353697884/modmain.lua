STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH

STRINGS.RECIPE_DESC.GEARS = "A useful collection of mechanical...stuff."

Recipe( "gears", { Ingredient("cutstone", 4), Ingredient("twigs", 6), Ingredient("goldnugget", 4), Ingredient("flint", 6) }, RECIPETABS.REFINE, TECH.SCIENCE_TWO )
