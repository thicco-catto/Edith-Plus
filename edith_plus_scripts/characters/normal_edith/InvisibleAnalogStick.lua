local Constants = require("edith_plus_scripts.Constants")
local HiddenItemManager = require("edith_plus_scripts.HiddenItemManager")
local InvisibleAnalogStick = {}


---@param player EntityPlayer
function InvisibleAnalogStick:OnPeffectUpdate(player)
    HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ANALOG_STICK, 1)

    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ANALOG_STICK) <= 1 then
        player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK))
    end
end
EdithPlusMod:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    InvisibleAnalogStick.OnPeffectUpdate,
    Constants.NORMAL_EDITH_PLAYER
)


-- ---@param player EntityPlayer
-- local function SpawnInvisibleItemWisp(player)
--     local invisibleItemWisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_ANALOG_STICK, Vector(-200, -200))
--     invisibleItemWisp:GetData().EdithIsInvisibleItemWisp = true
--     invisibleItemWisp.Visible = false
--     invisibleItemWisp:RemoveFromOrbit()

--     invisibleItemWisp.Player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK))
-- end


-- ---@param player EntityPlayer
-- function InvisibleAnalogStick:OnPeffectUpdate(player)
--     if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
--         SpawnInvisibleItemWisp(player)
--     end
-- end
-- EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, InvisibleAnalogStick.OnPeffectUpdate, Constants.NORMAL_EDITH_PLAYER)


-- ---@param wisp EntityFamiliar
-- function InvisibleAnalogStick:OnWispUpdate(wisp)
--     if wisp.SubType ~= CollectibleType.COLLECTIBLE_ANALOG_STICK then return end

--     if not wisp:GetData().EdithIsInvisibleItemWisp then
--         local player = wisp.Player
--         local hasTrueAnalogStick = player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK, true)
--         local alreadyHasInvisibleWisp = false

--         local playerIndex = player:GetCollectibleRNG(1):GetSeed()

--         for _, otherWisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)) do
--             otherWisp = otherWisp:ToFamiliar()
--             local otherPlayerIndex = otherWisp.Player:GetCollectibleRNG(1):GetSeed()

--             if otherWisp:GetData().EdithIsInvisibleItemWisp and playerIndex == otherPlayerIndex then
--                 alreadyHasInvisibleWisp = true
--             end
--         end

--         if not hasTrueAnalogStick and not alreadyHasInvisibleWisp then
--             wisp:GetData().EdithIsInvisibleItemWisp = true

--             wisp.Visible = false
--             wisp:RemoveFromOrbit()
--             wisp.Position = Vector(-200, -200)

--             wisp.Player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK))
--         end

--         return
--     end

--     wisp.Visible = false
--     wisp:RemoveFromOrbit()
--     wisp.Position = Vector(-200, -200)
-- end
-- EdithPlusMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, InvisibleAnalogStick.OnWispUpdate, FamiliarVariant.ITEM_WISP)


-- function InvisibleAnalogStick:PreSacrificialAltarUse(_, _, player)
--     local playerIndex = player:GetCollectibleRNG(1):GetSeed()

--     for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)) do
--         wisp = wisp:ToFamiliar()
--         local otherPlayerIndex = wisp.Player:GetCollectibleRNG(1):GetSeed()

--         if wisp:GetData().EdithIsInvisibleItemWisp and playerIndex == otherPlayerIndex then
--             wisp:Remove()
--         end
--     end
-- end
-- EdithPlusMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, InvisibleAnalogStick.PreSacrificialAltarUse, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)