local meld = require('meld')
if mods["signalstrings"] then
  meld.meld(data.raw["mod-data"]["signalstrings-mapping"].data --[[@as signalstrings-mapping]], {
    ["{"] = { type="virtual", name="signal-curopen", quality="normal", },
    ["}"] = { type="virtual", name="signal-curclose", quality="normal", },
    ["@"] = { type="virtual", name="signal-at", quality="normal", },
  })
end
