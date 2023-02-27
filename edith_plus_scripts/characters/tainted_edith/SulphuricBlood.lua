local SulphuricBlood = {}
local Constants = require("edith_plus_scripts.Constants")


---@param player Entity
---@param source EntityRef
function SulphuricBlood:OnPlayerDamage(player, _, _, source)
    player = player:ToPlayer()
    if player:GetPlayerType() ~= Constants.TAINTED_EDITH_PLAYER then return end

    local enemy = source.Entity
    if not enemy then return end
    local npc = enemy:ToNPC()
    if not npc then
        local spawner = enemy.SpawnerEntity
        if not spawner then return end

        npc = spawner:ToNPC()
        if not npc then return end
    end

    local tear = Isaac.Spawn(
        EntityType.ENTITY_TEAR,
        TearVariant.BLUE,
        0,
        player.Position,
        (npc.Position - player.Position):Normalized() * 7,
        player
    )
    tear.Color = Color(1, 1, 0.455, 1, 0.169, 0.145, 0)
    local data = tear:GetData()
    data.EdithSulphuricBloodTear = true
    data.EdithSulphuricBloodTarget = npc
end
EdithPlusMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SulphuricBlood.OnPlayerDamage, EntityType.ENTITY_PLAYER)


---@param tear EntityTear
function SulphuricBlood:OnTearUpdate(tear)
    local data = tear:GetData()
    if not data.EdithSulphuricBloodTear then return end

    ---@type Entity
    local target = data.EdithSulphuricBloodTarget

    if not target:Exists() then return end

    local angle = tear.Velocity:GetAngleDegrees()
    local targetAngle = (target.Position - tear.Position):GetAngleDegrees()

    if angle == targetAngle then return end

    local rotation = targetAngle - angle

    if rotation < 0 then
        rotation = math.max(-10, rotation)
    else
        rotation = math.min(10, rotation)
    end

    tear.Velocity = tear.Velocity:Rotated(rotation)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, SulphuricBlood.OnTearUpdate)


---@param entity Entity
function SulphuricBlood:OnTearRemove(entity)
    local tear = entity:ToTear()

    local data = tear:GetData()
    if not data.EdithSulphuricBloodTear then return end

    local creep = Isaac.Spawn(
        EntityType.ENTITY_EFFECT,
        EffectVariant.PLAYER_CREEP_RED,
        0,
        tear.Position,
        Vector.Zero,
        tear.SpawnerEntity
    ):ToEffect()

    creep.Timeout = Constants.SULFURIC_CREEP_DURATION

    local newColor = Color(50, 50, 50)
    newColor:SetColorize(0.5, 0.5, 0, 1)
    creep.Color = newColor
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, SulphuricBlood.OnTearRemove, EntityType.ENTITY_TEAR)