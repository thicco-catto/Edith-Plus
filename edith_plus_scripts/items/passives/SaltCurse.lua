local EdithPlusMod, Constants = table.unpack(...)
local SaltCurse = {}


function SaltCurse:PreNPCUpdate(npc)
    if not npc:GetData().HasEdithPlusSaltCurse then return end

    return true
end
EdithPlusMod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, SaltCurse.PreNPCUpdate)


function SaltCurse:OnNPCRender(npc)
    if not npc:GetData().HasEdithPlusSaltCurse then return end

    --Sometimes the no physics entity flag doesnt work (thanks game)
    npc.Velocity = Vector.Zero
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, SaltCurse.OnNPCRender)


---@param entity Entity
---@param source EntityRef
function SaltCurse:OnPlayerDamage(entity, _, flags, source)
    local player = entity:ToPlayer()
    if not player:HasCollectible(Constants.EDITHS_CURSE_ITEM) then return end

    local enemy = source.Entity

    if flags & DamageFlag.DAMAGE_LASER ~= 0 or not enemy:IsEnemy() or enemy:IsBoss() or not enemy:ToNPC() then return end

    if enemy:GetData().HasEdithPlusSaltCurse then return false end

    enemy = enemy:ToNPC()

    local chance = Constants.SALT_CURSE_INCREASED_CHANCE

    local heartContainers = math.ceil(player:GetSoulHearts() / 2)
    chance = chance - 10 * math.max(0, heartContainers - 2)

    if enemy:GetDropRNG():RandomInt(100) < chance then
        local newColor = Color(1, 1, 1, 1, 0.8, 0.5, 0.5)
        enemy.Color = newColor
        enemy.Velocity = Vector.Zero
        enemy:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK |
        EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE |
        EntityFlag.FLAG_NO_SPRITE_UPDATE | EntityFlag.FLAG_HIDE_HP_BAR |
        EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        enemy.CanShutDoors = false
        enemy:GetData().HasEdithPlusSaltCurse = true
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SaltCurse.OnPlayerDamage, EntityType.ENTITY_PLAYER)


---@param entity Entity
function SaltCurse:OnEntityDamage(entity, _, flags)
    if not entity:GetData().HasEdithPlusSaltCurse then return end

    if flags & DamageFlag.DAMAGE_EXPLOSION == 0 and flags & DamageFlag.DAMAGE_CRUSH == 0 then return false end

    local rng = entity:GetDropRNG()

    if rng:RandomInt(100) < Constants.SALT_CURSE_SOUL_HEART_CHANCE then
        for _ = 1, rng:RandomInt(2)+1, 1 do
            local velocity = Vector(rng:RandomFloat() * 8 + 4, 0):Rotated(rng:RandomInt(360))
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, entity.Position, velocity, nil)
        end
    end

    entity:Remove()
    SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)

    local minParticles = math.ceil(3 + entity.MaxHitPoints/2)
    local maxParticles = math.ceil(3 + entity.MaxHitPoints)
    local numParticles = math.random(minParticles, maxParticles)
    for _ = 1, numParticles, 1 do
        local velocity = Vector(3, 0)
        velocity = velocity:Rotated(math.random(0, 360))

        local rockParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, entity.Position, velocity, nil)
        rockParticle.DepthOffset = -20
        rockParticle.Color = Color(1, 0.8, 0.8, 1)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SaltCurse.OnEntityDamage)