local InitialItems = {}
local Constants = require("edith_plus_scripts.Constants")


---@param player EntityPlayer
function InitialItems:OnPlayerInit(player)
    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    local cost = Isaac.GetCostumeIdByPath("gfx/characters/edith_hoodie.anm2")
    player:AddNullCostume(cost)


    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER then
        player:AddSoulHearts(2)
    end


    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER then
        player:AddTrinket(TrinketType.TRINKET_APPLE_OF_SODOM)
    end

    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER then
        player:SetCard(0, Card.CARD_MAGICIAN)
    end

    --Pocket active item
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER then
        player:AddCollectible(Constants.SALT_SHAKER_ITEM, 3)
        player:AddCollectible(Constants.EDITHS_CURSE_ITEM)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, InitialItems.OnPlayerInit)