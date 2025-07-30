# Plugins

Other mods may extend Nixie Tubes by defining a plugin. Plugins are `mod-data` prototypes with the `data_type` field set to `"NixieTubesPluginData"`, and a `NixieTubesPluginData` (see class defined in `plugins.lua`) table in `data`.

Plugin code strings are loaded in a restricted environment inside Nixie Tubes. The sandbox environment has a limited set of builtins (`assert`, `error`, `pcall`, `xpcall`, `ipairs`, `next`, `pairs`, `select`, `tonumber`, `tostring`, `type`, `table`, `string`, `bit32`, `math`, `table_size`, `prototypes`, `defines`), a limited version of `remote` (with only `remote.call`), and a few formatting utility function: `int_format`, `make_fixed_format`, `make_enum_format` (from `number_type.lua`).

## Number Types

Addition number types are defined in `data.numberType[key]`, with an int32 or four byte string as a key. The keys must be unique. The numberType data consists of a table with a code string (`code` field) to return a `NixieTubesNumberType` or `NixieTubesSplitNumberType` table.