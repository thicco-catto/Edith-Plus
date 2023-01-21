local Stats = {}
local Constants = require("edith_plus_scripts.Constants")


---@param player EntityPlayer
---@param cache CacheFlag
function Stats:OnCache(player, cache)
    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay - 3
    end

    if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed + 0.15
    end

    if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange + 3.5
    end

    if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed + 0.5
    end

    if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck -1
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Stats.OnCache)