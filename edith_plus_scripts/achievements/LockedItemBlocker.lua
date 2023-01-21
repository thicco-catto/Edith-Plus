local Constants = require("edith_plus_scripts.Constants")
local LockedItemBlocker = {}
local game = Game()


local function TryRemoveItemFromPool(item)
    local itemPool = game:GetItemPool()
    local existed = itemPool:RemoveCollectible(item)

    --It sometimes doesn't work, so repeat it until it does lmao
    while existed do
        existed = itemPool:RemoveCollectible(item)
    end
end


function LockedItemBlocker:OnGameStart()
    --Remove items from item pools if they haven't been unlocked

    --Salt baby unlocked by beating Isaac
    local hasBeatenIsaac = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.ISAAC]
    if not hasBeatenIsaac or hasBeatenIsaac == 0 then
        TryRemoveItemFromPool(Constants.SALT_BABY_ITEM)
    end

    --Sodom's rain unlocked by beating Blue Baby
    local hasBeatenBlueBaby = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.BLUE_BABY]
    if not hasBeatenBlueBaby or hasBeatenBlueBaby == 0 then
        TryRemoveItemFromPool(Constants.SODOMS_RAIN_ITEM)
    end

    --Lot's cup unlocked by beating Satan
    local hasBeatenSatan = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.SATAN]
    if not hasBeatenSatan or hasBeatenSatan == 0 then
        TryRemoveItemFromPool(Constants.LOTS_CUP_ITEM)
    end

    --Gomorrah's Demise unlocked by beating The Lamb
    local hasBeatenLamb = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.LAMB]
    if not hasBeatenLamb or hasBeatenLamb == 0 then
        TryRemoveItemFromPool(Constants.GOMORRAHS_DEMISE_ITEM)
    end

    --Edith's scarf unlocked by beating Hush
    local hasBeatenHush = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.HUSH]
    if not hasBeatenHush or hasBeatenHush == 0 then
        TryRemoveItemFromPool(Constants.EDITHS_SCARF_ITEM)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LockedItemBlocker.OnGameStart)


---@param collectible EntityPickup
function LockedItemBlocker:OnPickupInit(collectible)
    --Salt baby unlocked by beating Isaac
    local hasBeatenIsaac = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.ISAAC]
    if (not hasBeatenIsaac or hasBeatenIsaac == 0) and collectible.SubType == Constants.SALT_BABY_ITEM then
        collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true)
    end

    --Sodom's rain unlocked by beating Blue Baby
    local hasBeatenBlueBaby = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.BLUE_BABY]
    if (not hasBeatenBlueBaby or hasBeatenBlueBaby == 0) and collectible.SubType == Constants.SODOMS_RAIN_ITEM then
        collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true)
    end

    --Lot's cup unlocked by beating Satan
    local hasBeatenSatan = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.SATAN]
    if (not hasBeatenSatan or hasBeatenSatan == 0) and collectible.SubType == Constants.LOTS_CUP_ITEM then
        collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true)
    end

    --Sodom's rain unlocked by beating The Lamb
    local hasBeatenLamb = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.LAMB]
    if (not hasBeatenLamb or hasBeatenLamb == 0) and collectible.SubType == Constants.GOMORRAHS_DEMISE_ITEM then
        collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true)
    end

    --Edith's scarf unlocked by beating Hush
    local hasBeatenHush = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.HUSH]
    if (not hasBeatenHush or hasBeatenHush == 0) and collectible.SubType == Constants.EDITHS_SCARF_ITEM then
        collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, true)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, LockedItemBlocker.OnPickupInit)