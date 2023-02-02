local Stats = {}
local Constants = require("edith_plus_scripts.Constants")


---@param player EntityPlayer
---@param cache CacheFlag
function Stats:OnCache(player, cache)
    if player:GetPlayerType() ~= Constants.TAINTED_EDITH_PLAYER then return end

    if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck - 1
    end

    if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_BURN
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Stats.OnCache)