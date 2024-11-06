addcmd("staffwatch", {}, function(args, speaker)
    if staffwatchjoin then
        staffwatchjoin:Disconnect()
    end
    if game.CreatorType == Enum.CreatorType.Group then
        local found = {}
        staffwatchjoin = Players.PlayerAdded:Connect(function(player)
            local result = getStaffRole(player)
            if result.Staff then
                notify("Staffwatch", formatUsername(player) .. " is a " .. result.Role)
            end
        end)
        for _, player in pairs(Players:GetPlayers()) do
            local result = getStaffRole(player)
            if result.Staff then
                table.insert(found, formatUsername(player) .. " is a " .. result.Role)
            end
        end
        if #found > 0 then
            notify("Staffwatch", table.concat(found, ",\n"))
        else
            notify("Staffwatch", "Enabled")
        end
    else
        notify("Staffwatch", "Game is not owned by a Group")
    end
end)
