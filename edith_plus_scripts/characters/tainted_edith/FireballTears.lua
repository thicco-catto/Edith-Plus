local Constants = require "edith_plus_scripts.Constants"
local FireballTears = {}


---@param tear EntityTear
function FireballTears:OnTearInitLate(tear)
    if tear.FrameCount ~= 0 then return end
    if not tear.SpawnerEntity then return end
    if tear.SpawnerType ~= EntityType.ENTITY_PLAYER then return end

    local player = tear.SpawnerEntity:ToPlayer()

    if player:GetPlayerType() ~= Constants.TAINTED_EDITH_PLAYER then return end

    tear:ChangeVariant(TearVariant.FIRE_MIND)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, FireballTears.OnTearInitLate)