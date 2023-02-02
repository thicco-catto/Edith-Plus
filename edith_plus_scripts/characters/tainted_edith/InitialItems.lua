local InitialItems = {}
local Constants = require("edith_plus_scripts.Constants")


---@param player EntityPlayer
function InitialItems:OnPlayerInit(player)
    if player:GetPlayerType() ~= Constants.TAINTED_EDITH_PLAYER then return end

    player:SetPocketActiveItem(Constants.STANDSTILL_ITEM, ActiveSlot.SLOT_POCKET)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, InitialItems.OnPlayerInit)