for _,surf in pairs(game.surfaces) do
  -- re-index all nixies
  for _,lamp in pairs(surf.find_entities_filtered{name={'nixie-tube', 'nixie-tube-alpha', 'nixie-tube-small'}}) do
    local color = lamp.color
    if color and color.a == 0 then
      color.a = 1
      lamp.color = color
    end
  end
end