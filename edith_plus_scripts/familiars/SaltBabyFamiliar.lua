local EdithPlusMod, Constants = table.unpack(...)
local SaltBabyFamiliar = {}
local game = Game()


---@param familiar EntityFamiliar
function SaltBabyFamiliar:OnFamiliarInit(familiar)
    familiar:AddToFollowers()
end
EdithPlusMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SaltBabyFamiliar.OnFamiliarInit, Constants.SALT_BABY_FAMILIAR)


local function SpawnCreep(familiar)
    if game:GetFrameCount() % 6 ~= 0 then return end

    local saltCreep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, familiar.Position, Vector.Zero, familiar)
    saltCreep = saltCreep:ToEffect()

    local saltCreepSpr = saltCreep:GetSprite()
    saltCreepSpr:Load("gfx/1000.092_creep (powder).anm2", true)
    saltCreepSpr:PlayRandom(saltCreep.InitSeed)

    saltCreep.Timeout = Constants.SALT_BABY_CREEP_TIMEOUT
    saltCreep.SpriteScale = Vector(Constants.SALT_BABY_CREEP_SCALE, Constants.SALT_BABY_CREEP_SCALE)
    saltCreep.Color = Color(1, 1, 1, 1, 1, 1, 1)
end


local function HandleShooting(familiar, player, sprite, fireDir)
    if fireDir ~= Direction.NO_DIRECTION then
        if familiar.FireCooldown > 0 then
            if familiar:GetData().ShootAnimFrames > 0 then
                familiar:GetData().ShootAnimFrames = familiar:GetData().ShootAnimFrames - 1
            else
                sprite:SetAnimation(Constants.FLOAT_ANIM_PER_DIRECTION[fireDir], false)
            end
        else
            --Set tear delay (half if the player has forgotten lullaby)
            familiar.FireCooldown = Constants.SALT_BABY_TEAR_RATE
            if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
                familiar.FireCooldown = math.max(1, math.ceil(familiar.FireCooldown / 2))
            end

            sprite:SetAnimation(Constants.SHOOT_ANIM_PER_DIRECTION[fireDir], false)
            familiar:GetData().ShootAnimFrames = 16

            local familiarTear = familiar:FireProjectile(Constants.DIRECTION_TO_VECTOR[fireDir])

            --Set color (make them purple if they have baby bender)
            if player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
                familiarTear.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)
            end

            --Set damage (double it if bff)
            familiarTear.CollisionDamage = player.Damage
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                familiarTear.CollisionDamage = familiarTear.CollisionDamage * 2
            end
        end
    else
        if familiar:GetData().ShootAnimFrames > 0 then
            familiar:GetData().ShootAnimFrames = familiar:GetData().ShootAnimFrames - 1
        else
            sprite:SetAnimation(Constants.FLOAT_ANIM_PER_DIRECTION[fireDir], false)
        end
    end
end


---@param familiar EntityFamiliar
function SaltBabyFamiliar:OnFamiliarUpdate(familiar)
    if not familiar:GetData().ShootAnimFrames then
        familiar:GetData().ShootAnimFrames = 0
    end

    familiar:FollowParent()

    local player = familiar.Player
	local fireDir = player:GetFireDirection()
    local sprite = familiar:GetSprite()


    if familiar.FireCooldown > 0 then
        familiar.FireCooldown = familiar.FireCooldown - 1
    end

    SpawnCreep(familiar)

    HandleShooting(familiar, player, sprite, fireDir)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SaltBabyFamiliar.OnFamiliarUpdate, Constants.SALT_BABY_FAMILIAR)