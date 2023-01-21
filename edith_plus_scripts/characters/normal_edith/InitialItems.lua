local InitialItems = {}
local Constants = require("edith_plus_scripts.Constants")


---@param player EntityPlayer
function InitialItems:OnPlayerInit(player)
    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    local cost = Isaac.GetCostumeIdByPath("gfx/characters/edith_hoodie.anm2")
    player:AddNullCostume(cost)

    --Initialize tables
    if not EdithPlusMod.Persistent.Unlocks then
        EdithPlusMod.Persistent.Unlocks = {}
    end

    if not EdithPlusMod.Persistent.Unlocks.EDITH then
        EdithPlusMod.Persistent.Unlocks.EDITH = {}
    end

    --Extra soul heart
    --Need's to beat mother for this
    local hasBeatenMother = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.MOTHER]
    if not hasBeatenMother then hasBeatenMother = 0 end
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER and hasBeatenMother > 0 then
        player:AddSoulHearts(2)
    end

    --Trinket
    --Need's to beat greedier for this
    local hasBeatenGreed = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.GREED]
    if not hasBeatenGreed then hasBeatenGreed = 0 end
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER and hasBeatenGreed > 1 then
        player:AddTrinket(TrinketType.TRINKET_APPLE_OF_SODOM)
    end

    --Card
    --Needs to have killed mom's heart for this
    local hasBeatenBossRush = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.BOSS_RUSH]
    if not hasBeatenBossRush then hasBeatenBossRush = 0 end
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER and hasBeatenBossRush > 0 then
        player:SetCard(0, Card.CARD_MAGICIAN)
    end

    --Pocket active item
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER then
        player:AddCollectible(Constants.SALT_SHAKER_ITEM, 3)
        player:AddCollectible(Constants.EDITHS_CURSE_ITEM)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, InitialItems.OnPlayerInit)