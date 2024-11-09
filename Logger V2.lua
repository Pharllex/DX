-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Player Info Functions
local function getPlayerInfo()
    local LocalPlayer = Players.LocalPlayer
    return {
        DisplayName = LocalPlayer.DisplayName,
        Username = LocalPlayer.Name,
        UserId = LocalPlayer.UserId,
        MembershipType = tostring(LocalPlayer.MembershipType):sub(21),
        AccountAge = LocalPlayer.AccountAge,
        Platform = (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) and "📱 Mobile" or "💻 PC",
    }
end

-- Device Info Functions (Simplified)
local function getDeviceInfo()
    return {
        IsUsingGamepad = UserInputService:IsGamepadConnected(1),  -- Gamepad connection status
        ScreenSize = Vector2.new(Camera.ViewportSize.X, Camera.ViewportSize.Y),  -- Screen size (width x height)
    }
end

-- Game Info Functions
local function getGameInfo()
    local gameInfo = {
        GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name,
        GameLink = "https://www.roblox.com/games/" .. game.PlaceId
    }
    return gameInfo
end

-- Data Display Function
local function displayData()
    local playerInfo = getPlayerInfo()
    local deviceInfo = getDeviceInfo()
    local gameInfo = getGameInfo()

    -- Print each category of data to the console for testing or debugging
    print("🎮 Game Information:", gameInfo)
    print("👤 Player Information:", playerInfo)
    print("📱 Device Info:", deviceInfo)
end

-- Execute
displayData()
