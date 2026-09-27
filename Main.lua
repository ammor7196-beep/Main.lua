local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local httpRequest = (syn and syn.request) or (http and http.request) or request or HttpService.RequestAsync

local scriptName = "LowPlayerServerFinder"
local targetParent = player:FindFirstChild("PlayerGui")
pcall(function()
    targetParent = (typeof(gethui) == "function" and gethui()) or CoreGui 
end)

if targetParent:FindFirstChild(scriptName) then
    targetParent[scriptName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = scriptName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 90)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Low Player Server"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(0.9, 0, 0, 40)
HopBtn.Position = UDim2.new(0.05, 0, 0, 40)
HopBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Text = "Найти пустой сервер (1 чел)"
HopBtn.Font = Enum.Font.GothamSemibold
HopBtn.TextSize = 12
HopBtn.Parent = MainFrame
Instance.new("UICorner", HopBtn).CornerRadius = UDim.new(0, 6)

HopBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        HopBtn.Text = "Поиск сервера..."
        
        task.spawn(function()
            local success, result = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                local response = httpRequest({
                    Url = url,
                    Method = "GET"
                })
                if response and response.Body then
                    return HttpService:JSONDecode(response.Body)
                end
                return nil
            end)
            
            if success and result and result.data then
                local bestServerId = nil
                local minPlayers = 999
                
                -- Ищем сервер с наименьшим количеством игроков (но больше 0, чтобы не кидало в одиночку бесконечно)
                for _, server in ipairs(result.data) do
                    if server.playing > 0 and server.playing < server.maxPlayers and server.playing < minPlayers then
                        minPlayers = server.playing
                        bestServerId = server.id
                    end
                end
                
                if bestServerId then
                    HopBtn.Text = "Телепортация (" .. minPlayers .. " изи)..."
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServerId, player)
                else
                    HopBtn.Text = "Серверов не найдено"
                    task.wait(2)
                    HopBtn.Text = "Найти пустой сервер (1 чел)"
                end
            else
                -- Запасной вариант обычного хопа, если API заблокировано
                HopBtn.Text = "Случайный хоп..."
                TeleportService:Teleport(game.PlaceId, player)
            end
        end)
    end
end)
