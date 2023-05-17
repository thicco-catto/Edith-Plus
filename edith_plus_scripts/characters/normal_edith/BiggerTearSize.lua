local Constants = require("edith_plus_scripts.Constants")
local BiggerTearSize = {}


---@param tear EntityTear
function BiggerTearSize:OnTearFire(tear)
    if not tear.SpawnerEntity then return end
    local player = tear.SpawnerEntity:ToPlayer()
    if not player then return end
    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    tear.Scale = tear.Scale + Constants.EDITH_TEAR_SCALE
    tear:ResetSpriteScale()
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, BiggerTearSize.OnTearFire)