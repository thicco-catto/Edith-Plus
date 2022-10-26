local EdithPlusMod, Constants = table.unpack(...)
local HigherChanceSodomGomorrahFirstDeal = {}
local game = Game()


function HigherChanceSodomGomorrahFirstDeal:OnNewRoom()
    local hasBeatenDelirium = EdithPlusMod.Persistent.Unlocks.EDITH[Constants.CompletionMark.DELIRIUM]
    if not hasBeatenDelirium or hasBeatenDelirium == 0 then return end

    local room = game:GetRoom()

    if room:GetType() ~= RoomType.ROOM_DEVIL then return end
    if EdithPlusMod.Data.HasVisitedDevilDeal then return end

    EdithPlusMod.Data.HasVisitedDevilDeal = true

    local replacements = {}

    --Sodom's rain unlocked by beating Blue Baby
    local hasBeatenBlueBaby = mod.Persistent.Unlocks.EDITH[Constants.CompletionMark.BLUE_BABY]
    if hasBeatenBlueBaby and hasBeatenBlueBaby > 0 then
        table.insert(replacements, Constants.SODOMS_RAIN_ITEM)
    end

    --Gomorrah's Demise unlocked by beating The Lamb
    local hasBeatenLamb = mod.Persistent.Unlocks.EDITH[Constants.CompletionMark.LAMB]
    if hasBeatenLamb and hasBeatenLamb > 0 then
        table.insert(replacements, Constants.GOMORRAHS_DEMISE_ITEM)
    end

    --If we haven't unlocked either sodom/gomorrah item
    if #replacements == 0 then return end

    local isThereSodomItem = #Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Constants.SODOMS_RAIN_ITEM) > 0
    local isThereGomorrahItem = #Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Constants.GOMORRAHS_DEMISE_ITEM) > 0

    --There's already a sodom/gomorrah item, don't replace
    if isThereSodomItem or isThereGomorrahItem then return end

    local rng = RNG()
    rng:SetSeed(game:GetSeeds():GetStartSeed(), 35)

    local collectiblesInRoom = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

    local lowQualityItems = {}
    local qualityTwoItems = {}

    for _, collectible in ipairs(collectiblesInRoom) do
        local itemConfig = Isaac.GetItemConfig()
        local collectibleConfig = itemConfig:GetCollectible(collectible.SubType)

        if collectibleConfig.Quality < 2 then
            table.insert(lowQualityItems)
        elseif collectibleConfig.Quality == 2 then
            table.insert(qualityTwoItems)
        end
    end

    local itemsThatCanBeReplaced = {}
    local chanceToReplace = 0

    if #lowQualityItems > 0 then
        itemsThatCanBeReplaced = lowQualityItems
        chanceToReplace = Constants.CHANCE_REPLACE_FIRST_DEAL_1
    elseif #qualityTwoItems > 0 then
        itemsThatCanBeReplaced = qualityTwoItems
        chanceToReplace = Constants.CHANCE_REPLACE_FIRST_DEAL_2
    end

    --There are no items to replace
    if #itemsThatCanBeReplaced == 0 then return end

    --We're replacing an item
    if rng:RandomInt(100) >= chanceToReplace then return end

    local collectibleToReplace = collectiblesInRoom[rng:RandomInt(#collectiblesInRoom) + 1]

    local replacement = replacements[rng:RandomInt(#replacements) + 1]

    collectibleToReplace = collectibleToReplace:ToPickup()
    collectibleToReplace:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, replacement, true, true, false)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, HigherChanceSodomGomorrahFirstDeal.OnNewRoom)