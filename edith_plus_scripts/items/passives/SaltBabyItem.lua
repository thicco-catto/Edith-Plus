local EdithPlusMod, Constants = table.unpack(...)
local SaltBabyItem = {}
local game = Game()


---@param player EntityPlayer
function SaltBabyItem:OnFamiliarCache(player)
    local saltBabyItemCount = player:GetCollectibleNum(Constants.SALT_BABY_ITEM)
    local numBoxUses = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local numDeadSaltBabies = EdithPlusMod.GetPlayerData(player).DeadSaltBabies

    if not numDeadSaltBabies then
        numDeadSaltBabies = 0
    end

    local saltBabyFamiliarsNum = saltBabyItemCount + numBoxUses - numDeadSaltBabies

    saltBabyFamiliarsNum = math.max(saltBabyFamiliarsNum, 0)

    if saltBabyItemCount == 0 then
        saltBabyFamiliarsNum = 0
    end

    player:CheckFamiliar(Constants.SALT_BABY_FAMILIAR, saltBabyFamiliarsNum,
        player:GetCollectibleRNG(Constants.SALT_BABY_ITEM),
        Isaac.GetItemConfig():GetCollectible(Constants.SALT_BABY_ITEM))
end
EdithPlusMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SaltBabyItem.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)


---@param tookDamage Entity
function SaltBabyItem:OnPlayerDamage(tookDamage, _, flags)
    if flags & DamageFlag.DAMAGE_CURSED_DOOR == DamageFlag.DAMAGE_CURSED_DOOR or
    flags & DamageFlag.DAMAGE_DEVIL == DamageFlag.DAMAGE_DEVIL or
    flags & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE or
    flags & DamageFlag.DAMAGE_IV_BAG == DamageFlag.DAMAGE_IV_BAG or
    flags & DamageFlag.DAMAGE_NO_PENALTIES == DamageFlag.DAMAGE_NO_PENALTIES or
    flags & DamageFlag.DAMAGE_TIMER == DamageFlag.DAMAGE_TIMER then return end

    local player = tookDamage:ToPlayer()

    local playerIndex = player:GetCollectibleRNG(1):GetSeed()

    for _, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, Constants.SALT_BABY_FAMILIAR)) do
        familiar = familiar:ToFamiliar()

        local familiarPlayer = familiar.Player
        local familiarPlayerIndex = familiarPlayer:GetCollectibleRNG(1):GetSeed()

        if playerIndex == familiarPlayerIndex then
            local playerData = EdithPlusMod.GetPlayerData(player)

            if not playerData.DeadSaltBabies then
                playerData.DeadSaltBabies = 1
            else
                playerData.DeadSaltBabies = playerData.DeadSaltBabies + 1
            end

            local saltPoof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, nil)
            saltPoof.Color = Color(1, 1, 1, 0.7, 0.7, 0.7, 0.7)
        end
    end

    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    player:EvaluateItems()
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SaltBabyItem.OnPlayerDamage, EntityType.ENTITY_PLAYER)


function SaltBabyItem:OnNewRoom()
    for i = 0, game:GetNumPlayers() - 1, 1 do
        local player = game:GetPlayer(i)

        EdithPlusMod.GetPlayerData(player).DeadSaltBabies = nil

        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SaltBabyItem.OnNewRoom)