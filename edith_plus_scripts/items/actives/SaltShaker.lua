local Constants = require("edith_plus_scripts.Constants")
local SaltShaker = {}
local game = Game()

function SaltShaker:OnSaltShakerUse()
    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
EdithPlusMod:AddCallback(ModCallbacks.MC_USE_ITEM, SaltShaker.OnSaltShakerUse, Constants.SALT_SHAKER_ITEM)


---@param player EntityPlayer
function SaltShaker:OnPeffectUpdate(player)
    local effects = player:GetEffects()
    local numSaltShakerUses = effects:GetCollectibleEffectNum(Constants.SALT_SHAKER_ITEM)

    if numSaltShakerUses == 0 then return end

    local data = player:GetData()

    if not data.LastPlayerPositionSaltShaker then
        data.LastPlayerPositionSaltShaker = player.Position
        return
    end

    if player.Position:Distance(data.LastPlayerPositionSaltShaker) > Constants.MINIMUM_TRAVEL_DISTANCE then
        --This is the base direction
        local targetDirection = (player.Position - data.LastPlayerPositionSaltShaker):Normalized()
        --This is the direction the current position has to take to the player
        local currentDirection = (player.Position - data.LastPlayerPositionSaltShaker):Normalized()
        --This is the current position (duh)
        local currentPosition = data.LastPlayerPositionSaltShaker

        --We only spawn creep if the difference between the current direction and the base one is small (they're roughly the same)
        while targetDirection:Distance(currentDirection) < 0.1 do
            for _ = 1, numSaltShakerUses, 1 do
                local saltCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, currentPosition, Vector.Zero, player)
                saltCreep = saltCreep:ToEffect()

                local saltCreepSpr = saltCreep:GetSprite()
                saltCreepSpr:Load("gfx/1000.092_creep (powder).anm2", true)
                saltCreepSpr:PlayRandom(saltCreep.InitSeed)

                saltCreep.Timeout = Constants.SALT_CREEP_TIMEOUT
                saltCreep.SpriteScale = Vector(Constants.SALT_CREEP_SCALE, Constants.SALT_CREEP_SCALE)
                saltCreep.Color = Color(1, 1, 1, 1, 1, 1, 1)

                saltCreep.CollisionDamage = (player.Damage/10) * numSaltShakerUses

                saltCreep:GetData().IsEdithSaltCreep = true
            end

            currentPosition = currentPosition + currentDirection * Constants.SALT_CREEP_SEPARATION
            currentDirection = (player.Position - currentPosition):Normalized()
        end
    end

    data.LastPlayerPositionSaltShaker = player.Position
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SaltShaker.OnPeffectUpdate)


function SaltShaker:OnNewRoom()
    for i = 0, game:GetNumPlayers() - 1, 1 do
        local player = game:GetPlayer(i)

        player:GetData().LastPlayerPositionSaltShaker = nil
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SaltShaker.OnNewRoom)