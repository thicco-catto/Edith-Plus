-- Imports --

---@type string, string, function, AllCharacters, boolean
local modName, path, loadFile, characters, useCustomErrorChecker = table.unpack(...)

local Constants = loadFile("edith_plus_scripts/Constants")

-- Init --
mod = RegisterMod(modName, 1)
--SaveData by KingBobson
loadFile("edith_plus_scripts/SaveData")(mod)
-- CODE --
local config = Isaac.GetItemConfig()
local game = Game()
local pool = game:GetItemPool()
local game_started = false -- a hacky check for if the game is continued.
local is_continued = false -- a hacky check for if the game is continued.

-- Utility Functions

---Returns if the player is one of your characters, true if it is, false if not, nil if player doesn't exist.
---@param player EntityPlayer
---@return boolean | nil
local function IsChar(player)
    if (player == nil) then return nil end
    if characters:isChar(player) then return true end
    return false
end

---Gets all players that is one of your characters, returns a table of all players, or nil if none are
---@return table|nil
local function GetPlayers()
    local players = {}
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if (characters:isChar(player)) then
            table.insert(players, player)
        end
    end
    return #players > 0 and players or nil
end

-- Character Code

---@param _ any
---@param player EntityPlayer
---@param cache CacheFlag | BitSet128
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
    if not (IsChar(player)) then return end

    local playerStat = characters:getCharacterByVariant(player).stats

    if (cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage + playerStat.Damage
    end

    if (cache & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay + playerStat.Firedelay
    end

    if (cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed + playerStat.Shotspeed
    end

    if (cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange + playerStat.Range
    end

    if (cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed + playerStat.Speed
    end

    if (cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck + playerStat.Luck
    end

    if (cache & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING and
        playerStat.Flying) then player.CanFly = true end

    if (cache & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG) then
        ---@diagnostic disable-next-line: assign-type-mismatch
        player.TearFlags = player.TearFlags | playerStat.Tearflags
    end

    -- if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR) then
    --     player.TearColor = playerStat.Tearcolor
    -- end
end)

---applies the costume to the player
---@param CostumeName string
---@param player EntityPlayer
local function AddCostume(CostumeName, player) -- actually adds the costume.
    local cost = Isaac.GetCostumeIdByPath("gfx/characters/" .. CostumeName .. ".anm2")
    ---@diagnostic disable-next-line: param-type-mismatch
    if (cost ~= -1) then player:AddNullCostume(cost) end
end

---goes through each costume and applies it
---@param AppliedCostume table
---@param player EntityPlayer
local function AddCostumes(AppliedCostume, player) -- costume logic
    if #AppliedCostume == 0 then return end
    if (type(AppliedCostume) == "table") then
        for i = 1, #AppliedCostume do
            AddCostume(AppliedCostume[i], player)
        end
    end
end

---@param player? EntityPlayer
local function postPlayerInitLate(player)
    player = player or Isaac.GetPlayer()
    if not (IsChar(player)) then return end
    local statTable = characters:getCharacterByVariant(player)
    if statTable == nil then return end
    -- Costume
    AddCostumes(statTable.costume, player)

    local items = statTable.items
    if (#items > 0) then
        for i, v in ipairs(items) do
            player:AddCollectible(v[1])
            if (v[2]) then
                local ic = config:GetCollectible(v[1])
                player:RemoveCostume(ic)
            end
        end
        local charge = statTable.charge
        if (player:GetActiveItem() and charge ~= -1) then
            if (charge == true) then
                player:FullCharge()
            else
                player:SetActiveCharge(charge)
            end
        end
    end

    local trinket = statTable.trinket
    if (trinket) then player:AddTrinket(trinket, true) end

    if (statTable.PocketItem) then
        if statTable.isPill then
            player:SetPill(0, pool:ForceAddPillEffect(statTable.PocketItem))
        else
            player:SetCard(0, statTable.PocketItem)
        end
    end

    --Initialize tables
    if not mod.Persistent.Unlocks then
        mod.Persistent.Unlocks = {}
    end

    if not mod.Persistent.Unlocks.EDITH then
        mod.Persistent.Unlocks.EDITH = {}
    end

    --Extra soul heart
    --Need's to beat mother for this
    local hasBeatenMother = mod.Persistent.Unlocks.EDITH[Constants.CompletionMark.MOTHER]
    if not hasBeatenMother then hasBeatenMother = 0 end
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER and hasBeatenMother > 0 then
        player:AddSoulHearts(2)
    end

    --Trinket
    --Need's to beat greedier for this
    local hasBeatenGreed = mod.Persistent.Unlocks.EDITH[Constants.CompletionMark.GREED]
    if not hasBeatenGreed then hasBeatenGreed = 0 end
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER and hasBeatenGreed > 1 then
        player:AddTrinket(TrinketType.TRINKET_APPLE_OF_SODOM)
    end

    --Card
    --Needs to have killed mom's heart for this
    local hasBeatenBossRush = mod.Persistent.Unlocks.EDITH[Constants.CompletionMark.BOSS_RUSH]
    if not hasBeatenBossRush then hasBeatenBossRush = 0 end
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER and hasBeatenBossRush > 0 then
        player:SetCard(0, Card.CARD_MAGICIAN)
    end

    --Pocket active item
    if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER then
        player:SetPocketActiveItem(Constants.SALT_SHAKER_ITEM, ActiveSlot.SLOT_POCKET, false)
    end
end

---@param _ any
---@param Is_Continued boolean
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, Is_Continued)
    if (not Is_Continued) then
        is_continued = false
        postPlayerInitLate()
    end
    game_started = true
end)

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
    game_started = false
end)

---@param _ any
---@param player EntityPlayer
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    if (game_started == false) then return end
    if (not is_continued) then
        postPlayerInitLate(player)
    end
end)

--[[
    // ModCallbacks.MC_POST_PEFFECT_UPDATE (4)
// PlayerTypeCustom.FOO
export function fooPostPEffectUpdate(player: EntityPlayer): void {
  convertRedHeartContainersToBlackHearts(player);
  removeRedHearts(player);
}

function convertRedHeartContainersToBlackHearts(player: EntityPlayer) {
  const maxHearts = player.GetMaxHearts();
  if (maxHearts > 0) {
    player.AddMaxHearts(maxHearts * -1, false);
    player.AddBlackHearts(maxHearts);
  }
}

/**
 * We also have to check for normal red hearts, so that the player is not able to fill bone hearts
 * (by e.g. picking up a healing item like Breakfast).
 */
function removeRedHearts(player: EntityPlayer) {
  const hearts = player.GetHearts();
  if (hearts > 0) {
    player.AddHearts(hearts * -1);
  }
}

/**
 * ModCallbacks.MC_PRE_PICKUP_COLLISION (38)
 * PickupVariant.PICKUP_HEART (10)
 *
 * Even though this character can never have any red heart containers, it is still possible for
 * them to have a bone heart and then touch a red heart to fill the bone heart. If this happened,
 * code in the PostPEffectUpdate callback would immediately cause the red hearts to be removed, but
 * it would still erroneously delete the pickup. To work around this, prevent this character from
 * colliding with any red hearts.
 */
export function fooPrePickupCollisionHeart(
  pickup: EntityPickup,
  collider: Entity,
): boolean | undefined {
  if (!isRedHeart(pickup)) {
    return undefined;
  }

  const player = collider.ToPlayer();
  if (player === undefined) {
    return undefined;
  }

  const character = player.GetPlayerType();
  if (character !== PlayerTypeCustom.FOO) {
    return undefined;
  }

  return false;
}
]]

-- put your custom code here!

--Pause Screen Completion Marks API by Connor
loadFile("edith_plus_scripts/achievements/pause_screen_completion_marks_api")

--Shockwave API
local ShockwaveAPI = loadFile("edith_plus_scripts/ShockwaveAPI")

--Achievement stuff
loadFile("edith_plus_scripts/achievements/CompletionMarks", {mod, Constants})
local ShowAchievementPaper = loadFile("edith_plus_scripts/achievements/ShowAchievementPaper", {mod, Constants})
loadFile("edith_plus_scripts/achievements/AchievementTracker", {mod, Constants, ShowAchievementPaper})
loadFile("edith_plus_scripts/achievements/LockedItemBlocker", {mod, Constants})

--Normal edith scripts
loadFile("edith_plus_scripts/characters/normal_edith/OnlySoulHearts", {mod, Constants})
loadFile("edith_plus_scripts/characters/normal_edith/SpecialMovement", {mod, Constants, ShockwaveAPI})
loadFile("edith_plus_scripts/characters/normal_edith/InvisibleAnalogStick", {mod, Constants})
loadFile("edith_plus_scripts/characters/normal_edith/MiniMagneto", {mod, Constants})
loadFile("edith_plus_scripts/characters/normal_edith/CallusLikeInmunity", {mod, Constants})
loadFile("edith_plus_scripts/characters/normal_edith/DoubleCreepDamage", {mod, Constants})
loadFile("edith_plus_scripts/characters/normal_edith/HigherChanceSodomGomorrahFirstDeal", {mod, Constants})
loadFile("edith_plus_scripts/characters/normal_edith/BiggerTearSize", {mod, Constants})

--Items
loadFile("edith_plus_scripts/items/actives/SaltShaker", {mod, Constants})
loadFile("edith_plus_scripts/items/actives/GomorrahsDemise", {mod, Constants})
loadFile("edith_plus_scripts/items/actives/LotsCup", {mod, Constants})
loadFile("edith_plus_scripts/items/passives/SodomsRain", {mod, Constants})
loadFile("edith_plus_scripts/items/passives/SaltBabyItem", {mod, Constants})
loadFile("edith_plus_scripts/items/passives/EdithsScarf", {mod, Constants})

--Familiars
loadFile("edith_plus_scripts/familiars/SmallMeteorite", {mod, Constants})
loadFile("edith_plus_scripts/familiars/SaltBabyFamiliar", {mod, Constants})

::EndOfFile::
