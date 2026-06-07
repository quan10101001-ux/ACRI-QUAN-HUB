local function CloneReference(Object)
    if Quan.Environment.cloneref then
        return Quan.Environment.cloneref(Object)
    else
        return Object
    end
end

local Services = setmetatable({}, {
    __index = function(self, Name)
        return CloneReference(game:GetService(Name))
    end
})

if Quan.Environment.identifyexecutor and Quan.Environment.request then
    local Player = Services.Players.LocalPlayer
    local Data = {
        Account = Player.Name,
        Executor = Quan.Environment.identifyexecutor(),
        Executions = tonumber(Quan.TotalExecutions),
        GameName = Services.MarketplaceService:GetProductInfo(game.PlaceId).Name,
        PlaceId = tostring(game.PlaceId)
    }

    task.spawn(function()
        pcall(function()
            Quan.Environment.request({
                Url = "http://93.115.101.180:10577/send",
                Method = "POST",
                Headers = {
                    ["content-type"] = "application/json"
                },
                Body = Services.HttpService:JSONEncode(Data)
            })
        end)
    end)
end
