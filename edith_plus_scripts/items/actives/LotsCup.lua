local EdithPlusMod, Constants = table.unpack(...)
local LotsCup = {}
local game = Game()

local lastItemQueue = nil


local function PlayerHasLotsCup(player)
    if player:HasCollectible(Constants.LOTS_CUP_ITEM) then
        return true
    end

    for _, helperLotsCupId in ipairs(Constants.LOTS_CUP_HELPER_ITEMS) do
        if player:HasCollectible(helperLotsCupId) then
            return true
        end
    end

    return false
end


local function IsItemLotsCup(item)
    if item == Constants.LOTS_CUP_ITEM then
        return true
    end

    for _, helperLotsCupId in ipairs(Constants.LOTS_CUP_HELPER_ITEMS) do
        if item == helperLotsCupId then
            return true
        end
    end

    return false
end


local function GetChargeFromLotsCupId(lotsCupId)
    if lotsCupId == Constants.LOTS_CUP_ITEM then return 0 end

    for charge, helperLotsCupId in ipairs(Constants.LOTS_CUP_HELPER_ITEMS) do
        if lotsCupId == helperLotsCupId then
            return charge
        end
    end
end


local function GetRedHealthValue(heartSubType)
    if heartSubType == HeartSubType.HEART_FULL or heartSubType == HeartSubType.HEART_BLENDED or 
    heartSubType == HeartSubType.HEART_SCARED then
        return 2
    elseif heartSubType == HeartSubType.HEART_HALF then
        return 1
    elseif heartSubType == HeartSubType.HEART_DOUBLEPACK then
        return 4
    end
end


---@param heart EntityPickup
---@param player EntityPlayer
local function CalculateChargesGained(heart, player)
    local maxPossibleReadHearts = player:GetEffectiveMaxHearts()
    local currentOccupiedHearts = player:GetHearts() + player:GetRottenHearts() * 2
    local emptyRedHealth = maxPossibleReadHearts - currentOccupiedHearts

    local heartValue = GetRedHealthValue(heart.SubType)

    if heart.SubType == HeartSubType.HEART_BLENDED then
        --If it is a blended heart we also need to check if the player can instead take the blue hearts
        if player:CanPickSoulHearts() then
            return 0
        else
            return math.max(0, heartValue - emptyRedHealth)
        end
    else
        return math.max(0, heartValue - emptyRedHealth)
    end
end


local function AddLotsCupChargeToSlot(player, charge, activeSlot)
    local activeItem = player:GetActiveItem(activeSlot)

    if not IsItemLotsCup(activeItem) then return end

    local currentCharge = GetChargeFromLotsCupId(activeItem)
    local newCharge = currentCharge + charge
    newCharge = math.min(newCharge, Constants.LOTS_CUP_MAX_CHARGE)
    newCharge = math.max(newCharge, 0)

    local newLotsCupItem = Constants.LOTS_CUP_HELPER_ITEMS[newCharge]
    if newCharge == 0 then
        newLotsCupItem = Constants.LOTS_CUP_ITEM
    end

    if activeItem ~= newLotsCupItem then
        player:AddCollectible(newLotsCupItem, 0, false, activeSlot)
    end
end


---@param player EntityPlayer
---@param charge integer
local function AddLotsCupCharge(player, charge)
    for activeSlot = 0, 3, 1 do
        AddLotsCupChargeToSlot(player, charge, activeSlot)
    end
end


local function GetHighestLotsCupCharge(player)
    if not PlayerHasLotsCup(player) then return 0 end

    local highestCharge = 0

    for activeSlot = 0, 3, 1 do
        local activeItem = player:GetActiveItem(activeSlot)

        if IsItemLotsCup(activeItem) then
            local currentCharge = GetChargeFromLotsCupId(activeItem)

            if currentCharge > highestCharge then highestCharge = currentCharge end
        end
    end

    return highestCharge
end


---@param heart EntityPickup
---@param collider Entity
function LotsCup:OnHeartCollision(heart, collider)
    --We only care about hearts that give out red hearts
    if heart.SubType ~= HeartSubType.HEART_BLENDED and heart.SubType ~= HeartSubType.HEART_DOUBLEPACK and
    heart.SubType ~= HeartSubType.HEART_FULL and heart.SubType ~= HeartSubType.HEART_HALF and
    heart.SubType ~= HeartSubType.HEART_SCARED then return end

    --If the heart didnt collide with a player we dont care
    if not collider:ToPlayer() then return end
    local player = collider:ToPlayer()

    --If the player doesnt have lots cup bye bye
    if not PlayerHasLotsCup(player) then return end

    --Check if all the player has at least 1 Lot's Cup that isnt full
    local allAreLotsCupFullCharge = true
    for activeSlot = 0, 3, 1 do
        ---@cast activeSlot ActiveSlot
        local activeItem = player:GetActiveItem(activeSlot)
        if IsItemLotsCup(activeItem) and activeItem ~= Constants.LOTS_CUP_HELPER_ITEMS[Constants.LOTS_CUP_MAX_CHARGE] then
            allAreLotsCupFullCharge = false
            break
        end
    end

    if allAreLotsCupFullCharge then return end

    local chargeGained = 0

    if player:CanPickRedHearts() then
        --If we can pick up red health, calculate how much is extra health
        chargeGained = CalculateChargesGained(heart, player)
    elseif player:CanPickSoulHearts() and heart.SubType == HeartSubType.HEART_BLENDED then
        --If it is a blended soul and we take blue hearts, we gain 0 charges
        chargeGained = 0
    else
        --If we cant pick red or soul hearts, we get full charge no matter what
        chargeGained = GetRedHealthValue(heart.SubType)
    end

    local bloodyPoof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, 0, heart.Position, Vector.Zero, nil)
    --Scale the poof with how much charge we got, so it looks cool
    local spriteScale = 1 + chargeGained / 10
    bloodyPoof.SpriteScale = Vector(spriteScale, spriteScale)

    local heartUpEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, heart.Position - Vector(0, 20), Vector.Zero, nil)
    heartUpEffect.DepthOffset = 50

    SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)

    AddLotsCupCharge(player, chargeGained)

    heart:Remove()

    return true
end
EdithPlusMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, LotsCup.OnHeartCollision, PickupVariant.PICKUP_HEART)


---Code taken from ded's ez item name changer
---https://github.com/ddeeddii/ezitems-web
---@param player EntityPlayer
function LotsCup:RenameHelperItems(player)
    local currentItemQueue = player.QueuedItem.Item

    if currentItemQueue then
        for _, cupHelperId in ipairs(Constants.LOTS_CUP_HELPER_ITEMS) do
            if (currentItemQueue.ID == cupHelperId and currentItemQueue:IsCollectible() and lastItemQueue == nil) then
                game:GetHUD():ShowItemText(Constants.LOTS_CUP_NAME, Constants.LOTS_CUP_DESCRIPTION)
            end
        end
    end

    lastItemQueue = currentItemQueue
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LotsCup.RenameHelperItems)


function LotsCup:OnLotsCupUse(lotsCupId, rng, player, _, activeSlot)
    local currentCharge = GetChargeFromLotsCupId(lotsCupId)
    AddLotsCupChargeToSlot(player, - currentCharge, activeSlot)

    local chosenRandomStatIndex = rng:RandomInt(#Constants.LOTS_CUP_POSSIBLE_STATS)
    local chosenRandomStat = Constants.LOTS_CUP_POSSIBLE_STATS[chosenRandomStatIndex + 1]

    local playerData = EdithPlusMod.GetPlayerData(player)

    --If the stats list didnt exist, create it
    if not playerData.LotsCupStats then
        playerData.LotsCupStats = {}
    end

    --Find the damage and other stat tables in the stats we already have
    local lotsCupDamage
    local lotsCupOtherStat
    for _, lotsCupStat in ipairs(playerData.LotsCupStats) do
        if lotsCupStat.cacheFlag == CacheFlag.CACHE_DAMAGE then
            lotsCupDamage = lotsCupStat
        elseif lotsCupStat.cacheFlag == chosenRandomStat then
            lotsCupOtherStat = lotsCupStat
        end
    end

    --Add the damage
    local damageToAdd = Constants.LOTS_CUP_STAT_MULTIPLIER[CacheFlag.CACHE_DAMAGE] * currentCharge
    if not lotsCupDamage then
        --If we didnt find the damage stat, create it
        table.insert(playerData.LotsCupStats, {
            cacheFlag = CacheFlag.CACHE_DAMAGE,
            value = damageToAdd
        })
    else
        lotsCupDamage.value = lotsCupDamage.value + damageToAdd
    end

    --Add the other stat
    --Add the damage
    local otherStatToAdd = Constants.LOTS_CUP_STAT_MULTIPLIER[chosenRandomStat] * currentCharge
    if not lotsCupOtherStat then
        --If we didnt find the other stat, create it
        table.insert(playerData.LotsCupStats, {
            cacheFlag = chosenRandomStat,
            value = otherStatToAdd
        })
    else
        lotsCupOtherStat.value = lotsCupOtherStat.value + damageToAdd
    end

    --Add the corresponding cache flags and evaluate
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | chosenRandomStat)
    player:EvaluateItems()

    return {
        Discharge = false,
        Remove = false,
        ShowAnim = true
    }
end
for _, helperLotsCupId in ipairs(Constants.LOTS_CUP_HELPER_ITEMS) do
    EdithPlusMod:AddCallback(ModCallbacks.MC_USE_ITEM, LotsCup.OnLotsCupUse, helperLotsCupId)
end


--From hybrid (the andromeda guy), found on the discord server
local function TearsUp(firedelay, val)
    local currentTears = 30 / (firedelay + 1)
    local newTears = currentTears + val
    return math.max((30 / newTears) - 1, -0.99)
end


---@param player EntityPlayer
---@param cacheFlag CacheFlag
function LotsCup:OnCacheUpdate(player, cacheFlag)
    local playerData = EdithPlusMod.GetPlayerData(player)

    if not playerData.LotsCupStats then return end

    for _, lotsCupStat in ipairs(playerData.LotsCupStats) do
        if cacheFlag == lotsCupStat.cacheFlag then
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                player.Damage = player.Damage + lotsCupStat.value
            elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
                player.MaxFireDelay = TearsUp(player.MaxFireDelay, lotsCupStat.value)
            elseif cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + lotsCupStat.value
            elseif cacheFlag == CacheFlag.CACHE_RANGE then
                player.TearRange = player.TearRange + lotsCupStat.value
            elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
                player.ShotSpeed = player.ShotSpeed + lotsCupStat.value
            elseif cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + lotsCupStat.value
            end
        end
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LotsCup.OnCacheUpdate)


function LotsCup:OnCreepUpdate(creep)
    if not creep:GetData().LotsCupTargetScale then return end
    if creep.SpriteScale.X >= creep:GetData().LotsCupTargetScale then return end

    local newScale = creep.SpriteScale.X + Constants.LOTS_CUP_CREEP_SIZE_SPEED
    newScale = math.min(newScale, creep:GetData().LotsCupTargetScale)

    creep.SpriteScale = Vector(newScale, newScale)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, LotsCup.OnCreepUpdate, EffectVariant.PLAYER_CREEP_RED)


local function SpawnSpilledCreep(player)
    local highestCharge = GetHighestLotsCupCharge(player)

    if highestCharge == 0 then return end

    --Spawn the creep
    local lotsCupCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, player.Position, Vector.Zero, player)
    lotsCupCreep = lotsCupCreep:ToEffect()

    lotsCupCreep:GetData().LotsCupTargetScale = 1 + 10 * Constants.LOTS_CUP_CREEP_SIZE_MULTIPLIER
    lotsCupCreep.Timeout = Constants.LOTS_CUP_CREEP_TIMEOUT
end


function LotsCup:OnPlayerDamage(tookDamage, _, flags)
    if flags & DamageFlag.DAMAGE_CURSED_DOOR == DamageFlag.DAMAGE_CURSED_DOOR or
    flags & DamageFlag.DAMAGE_DEVIL == DamageFlag.DAMAGE_DEVIL or
    flags & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE or
    flags & DamageFlag.DAMAGE_IV_BAG == DamageFlag.DAMAGE_IV_BAG or
    flags & DamageFlag.DAMAGE_NO_PENALTIES == DamageFlag.DAMAGE_NO_PENALTIES or
    flags & DamageFlag.DAMAGE_TIMER == DamageFlag.DAMAGE_TIMER then return end

    local player = tookDamage:ToPlayer()
    SpawnSpilledCreep(player)
    AddLotsCupCharge(player, -20)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LotsCup.OnPlayerDamage, EntityType.ENTITY_PLAYER)


function LotsCup:OnNewLevel()
    for i = 0, game:GetNumPlayers() - 1, 1 do
        local player = game:GetPlayer(i)
        SpawnSpilledCreep(player)
        AddLotsCupCharge(player, -20)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, LotsCup.OnNewLevel)