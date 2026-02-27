-- Script ESP Trái Ác Quỷ & Auto Farm cho Blox Fruits (Delta Executor)
--soi làm gì--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Biến toggle
local ESP_Enabled = false
local AutoFarm_Enabled = false

-- [[ HÀM ESP ]] --
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
    text.Color = Color3.fromRGB(255, 255, 255)
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if ESP_Enabled and fruit and fruit:FindFirstChild("Handle") and fruit.Handle.Position then
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

RunService.Heartbeat:Connect(function()
    if ESP_Enabled then
        UpdateESP()
    end
end)

-- [[ HÀM AUTO FARM ]] --
local function GetClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    
    if Workspace:FindFirstChild("Enemies") then
        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    closestEnemy = enemy
                    shortestDistance = distance
                end
            end
        end
    end
    return closestEnemy
end

RunService.Heartbeat:Connect(function()
    if AutoFarm_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local enemy = GetClosestEnemy()
        if enemy then
            -- Teleport đến quái
            LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            
            -- Tấn công
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
        end
    end
end)

-- [[ TẠO MENU ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "v1" -- Tên UI

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 160, 0, 140) -- Tăng chiều cao để chứa nút farm
Frame.Position = UDim2.new(0.5, -80, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "X-Script V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Nút ESP
local ToggleESP = Instance.new("TextButton")
ToggleESP.Size = UDim2.new(0.9, 0, 0, 30)
ToggleESP.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleESP.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleESP.Text = "Bật ESP Trái"
ToggleESP.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleESP.Parent = Frame

-- Nút Farm
local ToggleFarm = Instance.new("TextButton")
ToggleFarm.Size = UDim2.new(0.9, 0, 0, 30)
ToggleFarm.Position = UDim2.new(0.05, 0, 0.52, 0)
ToggleFarm.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleFarm.Text = "Bật Auto Farm"
ToggleFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleFarm.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = Frame

-- [[ LOGIC NÚT BẤM ]] --

ToggleESP.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    ToggleESP.Text = ESP_Enabled and "Tắt ESP Trái" or "Bật ESP Trái"
    ToggleESP.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(100, 100, 100)
    UpdateESP()
end)

ToggleFarm.MouseButton1Click:Connect(function()
    AutoFarm_Enabled = not AutoFarm_Enabled
    ToggleFarm.Text = AutoFarm_Enabled and "Tắt Farm" or "Bật Auto Farm"
    ToggleFarm.BackgroundColor3 = AutoFarm_Enabled and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(100, 100, 100)
end)

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- Hotkey 'M'
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        Frame.Visible = not Frame.Visible
    end
end)

print("X-Script V1 Loaded!")
