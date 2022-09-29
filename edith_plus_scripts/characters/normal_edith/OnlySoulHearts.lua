local EdithPlusMod, Constants = table.unpack(...)
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

    if player:GetBoneHearts() > 0 then
        --Remove bone hearts too
        local boneHearts = player:GetBoneHearts()
        player:AddBoneHearts(-boneHearts)

        --For every bone heart removed, add 2 soul hearts
        player:AddSoulHearts(boneHearts * 4)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OnlySoulHearts.OnPlayerUpdate)