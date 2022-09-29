local EdithPlusMod, Constants = table.unpack(...)
local ShowAchievementPaper = {}
local game = Game()

local achievementPaperSprite = Sprite()
achievementPaperSprite:Load("gfx/ui/edith_achievement.anm2", true)

function ShowAchievementPaper:StartAchievement(achievementGFX)
    EdithPlusMod.Data.IsPlayingAchievementAnimation = true
    achievementPaperSprite:ReplaceSpritesheet(0, achievementGFX)
    achievementPaperSprite:LoadGraphics()

    achievementPaperSprite:Play("Appear", true)
end


function ShowAchievementPaper:OnRender()
    if not EdithPlusMod.Data.IsPlayingAchievementAnimation then return end

    --achievementPaperSprite:Play("Idle")

    local centerScreenPos = Vector(
        Isaac.GetScreenWidth() / 2,
        Isaac.GetScreenHeight() / 2
    )

    achievementPaperSprite:Render(centerScreenPos)
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_RENDER, ShowAchievementPaper.OnRender)


function ShowAchievementPaper:OnFrameUpdate()
    if not EdithPlusMod.Data.IsPlayingAchievementAnimation then return end

    for i = 0, game:GetNumPlayers() - 1, 1 do
        local player = game:GetPlayer(i)

        player.ControlsEnabled = false
    end

    achievementPaperSprite:Update()

    if achievementPaperSprite:IsFinished("Appear") then
        achievementPaperSprite:Play("Idle", true)
    end

    if achievementPaperSprite:IsFinished("Idle") then
        achievementPaperSprite:Play("Dissapear", true)
    end

    if achievementPaperSprite:IsFinished("Dissapear") then
        EdithPlusMod.Data.IsPlayingAchievementAnimation = nil

        for i = 0, game:GetNumPlayers() - 1, 1 do
            local player = game:GetPlayer(i)

            player.ControlsEnabled = true
        end
    end
end
EdithPlusMod:AddCallback(ModCallbacks.MC_POST_UPDATE, ShowAchievementPaper.OnFrameUpdate)


return ShowAchievementPaper