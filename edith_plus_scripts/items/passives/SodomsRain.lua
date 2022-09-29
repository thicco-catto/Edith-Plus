local EdithPlusMod, Constants = table.unpack(...)
local SodomsRain = {}
local game = Game()


---@param player EntityPlayer
function SodomsRain:OnPeffectUpdate(player)
    if not player:HasCollectible(Constants.SODOMS_RAIN_ITEM) then return end

    local playerData = player:GetData()

    if not playerData.LastSodomsRainMetoriteFrame then
        playerData.LastSodomsRainMetoriteFrame = game:GetFrameCount()
    end

    if game:GetFrameCount() - playerData.LastSodomsRainMetoriteFrame < Constants.SODOMS_RAIN_METEORITE_MIN_INTERVAL then return end

    local rng = player:GetCollectibleRNG(Constants.SODOMS_RAIN_ITEM)

    local chance = rng:RandomInt(10000)
    local luckModifier = 0

    if player.Luck > 0 then
        --For each positive luck you get +0.9 chance (max 10)
        luckModifier = player.Luck * 90
        luckModifier = math.min(1000, luckModifier)
    elseif player.Luck < 0 then
        --For each negative luck you get -0.2 chance (min 0.05)
        luckModifier = player.Luck * 20
        luckModifier = math.max(5, luckModifier)
    end

    if Constants.SODOMS_RAIN_METEORITE_BASE_SPAWN_CHANCE > (chance - luckModifier) then
        local meteorite = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Constants.SMALL_METEORITE_FAMILIAR, 0, Isaac.GetRandomPosition(), Vector.Zero, player)
        meteorite:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        playerData.LastSodomsRainMetoriteFrame = game:GetFrameCount()
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SodomsRain.OnPeffectUpdate)