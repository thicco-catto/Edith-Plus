local SpecialMovement = {}
local Constants = require("edith_plus_scripts.Constants")

---@class PlayerMovingData
---@field movingDirection Vector?
---@field prevPosition Vector?

local PlayersMovingData = {}


---@param player EntityPlayer
---@return PlayerMovingData
local function GetPlayerMovingData(player)
    local playerIndex = player:GetCollectibleRNG(1):GetSeed()

    local data = PlayersMovingData[playerIndex]

    if data == nil then
        data = {}
        PlayersMovingData[playerIndex] = data
    end

    return data
end


function SpecialMovement:OnNewRoom()
    PlayersMovingData = {}
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SpecialMovement.OnNewRoom)


---@param entity Entity
---@param inputHook InputHook
---@param buttonAction ButtonAction
function SpecialMovement:OnInput(entity, inputHook, buttonAction)
    if not entity or not entity:ToPlayer() then return end
    local player = entity:ToPlayer()

    --And is our player
    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    if buttonAction == ButtonAction.ACTION_LEFT or buttonAction == ButtonAction.ACTION_RIGHT or
    buttonAction == ButtonAction.ACTION_UP or buttonAction == ButtonAction.ACTION_DOWN then
        --Negate movement inputs
        if inputHook == InputHook.GET_ACTION_VALUE then
            return 0.0
        else
            return false
        end
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, SpecialMovement.OnInput)


---@param player EntityPlayer
---@param playerMovingData PlayerMovingData
local function ForceMovePlayer(player, playerMovingData)
    player.Velocity = playerMovingData.movingDirection * Constants.BASE_TAINTED_SPEED * player.MoveSpeed

    if player:CollidesWithGrid() then
        Game():ShakeScreen(6)
        player.Velocity = player.Velocity/7
        playerMovingData.movingDirection = nil
    end

    if player.Position:Distance(playerMovingData.prevPosition) < 2 then
        playerMovingData.movingDirection = nil
        return
    end

    playerMovingData.prevPosition = player.Position
end


---@param player EntityPlayer
---@param playerMovingData PlayerMovingData
local function CheckForPlayerMovementInput(player, playerMovingData)
    local room = Game():GetRoom()
    if room:GetFrameCount() < 2 then return end

    local movementDir = player:GetMovementInput()

    --Random threshold
    if movementDir:LengthSquared() < 0.01 then return end

    playerMovingData.movingDirection = movementDir:Normalized()
    playerMovingData.prevPosition = player.Position
    player.Velocity = movementDir:Normalized() * Constants.BASE_TAINTED_SPEED * player.MoveSpeed
end


---@param player EntityPlayer
function SpecialMovement:OnPlayerUpdate(player)
    if player:GetPlayerType() ~= Constants.TAINTED_EDITH_PLAYER then return end

    local playerMovingData = GetPlayerMovingData(player)

    if playerMovingData.movingDirection then
        ForceMovePlayer(player, playerMovingData)
    else
        CheckForPlayerMovementInput(player, playerMovingData)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SpecialMovement.OnPlayerUpdate)


function SpecialMovement:OnStandstillUse(_, _, player)
    GetPlayerMovingData(player).movingDirection = nil
    player.Velocity = Vector.Zero

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
EdithPlusMod:AddCallback(ModCallbacks.MC_USE_ITEM, SpecialMovement.OnStandstillUse, Constants.STANDSTILL_ITEM)