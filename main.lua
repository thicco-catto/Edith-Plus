EdithPlusMod = RegisterMod("Edith Plus Mod", 1)


--Libraries
require("edith_plus_scripts.HiddenItemManager"):Init(EdithPlusMod)
require("edith_plus_scripts.SaveData")(EdithPlusMod)


--Regular Edith
require("edith_plus_scripts.characters.normal_edith.Stats")
require("edith_plus_scripts.characters.normal_edith.InitialItems")
require("edith_plus_scripts.characters.normal_edith.BiggerTearSize")
require("edith_plus_scripts.characters.normal_edith.CallusLikeInmunity")
require("edith_plus_scripts.characters.normal_edith.DoubleCreepDamage")
require("edith_plus_scripts.characters.normal_edith.InvisibleAnalogStick")
require("edith_plus_scripts.characters.normal_edith.MiniMagneto")
require("edith_plus_scripts.characters.normal_edith.OnlySoulHearts")
require("edith_plus_scripts.characters.normal_edith.SpecialMovement")


--Active items
require("edith_plus_scripts.items.actives.SaltShaker")


--Passive items
require("edith_plus_scripts.items.passives.SaltCurse")