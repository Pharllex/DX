getStaffRole = function(player)
    local playerRole = player:GetRoleInGroup(game.CreatorId)
    local result = {Role = playerRole, Staff = false}
    if player:IsInGroup(1200769) then
        result.Role = "Roblox Employee"
        result.Staff = true
    end
    for _, role in pairs(staffRoles) do
        if string.find(string.lower(playerRole), role) then
            result.Staff = true
        end
    end
    return result
end
