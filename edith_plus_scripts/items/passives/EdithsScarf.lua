local Constants = require("edith_plus_scripts.Constants")
local EdithsScarf = {}


--From hybrid (the andromeda guy), found on the discord server
local function TearsUp(firedelay, val)
    local currentTears = 30 / (firedelay + 1)
    local newTears = currentTears + val
    return math.max((30 / newTears) - 1, -0.99)
end


---@param player EntityPlayer
---@param cacheFlag CacheFlag
function EdithsScarf:OnCacheUpdate(player, cacheFlag)
    local edithsScarfNum = player:GetCollectibleNum(Constants.EDITHS_SCARF_ITEM)

    if edithsScarfNum == 0 then return end

    local statMultiplier = 1
    for _ = 1, edithsScarfNum, 1 do
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = TearsUp(player.MaxFireDelay, Constants.EDITHS_SCARF_TEARDELAY * statMultiplier)
        elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + Constants.EDITHS_SCARF_SHOTSPEED * statMultiplier
        elseif cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + Constants.EDITHS_SCARF_LUCK * statMultiplier
        end

        statMultiplier = statMultiplier * Constants.EDITHS_SCARF_STAT_MULTIPLIER
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EdithsScarf.OnCacheUpdate)