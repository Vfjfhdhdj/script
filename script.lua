-- 🌟 BLOX FRUITS AUTO FARM LEVEL - SERVER-SIDE REMOTE CALL - PLAIN LUA NO ENCODE 🌟
-- Delta X OK 2026 - Auto quest + farm mob quest + bring + skill Z/X server-side
-- Bong bóng kéo được, ESP quái, farm level up thật (exp tăng, quest complete)
-- Full code, không đứt đoạn

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ImprovedFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Bong bóng draggable
local Bubble = Instance.new("TextButton")
Bubble.Size = UDim2.new(0, 70, 0, 70)
Bubble.Position = UDim2.new(1, -90, 1, -100)
Bubble.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Bubble.Text = "FARM"
Bubble.TextColor3 = Color3.new(1,1,1)
Bubble.Font = Enum.Font.GothamBold
Bubble.TextSize = 20
Bubble.Parent = ScreenGui

local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0)
BubbleCorner.Parent = Bubble

-- Draggable bubble
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
Title.Text = "Improved Farm Hub"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = Frame

local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.8, 0, 0, 50)
FarmBtn.Position = UDim2.new(0.1, 0, 0.25, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
FarmBtn.Text = "Auto Farm Level: OFF"
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

-- ESP Quái
local function addEsp(mob)
    if esps[mob] or not mob:FindFirstChild("HumanoidRootPart") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP"
    bb.Parent = mob
    bb.Adornee = mob.HumanoidRootPart
    bb.Size = UDim2.new(0, 100, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1,0,1,0)
    name.BackgroundTransparency = 1
    name.Text = mob.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.TextStrokeTransparency = 0
    name.TextStrokeColor3 = Color3.new(0,0,0)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.Parent = bb
    esps[mob] = bb
end

EspBtn.MouseButton1Click:Connect(function()
    espOn = not espOn
    EspBtn.Text = espOn and "ESP Quái: ON" or "ESP Quái: OFF"
    EspBtn.BackgroundColor3 = espOn and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    if espOn then
        for _, mob in workspace.Enemies:GetChildren() do addEsp(mob) end
        workspace.Enemies.ChildAdded:Connect(addEsp)
    else
        for _, esp in pairs(esps) do esp:Destroy() end
        esps = {}
    end
end)

-- Auto Farm Level - Gọi remote server thật
spawn(function()
    while task.wait(0.3) do
        if farmOn and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local char = player.Character

            -- Respawn nếu chết
            if char.Humanoid.Health <= 0 then
                char:BreakJoints()
                task.wait(4)
                continue
            end

            -- Auto lấy quest nếu chưa có
            if not player.PlayerGui.Main.Quest.Visible then
                CommF_:InvokeServer("PlayerHunter")  -- Lấy quest hunter (thay bằng quest khác nếu cần)
                task.wait(1.5)
            end

            -- Lấy tên mob từ quest
            local questTitle = player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text or ""
            local targetName = questTitle:match("Defeat (.-)%[") or "Galley Pirate"  -- fallback nếu không có quest

            -- Tìm mob gần nhất phù hợp
            local closest = nil
            local minDist = math.huge
            for _, mob in workspace.Enemies:GetChildren() do
                if mob.Name:find(targetName) and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                    local d = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        closest = mob
                    end
                end
            end

            if closest then
                -- Teleport + Bring mob
                hrp.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 5, -8)
                task.wait(0.1)

                for _, mob in workspace.Enemies:GetChildren() do
                    if mob.Name:find(targetName) and mob:FindFirstChild("HumanoidRootPart") then
                        mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(math.random(-5,5), -5, math.random(-5,5))
                    end
                end

                -- Gọi server attack thật (damage + exp)
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
                pcall(function()
                    CommF_:InvokeServer("Melee", "Z")  -- Skill Z server-side
                    task.wait(0.25)
                    CommF_:InvokeServer("Melee", "X")  -- Skill X server-side
                end)
            end
        end
    end
end)

print("Improved Farm Loaded - Gọi remote server thật! Farm level chạy, exp tăng!")