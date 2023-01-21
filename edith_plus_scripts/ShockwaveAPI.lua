--------------------------------------------------------------------------------------------------------------------
--Taken from Stone Bombs https://steamcommunity.com/sharedfiles/filedetails/?id=2585716114&searchtext=stone+bombs
--Slightly modified so it doesnt create global functions and some other fixes
--
--Originally by KittenChilly (I think) and modified by Thicco Catto
--------------------------------------------------------------------------------------------------------------------

local ShockwaveAPIMod = RegisterMod("ShockwaveAPI", 1)
local SfxManager = SFXManager()
local game = Game()

local ShockwaveAPI = {}

-- ########################## --
-- ### Shockwave API v0.7  ## --
-- ########################## --


-----------------
--API FUNCTIONS--
-----------------

ShockwaveAPI.ShockwaveSoundMode = {
    NO_SOUND = 0,
    ON_CREATE = 1,
    LOOP = 2
}

function ShockwaveAPI.NewCustomShockwaveParams()
    return {
        Duration = 15,
        Size = 1,
        Damage = 10,
        DamageCooldown = -1,
        SelfDamage = false,
        DamagePlayers = true,
        DestroyGrid = true,
        Color = Color(1, 1, 1),
        SoundMode = ShockwaveAPI.ShockwaveSoundMode.ON_CREATE
    }
end


function ShockwaveAPI.CreateShockwave(source, position, customShockwaveParams)
    --Check if the position is in a wall or even outside the room
    local room = game:GetRoom()
    local gridIndex = room:GetClampedGridIndex(position)
    local gridEntity = room:GetGridEntity(gridIndex)

    local isOutside = gridIndex < 0 or gridIndex > room:GetGridSize()
    local isInForbiddenGrid = gridEntity and (
        gridEntity:GetType() == GridEntityType.GRID_WALL or
        gridEntity:GetType() == GridEntityType.GRID_DOOR or
        gridEntity:GetType() == GridEntityType.GRID_PIT or
        gridEntity:GetType() == GridEntityType.GRID_ROCKB or
        gridEntity:GetType() == GridEntityType.GRID_PILLAR)
    local cantDestroyRocks = not customShockwaveParams.DestroyGrid and room:GetGridCollision(gridIndex) ~= GridCollisionClass.COLLISION_NONE

    if isOutside or isInForbiddenGrid or cantDestroyRocks then
        return false
    end

    --Spawn shockwave
    local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, position, Vector.Zero, source)
    shockwave.Size = shockwave.Size * customShockwaveParams.Size
    shockwave.Parent = source
    local sprite = shockwave:GetSprite()
    sprite.Scale = Vector(customShockwaveParams.Size, customShockwaveParams.Size)
    sprite.Color = customShockwaveParams.Color

    local shockwaveData = shockwave:GetData()
    shockwaveData.CustomShockwaveParams = customShockwaveParams
    shockwaveData.CurrentDuration = customShockwaveParams.Duration
    shockwaveData.HitEntities = {}

    if customShockwaveParams.SoundMode ~= ShockwaveAPI.ShockwaveSoundMode.NO_SOUND then
        SfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.5, 2, false, 1)
    end

    return shockwave
end


function ShockwaveAPI.CreateShockwaveRing(source, center, radius, customShockwaveParams, direction, angleWidth, spacing)
    local shockwaves = {}

    --Default values
    if direction == nil then direction = Vector(0, -1) end
    direction:Normalized()
    if angleWidth == nil then angleWidth = 360 end
    angleWidth = math.min(angleWidth, 360) -- Cap it at 360 (why tf you want bigger than that)
    if spacing == nil then spacing = 35 * customShockwaveParams.Size end

    --Other set up
    local totalPerimeter = math.pi * 2 * radius
    local widthPerimeter = angleWidth * totalPerimeter / 360

    local numShockwaves = math.max(1, math.floor(widthPerimeter / spacing + 0.5))

    local angleOffset = angleWidth/numShockwaves
    local currentDirection = direction:Rotated(-angleWidth/2)

    for _ = 0, numShockwaves, 1 do
        local spawningOffset = currentDirection * radius
        local shockwave = ShockwaveAPI.CreateShockwave(source, center + spawningOffset, customShockwaveParams)
        if shockwave then
            table.insert(shockwaves, shockwave)
        end
        currentDirection = currentDirection:Rotated(angleOffset)
    end

    return shockwaves
end


-----------------------
--SHOCKWAVE BEHAIVOUR--
-----------------------

local function ShockwaveUpdateDamageCooldowns(shockwaveData)
    local updatedHitEntities = {}

    for enemySeed, currentCooldown in pairs(shockwaveData.HitEntities) do
        if currentCooldown > 0 then
            updatedHitEntities[enemySeed] = currentCooldown - 1
        elseif currentCooldown < 0 then
            updatedHitEntities[enemySeed] = currentCooldown
        end
    end

    shockwaveData.HitEntities = updatedHitEntities
end


local function ShockwaveCollideWithEntities(shockwave, shockwaveData, customShockwaveParams)
    local enemiesInRadius = Isaac.FindInRadius(shockwave.Position, 40, EntityPartition.ENEMY | EntityPartition.PLAYER)

    for _, enemy in ipairs(enemiesInRadius) do
        if enemy:IsVulnerableEnemy() or enemy.Type == EntityType.ENTITY_FIREPLACE or enemy:ToPlayer() then
            local shockwaveParentSeed = shockwave.Parent.InitSeed
            local enemySeed = enemy.InitSeed

            if (customShockwaveParams.SelfDamage or shockwaveParentSeed ~= enemySeed) and --Check for self damage
            (customShockwaveParams.DamagePlayers or not enemy:ToPlayer()) and
            (not shockwaveData.HitEntities[enemySeed]) and --Check if we already hit this entity
            (enemy.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and --Check if the enemy isnt supposed to collide
            enemy.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_PLAYERONLY) then --Same
                shockwaveData.HitEntities[enemySeed] = customShockwaveParams.DamageCooldown

                if enemy:ToPlayer() then
                    enemy:TakeDamage(1, DamageFlag.DAMAGE_CRUSH, EntityRef(shockwave), 0)
                else
                    enemy:TakeDamage(customShockwaveParams.Damage, DamageFlag.DAMAGE_CRUSH, EntityRef(shockwave), 0)
                end
            end
        end
    end
end


local function ShockwaveDestroyGrid(shockwave, customShockwaveParams)
    if not customShockwaveParams.DestroyGrid then return end

    local room = game:GetRoom()

    for gridIndex = 0, room:GetGridSize() do
        local gridEntity = room:GetGridEntity(gridIndex)

        if gridEntity then
            if gridEntity.Position:Distance(shockwave.Position) <= 40 then
                local gridEntityType = gridEntity:GetType()

                if gridEntityType == GridEntityType.GRID_ROCK_BOMB or gridEntityType == GridEntityType.GRID_TNT then
                    gridEntity:Destroy(false)
                else
                    room:DestroyGrid(gridIndex, true)
                end
            end
        end
    end
end


local function ShockwaveUpdateAnimation(shockwave, shockwaveData, customShockwaveParams)
    local shockwaveSprite = shockwave:GetSprite()

    if shockwaveData.CurrentDuration <= 0 then
        shockwaveSprite:SetLastFrame()
        return
    end

    shockwaveData.CurrentDuration = shockwaveData.CurrentDuration - 1
    local currentFrame = shockwaveSprite:GetFrame()

    if currentFrame < 6 then return end

    if shockwaveData.CurrentDuration > (10 + currentFrame) then
        shockwaveSprite:Play("Break", true)
        shockwaveSprite:SetLayerFrame(0, 3)

        if customShockwaveParams.SoundMode == ShockwaveAPI.ShockwaveSoundMode.LOOP and
        shockwaveSprite.Duration % 2 == 0 then
            SfxManager:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.5, 1, false, 1)
        end
    elseif shockwaveData.CurrentDuration < (16 - currentFrame) then
        local frameDifference = 16 - currentFrame - shockwaveData.CurrentDuration
        shockwaveSprite:SetLayerFrame(0, currentFrame + frameDifference)
    end
end


function ShockwaveAPIMod:OnShockwaveUpdate(shockwave)
    local shockwaveData = shockwave:GetData()
    local customShockwaveParams = shockwaveData.CustomShockwaveParams

    --If it doesnt have custom shockwave params, its not our shockwave
    if not customShockwaveParams then return end

    ShockwaveUpdateDamageCooldowns(shockwaveData)

    ShockwaveCollideWithEntities(shockwave, shockwaveData, customShockwaveParams)

    ShockwaveDestroyGrid(shockwave, customShockwaveParams)

    ShockwaveUpdateAnimation(shockwave, shockwaveData, customShockwaveParams)
end
ShockwaveAPIMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ShockwaveAPIMod.OnShockwaveUpdate, EffectVariant.ROCK_EXPLOSION)


return ShockwaveAPI