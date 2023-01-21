local Constants = require("edith_plus_scripts.Constants")
local ShowAchievementPaper = require("edith_plus_scripts.achievements.ShowAchievementPaper")
local AchievementTracker = {}
local game = Game()

local ModUnlocks

-------------------------------------------------------------------
--Most of this code has been translated 
--from JSG's Completion Marks for modded characters
--https://steamcommunity.com/sharedfiles/filedetails/?id=2503022727
-------------------------------------------------------------------

local function InitializeUnlocksTable()
    if not EdithPlusMod.Persistent.Unlocks then
        EdithPlusMod.Persistent.Unlocks = {}
    end

    if not ModUnlocks then
        ModUnlocks = EdithPlusMod.Persistent.Unlocks
    end
end


local function CanRunUnlockAchievements()
    --Just try to spawn a greed donation machine
    local machine = Isaac.Spawn(EntityType.ENTITY_SLOT, 11, 0, Vector.Zero, Vector.Zero, nil)
    local achievementsEnabled = machine:Exists()
    machine:Remove()

    return achievementsEnabled
end


local function TryGrantAchievement(markType, markDifficulty)
    InitializeUnlocksTable()

    for i = 0, game:GetNumPlayers(), 1 do
        local player = game:GetPlayer(i)

        local unlocksTable
        local achievementGFXPrefix

        if player:GetPlayerType() == Constants.NORMAL_EDITH_PLAYER then
            if not ModUnlocks.EDITH then
                ModUnlocks.EDITH = {}
            end

            unlocksTable = ModUnlocks.EDITH
            achievementGFXPrefix = "edith"
        end

        if unlocksTable then
            local previousDifficulty = unlocksTable[markType]

            if not previousDifficulty or markDifficulty > previousDifficulty then
                local achievementGFX = "gfx/ui/achievements/" .. achievementGFXPrefix .. "_" .. markType .. ".png"
                ShowAchievementPaper:StartAchievement(achievementGFX)
                unlocksTable[markType] = markDifficulty
            end
        end
    end
end


function AchievementTracker:OnFrameUpdate()
    --TODO: Uncomment this check back
    --if not CanRunUnlockAchievements() then return end

    local room = game:GetRoom()

    if not room:IsClear() then return end

    local markDifficulty = 1
    if game.Difficulty == Difficulty.DIFFICULTY_HARD or game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
        markDifficulty = 2
    end

    local level = game:GetLevel()
    local stage = level:GetStage()
    local stageType = level:GetStageType()

    if room:GetType() == RoomType.ROOM_BOSS then
        if stage == LevelStage.STAGE4_1 and stageType ~= StageType.STAGETYPE_REPENTANCE and
        level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == LevelCurse.CURSE_OF_LABYRINTH then
            --We are in womb 1 XL
            local isThereAnyDoorToNormalRoom = false

            for doorSlot = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
                ---@cast doorSlot DoorSlot
                local door = room:GetDoor(doorSlot)

                if door and door.TargetRoomType == RoomType.ROOM_DEFAULT and
                door.TargetRoomIndex > 0 then
                    isThereAnyDoorToNormalRoom = true
                end
            end

            if not isThereAnyDoorToNormalRoom then
                --We are in the last boss room
                TryGrantAchievement(Constants.CompletionMark.HEART, markDifficulty)
            end
        elseif stage == LevelStage.STAGE4_2 and stageType ~= StageType.STAGETYPE_REPENTANCE then
            --We are in womb 2
            TryGrantAchievement(Constants.CompletionMark.HEART, markDifficulty)
        elseif stage == LevelStage.STAGE4_3 then
            --We are in the blue womb
            TryGrantAchievement(Constants.CompletionMark.HUSH, markDifficulty)
        elseif stage == LevelStage.STAGE5 then
            --We are in sheol / cathedral
            if stageType == StageType.STAGETYPE_WOTL then
                --We are in cathedral
                TryGrantAchievement(Constants.CompletionMark.ISAAC, markDifficulty)
            else
                --We are in the sheol
                TryGrantAchievement(Constants.CompletionMark.SATAN, markDifficulty)
            end
        elseif stage == LevelStage.STAGE6 then
            --We are in dark room / chest
            if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 then
                --We are in mega satan's room
                TryGrantAchievement(Constants.CompletionMark.MEGA_SATAN, markDifficulty)
            else
                if stageType == StageType.STAGETYPE_WOTL then
                    --We are in the the chest
                    TryGrantAchievement(Constants.CompletionMark.BLUE_BABY, markDifficulty)
                else
                    --We are in the dark room
                    TryGrantAchievement(Constants.CompletionMark.LAMB, markDifficulty)
                end
            end
        elseif stage == LevelStage.STAGE7 and room:GetRoomShape() == RoomShape.ROOMSHAPE_2x2 then
            --We are in the void and Delirium's room
            TryGrantAchievement(Constants.CompletionMark.DELIRIUM, markDifficulty)
        elseif stage == LevelStage.STAGE7_GREED and room:GetRoomShape() == RoomShape.ROOMSHAPE_1x2 then
            --We are in the last stage of greed and in ultra greed's room
            TryGrantAchievement(Constants.CompletionMark.GREED, markDifficulty)
        end
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_UPDATE, AchievementTracker.OnFrameUpdate)


function AchievementTracker:OnMotherRender()
    local room = game:GetRoom()

    if not room:IsClear() then return end

    local markDifficulty = 1
    if game.Difficulty == Difficulty.DIFFICULTY_HARD or game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
        markDifficulty = 2
    end

    TryGrantAchievement(Constants.CompletionMark.MOTHER, markDifficulty)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, AchievementTracker.OnMotherRender, EntityType.ENTITY_MOTHER)


function AchievementTracker:OnBeastRender()
    local room = game:GetRoom()

    if not room:IsClear() then return end

    local markDifficulty = 1
    if game.Difficulty == Difficulty.DIFFICULTY_HARD or game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
        markDifficulty = 2
    end

    TryGrantAchievement(Constants.CompletionMark.BEAST, markDifficulty)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, AchievementTracker.OnMotherRender, EntityType.ENTITY_BEAST)