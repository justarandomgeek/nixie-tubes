local effects = data.raw["technology"]["circuit-network"].effects
effects[#effects+1] = {
  type = "unlock-recipe",
  recipe = "nixie-tube",
}
effects[#effects+1] = {
  type = "unlock-recipe",
  recipe = "nixie-tube-alpha",
}
effects[#effects+1] = {
  type = "unlock-recipe",
  recipe = "nixie-tube-small",
}
