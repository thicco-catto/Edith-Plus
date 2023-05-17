local Constants = require("edith_plus_scripts.Constants")
local DoubleCreepDamage = {}


local function IsEntityADemon(entity)
    for _, entityTypeVariant in ipairs(Constants.DEVIL_ENEMIES) do
        if entity.Type == entityTypeVariant[1] and entity.Variant == entityTypeVariant[2] then
            return true
        end
    end

    return false
end


local avoidRecursion = false


---@param tookDamage Entity 
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
function DoubleCreepDamage:OnEntityDamage(tookDamage, amount, flags, source, damageCountdown)
    if avoidRecursion then return end

    local isDemon = IsEntityADemon(tookDamage)

    if not isDemon then return end

    if flags & DamageFlag.DAMAGE_ACID ~= DamageFlag.DAMAGE_ACID or  --Only care if its creep damage
    not source.Entity:GetData().IsEdithSaltCreep then               --Only care if it has been done by our salt creep
        return
    end

    avoidRecursion = true
    tookDamage:TakeDamage(amount * 2, flags, source, damageCountdown)
    avoidRecursion = false

    return false
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DoubleCreepDamage.OnEntityDamage)