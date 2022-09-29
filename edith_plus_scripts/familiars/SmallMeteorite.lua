local EdithPlusMod, Constants = table.unpack(...)
local SmallMeteorite = {}
local game = Game()


---@param meteorite EntityFamiliar
function SmallMeteorite:OnMeteoriteInit(meteorite)
    local meteoriteSprite = meteorite:GetSprite()

    local rng = RNG()
    rng:SetSeed(meteorite.InitSeed, 35)

    local startingHeight = Constants.SMALL_METEORITE_STARTING_HEIGHT_BASE + rng:RandomInt(Constants.SMALL_METEORITE_STARTING_HEIGHT_RANDOM)

    ---@diagnostic disable-next-line: assign-type-mismatch
    meteoriteSprite.Offset = Constants.SMALL_METEORITE_FALLING_DIRECTION * -startingHeight
end
EdithPlusMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SmallMeteorite.OnMeteoriteInit, Constants.SMALL_METEORITE_FAMILIAR)
EdithPlusMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, SmallMeteorite.OnMeteoriteInit, Constants.BIG_METEORITE_FAMILIAR)


---@param meteorite EntityFamiliar
local function ExplodeSmallMeteorite(meteorite)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, meteorite.Position, Vector.Zero, nil)
    local player = meteorite.Player

    local enemiesInRadius = Isaac.FindInRadius(meteorite.Position, Constants.SMALL_METEORITE_RADIUS, EntityPartition.ENEMY)

    for _, enemy in ipairs(enemiesInRadius) do
        if enemy:IsVulnerableEnemy() then
            enemy:TakeDamage(player.Damage * Constants.SMALL_METEORITE_DAMAGE, DamageFlag.DAMAGE_FIRE | DamageFlag.DAMAGE_EXPLOSION, EntityRef(meteorite), 1)
            enemy:AddBurn(EntityRef(meteorite), Constants.SMALL_METEORITE_BURN_DURATION, player.Damage * Constants.SMALL_METEORITE_BURN_DAMAGE)
        end
    end

    meteorite:Remove()
end


---@param meteorite EntityFamiliar
local function ExplodeBigMeteorite(meteorite)
    Isaac.Explode(meteorite.Position, meteorite, Constants.BIG_METEORITE_EXPLOSION_DAMAGE)
    game:ShakeScreen(10)

    local enemiesInRadius = Isaac.FindInRadius(meteorite.Position, Constants.SMALL_METEORITE_RADIUS, EntityPartition.ENEMY)

    for _, enemy in ipairs(enemiesInRadius) do
        if enemy:IsVulnerableEnemy() then
            enemy:AddBurn(EntityRef(meteorite), Constants.BIG_METEORITE_BURN_DURATION, meteorite.Player.Damage * Constants.BIG_METEORITE_BURN_DAMAGE)
        end
    end

    meteorite:Remove()
end


---@param meteorite EntityFamiliar
function SmallMeteorite:OnMeteoriteUpdate(meteorite)
    local meteoriteSprite = meteorite:GetSprite()

    if meteoriteSprite.Offset.Y >= 0 then
        if meteorite.Variant == Constants.SMALL_METEORITE_FAMILIAR then
            ExplodeSmallMeteorite(meteorite)
        else
            ExplodeBigMeteorite(meteorite)
        end

        return
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    meteoriteSprite.Offset = meteoriteSprite.Offset + Constants.SMALL_METEORITE_FALLING_DIRECTION * Constants.SMALL_METEORITE_FALLING_SPEED

    if meteoriteSprite.Offset.Y >= 0 then
        meteoriteSprite.Offset = Vector(0, 0)
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SmallMeteorite.OnMeteoriteUpdate, Constants.SMALL_METEORITE_FAMILIAR)
EdithPlusMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SmallMeteorite.OnMeteoriteUpdate, Constants.BIG_METEORITE_FAMILIAR)


function SmallMeteorite:OnNewRoom()
    --Remove all meteorites so they dont follow isaac to the next room
    for _, meteorite in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, Constants.SMALL_METEORITE_FAMILIAR)) do
        meteorite:Remove()
    end

    for _, meteorite in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, Constants.BIG_METEORITE_FAMILIAR)) do
        meteorite:Remove()
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SmallMeteorite.OnNewRoom)