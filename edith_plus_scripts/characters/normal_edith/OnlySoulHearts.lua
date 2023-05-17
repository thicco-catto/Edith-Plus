local Constants = require("edith_plus_scripts.Constants")
local OnlySoulHearts = {}

---@param player EntityPlayer
function OnlySoulHearts:OnPlayerUpdate(player)
    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    if player:GetMaxHearts() > 0 then
        --If the player has some amount of max health, remove it and add soul hearts instead
        local maxHearts = player:GetMaxHearts()
        player:AddMaxHearts(-maxHearts, true)
        player:AddSoulHearts(maxHearts)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnlySoulHearts.OnPlayerUpdate)