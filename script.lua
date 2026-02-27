-- Tác giả: yutakjin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Biến toggle
local AutoFarm_Enabled = false
local ESP_Enabled = false

-- [[ BẢNG CẤU HÌNH LEVEL QUÁI ]] --
local MonsterLevelMap = {
    ["Bandit"] = 5,
    ["Monkey"] = 15,
    ["Gorilla"] = 25,
    ["Fishman Warrior"] = 50,
    ["Fishman Commando"] = 75,
    -- Thêm các quái khác vào đây...
}

-- [[ HÀM TÌM QUÁI TỐT NHẤT ]] --
local function GetBestEnemy()
    local bestEnemy = nil
    local currentLevel = LocalPlayer.Data.Level.Value
    local minLevelDiff = math.huge

    if Workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                local monsterName = enemy.Name
                local monsterLevel = MonsterLevelMap[monsterName]
                
                if monsterLevel and monsterLevel <= currentLevel then
                    local levelDiff = currentLevel - monsterLevel
                    if levelDiff < minLevelDiff then
                        minLevelDiff = levelDiff
                        bestEnemy = enemy
                    end
                end
            end
        end
    end
    return bestEnemy
end

-- [[ HÀM ESP TÌM TRÁI ]] --
local function FindDevilFruits()
    local fruits = {}
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
            table.insert(fruits, v)
        end
    end
    return fruits
end

local function CreateESP(fruit)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Size = 16
    text.Color = Color3.fromRGB(255, 255, 0) -- Màu vàng cho nổi bật
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if ESP_Enabled and fruit and fruit:FindFirstChild("Handle") then
            local pos, onScreen = Camera:WorldToViewportPoint(fruit.Handle.Position)
            if onScreen then
                text.Text = fruit.Name
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end)
    
    fruit.AncestryChanged:Connect(function()
        text:Remove()
        connection:Disconnect()
    end)
    
    return text
end

local ESPs = {}
local function UpdateESP()
    for _, esp in pairs(ESPs) do
        esp:Remove()
    end
    ESPs = {}
    
    if ESP_Enabled then
        local fruits = FindDevilFruits()
        for _, fruit in pairs(fruits) do
            table.insert(ESPs, CreateESP(fruit))
        end
    end
end

-- [[ LOGIC CHÍNH ]] --
RunService.Heartbeat:Connect(function()
    -- Logic Auto Farm
    if AutoFarm_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local enemy = GetBestEnemy()
        if enemy then
            LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.1)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end
    end
    
    -- Logic Update ESP
    if ESP_Enabled then
        UpdateESP()
    end
end)

-- [[ TẠO MENU UI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "YutakjinGui"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 160, 0, 150) -- Tăng kích thước menu
Frame.Position = UDim2.new(0.5, -80, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "Yutakjin Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Nút Auto Farm
local ToggleFarm = Instance.new("TextButton")
ToggleFarm.Size = UDim2.new(0.9, 0, 0, 30)
ToggleFarm.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleFarm.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
ToggleFarm.Text = "Bật Auto Farm"
ToggleFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFarm.Font = Enum.Font.GothamBold
ToggleFarm.Parent = Frame

-- Nút ESP
local ToggleESP = Instance.new("TextButton")
ToggleESP.Size = UDim2.new(0.9, 0, 0, 30)
ToggleESP.Position = UDim2.new(0.05, 0, 0.5, 0)
ToggleESP.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleESP.Text = "Bật ESP Trái"
ToggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleESP.Font = Enum.Font.GothamBold
ToggleESP.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = Frame

-- [[ LOGIC NÚT BẤM ]] --
ToggleFarm.MouseButton1Click:Connect(function()
    AutoFarm_Enabled = not AutoFarm_Enabled
    ToggleFarm.Text = AutoFarm_Enabled and "Tắt Farm" or "Bật Auto Farm"
    ToggleFarm.BackgroundColor3 = AutoFarm_Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 150, 100)
end)

ToggleESP.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    ToggleESP.Text = ESP_Enabled and "Tắt ESP Trái" or "Bật ESP Trái"
    ToggleESP.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(100, 100, 100)
    UpdateESP()
end)

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        Frame.Visible = not Frame.Visible
    end
end)

print("yutakjin Script Loaded!")
