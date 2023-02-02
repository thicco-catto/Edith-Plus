EdithPlusMod = RegisterMod("Edith Plus Mod", 1)


--Save data
require("edith_plus_scripts.SaveData")(EdithPlusMod)


--Achivements
require("edith_plus_scripts.achievements.pause_screen_completion_marks_api")
require("edith_plus_scripts.achievements.CompletionMarks")
require("edith_plus_scripts.achievements.ShowAchievementPaper")
require("edith_plus_scripts.achievements.AchievementTracker")
require("edith_plus_scripts.achievements.LockedItemBlocker")


--Common for both ediths
require("edith_plus_scripts.characters.MiniMagneto")


--Regular Edith
require("edith_plus_scripts.characters.normal_edith.Stats")
require("edith_plus_scripts.characters.normal_edith.InitialItems")
require("edith_plus_scripts.characters.normal_edith.BiggerTearSize")
require("edith_plus_scripts.characters.normal_edith.CallusLikeInmunity")
require("edith_plus_scripts.characters.normal_edith.DoubleCreepDamage")
require("edith_plus_scripts.characters.normal_edith.HigherChanceSodomGomorrahFirstDeal")
require("edith_plus_scripts.characters.normal_edith.InvisibleAnalogStick")
require("edith_plus_scripts.characters.normal_edith.OnlySoulHearts")
require("edith_plus_scripts.characters.normal_edith.SpecialMovement")


--Tainted Edith
require("edith_plus_scripts.characters.tainted_edith.FireballTears")
require("edith_plus_scripts.characters.tainted_edith.InitialItems")
require("edith_plus_scripts.characters.tainted_edith.OnlyBlackHearts")
require("edith_plus_scripts.characters.tainted_edith.SpecialMovement")
require("edith_plus_scripts.characters.tainted_edith.Stats")


--Familiars
require("edith_plus_scripts.familiars.SaltBabyFamiliar")
require("edith_plus_scripts.familiars.SmallMeteorite")


--Active items
require("edith_plus_scripts.items.actives.GomorrahsDemise")
require("edith_plus_scripts.items.actives.LotsCup")
require("edith_plus_scripts.items.actives.SaltShaker")


--Passive items
require("edith_plus_scripts.items.passives.EdithsScarf")
require("edith_plus_scripts.items.passives.SaltBabyItem")
require("edith_plus_scripts.items.passives.SaltCurse")
require("edith_plus_scripts.items.passives.SodomsRain")


function EdithPlusMod:DebugCommand(cmd, args)
    if cmd == "edithunlock" then
        args = string.upper(args)
        local prevState = EdithPlusMod.Persistent.Unlocks.EDITH[args]
        if prevState and prevState == 2 then
            print("Locking " .. args)
            EdithPlusMod.Persistent.Unlocks.EDITH[args] = 0
        else
            print("Unlocking " .. args)
            EdithPlusMod.Persistent.Unlocks.EDITH[args] = 2
        end
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, EdithPlusMod.DebugCommand)