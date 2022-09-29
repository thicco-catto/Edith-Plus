local EdithPlusMod, Constants = table.unpack(...)
local CompletionMarks = {}


function CompletionMarks:GetCompletionTableForMarksAPI()
    local edithUnlocks = EdithPlusMod.Persistent.Unlocks.EDITH
    local marksForAPI = {}

    for _, mark in pairs(Constants.CompletionMark) do
        local difficultyCompleted = edithUnlocks[mark]
        if not difficultyCompleted then difficultyCompleted = 0 end

        marksForAPI[mark] = {Unlocked = difficultyCompleted > 0, HardMode = difficultyCompleted > 1}
    end

    return marksForAPI
end
PauseScreenCompletionMarksAPI:AddModCharacterCallback(Constants.NORMAL_EDITH_PLAYER, CompletionMarks.GetCompletionTableForMarksAPI)
