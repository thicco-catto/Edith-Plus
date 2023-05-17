---@diagnostic disable: assign-type-mismatch
local Constants = require("edith_plus_scripts.Constants")
local MiniMagneto = {}


local function IsInPickupWhiteList(pickup)
    for _, pickupWhiteList in ipairs(Constants.MINI_MAGNETO_PICKUP_WHITELIST) do
        if pickupWhiteList.Variant == pickup.Variant and
        (pickupWhiteList.SubType == pickup.Subtype or pickupWhiteList.SubType == -1) then
            return true
        end
    end

    return false
end


function MiniMagneto:OnPeffectUpdate(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGNETO) then return end

    local closePickups = Isaac.FindInRadius(player.Position, Constants.MINI_MAGNETO_RADIUS, EntityPartition.PICKUP)

    for _, pickup in ipairs(closePickups) do
        if IsInPickupWhiteList(pickup) then
            local currentPickupDirection = pickup.Velocity:Normalized()
            local targetDirection = (player.Position - pickup.Position):Normalized()

            if currentPickupDirection:Distance(targetDirection) > 0.1 or
            (currentPickupDirection:Distance(targetDirection) <= 0.1 and pickup.Velocity:Length() < Constants.MINI_MAGNETO_PICKUP_SPEED) then
                --Different direction or not fast enough
                pickup.Velocity = pickup.Velocity + targetDirection * Constants.MINI_MAGENTO_PICKUP_ACCEL

                if currentPickupDirection:Distance(targetDirection) <= 0.1 and pickup.Velocity:Length() > Constants.MINI_MAGNETO_PICKUP_SPEED then
                    pickup.Velocity = pickup.Velocity:Resized(Constants.MINI_MAGNETO_PICKUP_SPEED)
                end
            end
        end
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MiniMagneto.OnPeffectUpdate, Constants.NORMAL_EDITH_PLAYER)
