local EdithPlusMod, Constants, ShockwaveAPI = table.unpack(...)
local SpecialMovement = {}
local game = Game()

local SafetyRoomTransitionTimer = 0


---@param entity Entity
---@param inputHook InputHook
---@param buttonAction ButtonAction
function SpecialMovement:OnInput(entity, inputHook, buttonAction)
    --Only if the collider is a player
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
local function IsPlayerPressingMovingInputs(player)
    local controllerIndex = player.ControllerIndex

    return Input.IsActionPressed(ButtonAction.ACTION_LEFT, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_RIGHT, controllerIndex) or
    Input.IsActionPressed(ButtonAction.ACTION_UP, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_DOWN, controllerIndex)
end


---@param player EntityPlayer
local function CanPlayerTeleport(player)
    --Cant teleport if the controls are disabled
    if not player.ControlsEnabled then return false end

    --Cant teleport if they're dying
    if player:IsDead() then return false end

    return true
end


---@param player EntityPlayer
---@param targetPos Vector
local function TryTransitionThroughDoor(player, targetPos)
    if not CanPlayerTeleport(player) then return end
    if SafetyRoomTransitionTimer > 0 then return end

    local room = game:GetRoom()

    local doorToGoThrough = nil

    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
        ---@cast slot DoorSlot
        local door = room:GetDoor(slot)

        --Empty door slots return nil
        if door then
            if door.Position:Distance(targetPos) <= Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT then
                doorToGoThrough = door
            end
        end
    end

    if not doorToGoThrough then return end

    if not doorToGoThrough:IsOpen() then return end
    --If the player is too close, dont go through directly
    if doorToGoThrough.Position:Distance(player.Position) <= Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT then return end

    local level = game:GetLevel()
    local targetRoomIndex = doorToGoThrough.TargetRoomIndex

    level.LeaveDoor = -1
    game:StartRoomTransition(targetRoomIndex, doorToGoThrough.Direction, RoomTransitionAnim.WALK, player)

    SafetyRoomTransitionTimer = Constants.MAX_SAFETY_ROOM_TRANSITION_TIMER

    if doorToGoThrough.TargetRoomType == RoomType.ROOM_CURSE or room:GetType() == RoomType.ROOM_CURSE then
        player:TakeDamage(1, DamageFlag.DAMAGE_CURSED_DOOR | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
    end

    level.LeaveDoor = doorToGoThrough.Slot
end


local function TryUnlockDoorFromTarget(player, targetPos)
    if not CanPlayerTeleport(player) then return end
    if SafetyRoomTransitionTimer > 0 then return end

    local room = game:GetRoom()

    local doorToGoThrough = nil

    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
        ---@cast slot DoorSlot
        local door = room:GetDoor(slot)

        --Empty door slots return nil
        if door then
            if door.Position:Distance(targetPos) <= Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT then
                doorToGoThrough = door
            end
        end
    end

    if not doorToGoThrough then return end
    doorToGoThrough:TryUnlock(player, false)
end


---@param player EntityPlayer
local function TryMovePlayerThroughDoor(player, targetPos)
    if not CanPlayerTeleport(player) then return end
    if SafetyRoomTransitionTimer > 0 then return end

    local room = game:GetRoom()

    local doorToInteract = nil

    local posToCheckDistance = player.Position
    if targetPos then
        posToCheckDistance = targetPos
    end

    if room:GetType() == RoomType.ROOM_DUNGEON then
        local exitPosition = room:GetGridPosition(2)

        if exitPosition:Distance(posToCheckDistance) <= Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT then
            player.Velocity = Vector(0, -7)
        end

        local blackMarketPosition = room:GetGridPosition(74)

        if blackMarketPosition:Distance(posToCheckDistance) <= Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT then
            player.Velocity = Vector(7, 0)
        end
    end

    for slot = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
        ---@cast slot DoorSlot
        local door = room:GetDoor(slot)

        if door then
            if door.Position:Distance(posToCheckDistance) <= Constants.MAX_DISTANCE_TO_DOOR_TO_INTERACT then
                doorToInteract = door
            end
        end
    end

    if not doorToInteract then return end

    if doorToInteract:GetSprite():GetFilename() == "gfx/grid/door_downpour_mirror.anm2" then
        if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
            local pushDirection

            if doorToInteract.Slot == DoorSlot.RIGHT0 then
                pushDirection = Vector(1, 0)
            elseif doorToInteract.Slot == DoorSlot.LEFT0 then
                pushDirection = Vector(-1, 0)
            elseif doorToInteract.Slot == DoorSlot.UP0 then
                pushDirection = Vector(0, -1)
            elseif doorToInteract.Slot == DoorSlot.DOWN0 then
                pushDirection = Vector(0, 1)
            end

            player.Velocity = pushDirection * 5
        end

        return
    end

    if doorToInteract:IsLocked() then
        doorToInteract:TryUnlock(player, false)
    elseif doorToInteract:IsOpen() then
        local level = game:GetLevel()
        local targetRoomIndex = doorToInteract.TargetRoomIndex

        level.LeaveDoor = -1
        game:StartRoomTransition(targetRoomIndex, doorToInteract.Direction, RoomTransitionAnim.WALK, player)

        SafetyRoomTransitionTimer = Constants.MAX_SAFETY_ROOM_TRANSITION_TIMER

        if doorToInteract.TargetRoomType == RoomType.ROOM_CURSE or room:GetType() == RoomType.ROOM_CURSE then
            player:TakeDamage(1, DamageFlag.DAMAGE_CURSED_DOOR | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
        end

        level.LeaveDoor = doorToInteract.Slot
    end
end


local function GetSafePosition(pos)
    local room = game:GetRoom()
    local gridIndex = room:GetClampedGridIndex(pos)

    if room:GetGridCollision(gridIndex) ~= GridCollisionClass.COLLISION_NONE then
        local emptyGridPosition = room:FindFreeTilePosition(pos, 0)
        return emptyGridPosition
    end

    return pos
end


---@param player EntityPlayer
local function HandleEdithTeleport(player)
    local data = player:GetData()
    local sprite = player:GetSprite()

    if data.EdithTeleportTimer > 0 then
        data.EdithTeleportTimer = data.EdithTeleportTimer - 1

        if data.EdithTeleportTimer ~= 0 then return end

        --When the teleport timer counts to zero, actually teleport the player
        player.Position = data.EdithTeleportLocation

        sprite:Play("TeleportDown", true)
        sprite:SetFrame(13)

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            --Special shockwave effect for birthright
            local shockwaveParams = ShockwaveAPI.NewCustomShockwaveParams()
            shockwaveParams.DamagePlayers = false
            shockwaveParams.Damage = player.Damage * 2

            ShockwaveAPI.CreateShockwaveRing(player, player.Position, 40, shockwaveParams)
        end
    else
        if not sprite:IsPlaying("TeleportDown") then
            --When the player has finished the teleport down animation or is playing another one
            --Finish the teleport and try to find a door to interact with
            TryMovePlayerThroughDoor(player, _, true)

            data.EdithIsTeleporting = false
            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end
    end
end


---@param player EntityPlayer
function SpecialMovement:OnPlayerUpdate(player)
    if player:GetPlayerType() ~= Constants.NORMAL_EDITH_PLAYER then return end

    local data = player:GetData()

    if data.EdithIsTeleporting then
        HandleEdithTeleport(player)

        return
    end

    local isPlayerMoving = IsPlayerPressingMovingInputs(player)

    if data.EdithTargetEffect and not data.EdithTargetEffect:Exists() then
        --Remove the EdithTargetEffect field just in case it didnt get removed
        data.EdithTargetEffect = nil
    end

    if data.EdithTargetEffect and not isPlayerMoving then
        --There is a target and the player stopped pressing movements keys
        --Try teleporting
        local edithTarget = data.EdithTargetEffect

        if edithTarget.Position:Distance(player.Position) > Constants.MINIMUM_TRAVEL_DISTANCE then
            --Only teleport the player if the distance is greater than the minimum required
            player:PlayExtraAnimation("TeleportUp")
            player:GetSprite():SetFrame(6)

            player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

            if player:IsFlying() then
                data.EdithTeleportLocation = edithTarget.Position
            else
                data.EdithTeleportLocation = GetSafePosition(edithTarget.Position)
            end
            data.EdithTeleportTimer = 1 --Constants.MAX_FRAMES_TO_TP

            SFXManager():Play(SoundEffect.SOUND_HELL_PORTAL1)

            data.EdithIsTeleporting = true
        else
            --If we arent far away, still check for doors
            TryMovePlayerThroughDoor(player, edithTarget.Position)
        end

        --Remove the target regardless the teleport occurred or not
        edithTarget:Remove()
        data.EdithTargetEffect = nil
    elseif not data.EdithTargetEffect and isPlayerMoving and CanPlayerTeleport(player) then
        --There's not a target and the player is pressing movement keys
        --Spawn a target
        local edithTarget = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, player.Position, Vector.Zero, player)
        data.EdithTargetEffect = edithTarget
        edithTarget:GetData().IsEdithTargetEffect = true
        edithTarget.DepthOffset = -20

        edithTarget:GetSprite():Load("gfx/edith_target.anm2", true)
        edithTarget:GetSprite():Play("Idle", true)
        edithTarget:GetSprite().PlaybackSpeed = Constants.TARGET_SPRITE_PLAYBACK_SPEED
        edithTarget:GetSprite().Color = Color(1, 1, 1, 1, 1, 1, 1)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SpecialMovement.OnPlayerUpdate)


---@param target EntityEffect
function SpecialMovement:OnTargetUpdate(target)
    --Only care about our own targets
    if not target:GetData().IsEdithTargetEffect then return end

    local player = target.SpawnerEntity:ToPlayer()
    local controllerIndex = player.ControllerIndex

    --Get the inputs
    local baseXVelocity = Input.GetActionValue(ButtonAction.ACTION_RIGHT, controllerIndex) - Input.GetActionValue(ButtonAction.ACTION_LEFT, controllerIndex)
    local baseYVelocity = Input.GetActionValue(ButtonAction.ACTION_DOWN, controllerIndex) - Input.GetActionValue(ButtonAction.ACTION_UP, controllerIndex)

    local room = Game():GetRoom()
    if room:IsMirrorWorld() then
        baseXVelocity = -baseXVelocity
    end

    --Do this so if on controller and moving slightly, we dont normalize to length 1 vector
    local normalizeTarget = math.max(math.abs(baseXVelocity), math.abs(baseYVelocity))

    --Normalize the vector so it doesnt move faster on diagonals
    local baseVelocity = Vector(baseXVelocity, baseYVelocity)
    baseVelocity = baseVelocity:Normalized() * normalizeTarget

    target.Velocity = baseVelocity * Constants.TARGET_BASE_SPEED * player.MoveSpeed

    --Try to move the player through a door
    TryUnlockDoorFromTarget(player, target.Position)
    TryTransitionThroughDoor(player, target.Position)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, SpecialMovement.OnTargetUpdate, EffectVariant.TARGET)


function SpecialMovement:OnNewRoom()
    --Reset the players data so they dont accidentally teleport 
    for i = 0, game:GetNumPlayers(), 1 do
        local player = game:GetPlayer(i)
        local data = player:GetData()

        data.EdithTargetEffect = nil
        data.EdithIsTeleporting = false
        data.EdithTeleportTimer = 0
        data.EdithTeleportLocation = nil
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SpecialMovement.OnNewRoom)


function SpecialMovement:OnFrameUpdate()
    if SafetyRoomTransitionTimer <= 0 then return end

    SafetyRoomTransitionTimer = SafetyRoomTransitionTimer - 1
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_UPDATE, SpecialMovement.OnFrameUpdate)