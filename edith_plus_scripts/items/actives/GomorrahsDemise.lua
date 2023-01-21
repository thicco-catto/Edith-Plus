local Constants = require("edith_plus_scripts.Constants")
local GomorrahsDemise = {}
local game = Game()

function GomorrahsDemise:OnItemUse(_, _, player)
    EdithPlusMod.GetPlayerData(player).GomorrahsDemiseCountdown = Constants.GOMORRAHS_DEMISE_DURATION

    return {
        Discharge = true,
        Remove = true,
        ShowAnim = true
    }
end
EdithPlusMod:AddCallback(ModCallbacks.MC_USE_ITEM, GomorrahsDemise.OnItemUse, Constants.GOMORRAHS_DEMISE_ITEM)


---@param player EntityPlayer
function GomorrahsDemise:OnPeffectUpdate(player)
    if not EdithPlusMod.GetPlayerData(player).GomorrahsDemiseCountdown then return end

    local rng = player:GetCollectibleRNG(Constants.GOMORRAHS_DEMISE_ITEM)

    if game:GetFrameCount() % Constants.GOMORRAHS_DEMISE_METEORITE_INTERVAL == 0 then
        local meteoriteTypeToSpawn = Constants.SMALL_METEORITE_FAMILIAR
        if Constants.GOMORRAHS_DEMISE_BIG_METEORITE_CHANCE > rng:RandomInt(100) then
            meteoriteTypeToSpawn = Constants.BIG_METEORITE_FAMILIAR
        end

        local meteorite = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, meteoriteTypeToSpawn, 0, Isaac.GetRandomPosition(), Vector.Zero, player)
        meteorite:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end

    --Decrease the timer and make it nil if it reaches 0
    EdithPlusMod.GetPlayerData(player).GomorrahsDemiseCountdown = EdithPlusMod.GetPlayerData(player).GomorrahsDemiseCountdown - 1

    if EdithPlusMod.GetPlayerData(player).GomorrahsDemiseCountdown == 0 then
        EdithPlusMod.GetPlayerData(player).GomorrahsDemiseCountdown = nil
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, GomorrahsDemise.OnPeffectUpdate)