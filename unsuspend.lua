print("Attempting to unsuspend")
if typeof(onVoiceModerated) ~= "RBXScriptConnection" then
        onVoiceModerated = cloneref(game:GetService("VoiceChatInternal")).LocalPlayerModerated:Connect(function()
        task.wait(1)
        VoiceChatService:joinVoice()
    end)
end
