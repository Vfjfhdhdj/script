-- Simple Plain Lua Auto Farm Blox Fruits - No Encode - Delta X OK 2026
-- Farm quái theo level/sea, ESP, draggable bubble
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF_ = ReplicatedStorage.Remotes.CommF_

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Draggable Bubble
local Bubble = Instance.new("TextButton")
Bubble.Size = UDim2.new(0, 70, 0, 70)
Bubble.Position = UDim2.new(1, -90, 1, -100)
Bubble.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
Bubble.Text = "FARM"
Bubble.TextColor3 = Color3.new(1,1,1)
Bubble.Font = Enum.Font.GothamBold
Bubble.TextSize = 20
Bubble.Parent = ScreenGui

local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0)
BubbleCorner.Parent = Bubble

-- Draggable logic
local dragging, dragInput, dragStart, startPos
local function updateInput(input)
    local Delta = input.Position - dragStart
    Bubble.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
end
Bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Bubble.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Bubble.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Menu Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 300)
Frame.Position = UDim2.new(0.5, -150, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Visible = false
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Simple Farm Hub"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = Frame

local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.8, 0, 0, 50)
FarmBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
FarmBtn.Text = "Auto Farm: OFF"
FarmBtn.TextColor3 = Color3.new(1,1,1)
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.TextSize = 18
FarmBtn.Parent = Frame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmBtn

local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.8, 0, 0, 50)
EspBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
EspBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
EspBtn.Text = "ESP Quái: OFF"
EspBtn.TextColor3 = Color3.new(1,1,1)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.TextSize = 18
EspBtn.Parent = Frame

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 8)
EspCorner.Parent = EspBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = Frame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Vars
local farmOn = false
local espOn = false
local esps = {}

-- Toggle menu
Bubble.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ESP
local function addEsp(mob)
    if esps[mob] or not mob:FindFirstChild("HumanoidRootPart") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Parent = mob
    billboard.Adornee = mob.HumanoidRootPart
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = mob.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard
    esps[mob] = billboard
end

EspBtn.MouseButton1Click:Connect(function()
    espOn = not espOn
    EspBtn.Text = espOn and "ESP Quái: ON" or "ESP Quái: OFF"
    EspBtn.BackgroundColor3 = espOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    if espOn then
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            addEsp(mob)
        end
        workspace.Enemies.ChildAdded:Connect(addEsp)
    else
        for mob, esp in pairs(esps) do
            esp:Destroy()
        end
        esps = {}
    end
end)

-- Auto Farm
FarmBtn.MouseButton1Click:Connect(function()
    farmOn = not farmOn
    FarmBtn.Text = farmOn and "Auto Farm: ON" or "Auto Farm: OFF"
    FarmBtn.BackgroundColor3 = farmOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 170, 0)
end)

spawn(function()
    while task.wait(0.3) do
        if farmOn and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local targetMob = "Galley Pirate"  -- Thay bằng quái phù hợp level bro
            local closestMob = nil
            local dist = math.huge
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob.Name:find(targetMob) and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                    local d = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
                    if d < dist then
                        dist = d
                        closestMob = mob
                    end
                end
            end
            if closestMob then
                hrp.CFrame = closestMob.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
                VirtualUser:ClickButton1(Vector2.new())
            end
        end
    end
end)

print("Simple Plain Farm Loaded!")
