for _,surf in pairs(game.surfaces) do
  -- re-index all nixies
  for _,lamp in pairs(surf.find_entities_filtered{name={'nixie-tube', 'nixie-tube-alpha', 'nixie-tube-small'}}) do
    local color = lamp.color
    if color then
      if color.a == 0 then
        color.a = 1
      end

      if color.r==1 and color.g==1 and color.b==1 then
        color = {r=1, g=.6, b=.3, a=1}
      end

      lamp.color = color
    end
  end
end