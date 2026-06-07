-- Chặn chạy trùng script
if getgenv().Quan then return end
getgenv().Quan = {}

local GameList = {
    [2440500124] = "Doors" -- Hãy chắc chắn đây là Universe ID nhé
}

local BaseUrl = "https://raw.githubusercontent.com/quan10101001-ux/ACRI-QUAN-HUB/refs/heads/main/"

-- Load Component an toàn bằng pcall để tránh một file sập làm sập cả script
local success, env = pcall(function() return loadstring(game:HttpGet(BaseUrl .. "Components/Environment.luau"))() end)
getgenv().Abysall = {
    Environment = success and env or {},
    ESPLibrary = loadstring(game:HttpGet(BaseUrl .. "Components/ESP.luau"))(),
}

-- Tối ưu hóa lấy Service an toàn cho Executor
local function CloneReference(Object)
    local envRef = Abysall.Environment.cloneref or cloneref
    if envRef then return envRef(Object) end
    return Object
end

local Services = setmetatable({}, {
    __index = function(self, Name)
        return CloneReference(game:GetService(Name))
    end
})

-- Ưu tiên lấy hàm từ Executor Global, nếu không có thì lấy từ Env custom
local _isfile = isfile or Abysall.Environment.isfile
local _writefile = writefile or Abysall.Environment.writefile
local _readfile = readfile or Abysall.Environment.readfile
local _makefolder = makefolder or Abysall.Environment.makefolder
local _isfolder = isfolder or Abysall.Environment.isfolder

-- Xử lý Data User trong thư mục workspace của Executor
if _writefile and _readfile then
    -- pcall giúp tránh crash nếu Executor bị lỗi ghi file do quyền hệ thống (Permission Lock)
    pcall(function()
        if _makefolder and _isfolder and not _isfolder("Quan") then
            _makefolder("Quan")
        end

        if not _isfile("Quan/UserData.json") then
            local Data = { TotalExecutions = 0, UILibrary = "Obsidian" }
            _writefile("Quan/UserData.json", Services.HttpService:JSONEncode(Data))
        end

        local UserData = _readfile("Quan/UserData.json")
        local Decoded = Services.HttpService:JSONDecode(UserData) or {}
        
        Decoded.TotalExecutions = (Decoded.TotalExecutions or 0) + 1
        Decoded.UILibrary = Decoded.UILibrary or "Obsidian"

        Abysall.TotalExecutions = Decoded.TotalExecutions
        Abysall.UILibrary = Decoded.UILibrary

        _writefile("Quan/UserData.json", Services.HttpService:JSONEncode(Decoded))
    end)
end

-- Load Giao diện & Analytics
Quan.Interface = loadstring(game:HttpGet(BaseUrl .. "Components/Interface.luau"))()
Quan.Analytics = loadstring(game:HttpGet(BaseUrl .. "Components/Analytics.luau"))()

-- Kiểm tra ID để load game script phù hợp
local CurrentGame = GameList[game.GameId] or GameList[game.PlaceId] -- Check cả 2 loại ID cho chắc
if CurrentGame then
    loadstring(game:HttpGet(BaseUrl .. "Games/" .. CurrentGame .. "/Loader.luau"))()
else
    loadstring(game:HttpGet(BaseUrl .. "Games/Universal/Loader.luau"))()
end
