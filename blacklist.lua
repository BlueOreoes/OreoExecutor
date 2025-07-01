-- Table of usernames to check against
local blacklist = {
    "DenisDaily",
    "hugeguy5me",
    "Enathri",
    "hugeguy5me",
    "MatthewAlt20325",
}

-- Function to check if a name is in the blacklist
local function isBlacklisted(name)
    for _, bannedName in pairs(blacklist) do
        if name:lower() == bannedName:lower() then
            return true
        end
    end
    return false
end

-- Hook onto PlayerAdded
game.Players.PlayerAdded:Connect(function(player)
    if isBlacklisted(player.Name) then
        warn("Blacklisted user detected: " .. player.Name .. " - Leaving game.")
        game:Shutdown() -- Only works in Studio. Use game:Kick() on yourself for live servers.
        game.Players.LocalPlayer:Kick("Blacklisted user detected.")
    end
end)

-- Also check existing players just in case
for _, player in pairs(game.Players:GetPlayers()) do
    if isBlacklisted(player.Name) then
        warn("Blacklisted user detected: " .. player.Name .. " - Leaving game.")
        game.Players.LocalPlayer:Kick("Blacklisted user detected.")
    end
end
