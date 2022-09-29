local EdithPlusMod, Constants = table.unpack(...)
local DoubleCreepDamage = {}


local function IsEntityADemon(entity)
    for _, entityTypeVariant in ipairs(Constants.DEVIL_ENEMIES) do
        if entity.Type == entityTypeVariant[1] and entity.Variant == entityTypeVariant[2] then
            return true
        end
    end

    return false
end


---@param tookDamage Entity 
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
function DoubleCreepDamage:OnEntityDamage(tookDamage, amount, flags, source, damageCountdown)
    --Needs to have killed megasatan for this
    local hasBeatenMegaSatan = mod.Persistent.Unlocks.EDITH[Constants.CompletionMark.MEGASATAN]
    if not hasBeatenMegaSatan then hasBeatenMegaSatan = 0 end
    if hasBeatenMegaSatan == 0 then return end

    local isDemon = IsEntityADemon(tookDamage)

    if not isDemon then return end

    if flags & DamageFlag.DAMAGE_ACID ~= DamageFlag.DAMAGE_ACID or  --Only care if its creep damage
    not source.Entity:GetData().IsEdithSaltCreep or                 --Only care if it has been done by our salt creep
    flags & DamageFlag.DAMAGE_TIMER == DamageFlag.DAMAGE_TIMER then --We use timer as a special flag as to not cause loops
        return
    end

    --Add the timer damage flag so we can check for it later and avoid loops
    tookDamage:TakeDamage(amount * 2, flags | DamageFlag.DAMAGE_TIMER, source, damageCountdown)

    return false
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DoubleCreepDamage.OnEntityDamage)