local EdithPlusMod, Constants = table.unpack(...)
local CallusLikeInmunity = {}

function CallusLikeInmunity:OnPlayerDamage(tookDamage, _, flags)
    --Needs to have killed the beast for this
    local hasBeatenBeast = mod.Persistent.Unlocks.EDITH[Constants.CompletionMark.BEAST]
    if not hasBeatenBeast then hasBeatenBeast = 0 end
    if hasBeatenBeast == 0 then return end

    local player = tookDamage:ToPlayer()

    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    if (flags & DamageFlag.DAMAGE_ACID == DamageFlag.DAMAGE_ACID or
    flags & DamageFlag.DAMAGE_SPIKES == DamageFlag.DAMAGE_SPIKES) and
    flags & DamageFlag.DAMAGE_NO_MODIFIERS ~= DamageFlag.DAMAGE_NO_MODIFIERS then
        return false
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallusLikeInmunity.OnPlayerDamage, EntityType.ENTITY_PLAYER)