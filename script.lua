-- Tác giả: yutakjin
-- Phiên bản: V12 Fix v3 (Sửa lỗi Menu không hiện v3)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

_G.AutoFarm = false
_G.AutoChest = false 
_G.BringMobs = false
_G.MonsterESP = false
_G.FruitESP = false

-- [[ HÀM BAY MƯỢT (TWEEN) ]] --
local function SmoothFly(targetCFrame)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local speed = 300 
    local info = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- [[ DỮ LIỆU ĐẢO & QUÁI (3 SEA) ]] --
local QuestLocations = {
    ["Sea1"] = {
        [1] = {Level = 1, NPC = "Bandit Quest Giver", QName = "Bandits", QID = 1, Enemy = "Bandit", Spawn = CFrame.new(1100, 30, 1600)},                
        [2] = {Level = 15, NPC = "Monkey Quest Giver", QName = "Monkeys", QID = 1, Enemy = "Monkey", Spawn = CFrame.new(-1450, 30, 200)},
        [3] = {Level = 30, NPC = "Gorilla Quest Giver", QName = "Gorillas", QID = 2, Enemy = "Gorilla", Spawn = CFrame.new(-1200, 30, -450)},
        [4] = {Level = 100, NPC = "Marine Quest Giver", QName = "Marine", QID = 2, Enemy = "Chief Petty Officer", Spawn = CFrame.new(-2450, 30, -3200)},
    },
    ["Sea2"] = {
        [1] = {Level = 700, NPC = "Cafe", QName = "Raids", QID = 1, Enemy = "Fordo", Spawn = CFrame.new(-550, 30, 100)},
    },
    ["Sea3"] = {
        [1] = {Level = 1500, NPC = "Port Town", QName = "Pirates", QID = 1, Enemy = "Pirate", Spawn = CFrame.new(100, 30, 100)},
    }
}

_G.SelectedSea = "Sea1" 

-- [[ LOGIC CHỌN QUÁI & NHIỆM VỤ CHUYỂN SEA ]] --
local function GetCurrentQuest()
    local lvl = LocalPlayer.Data.Level.Value
    
    if lvl >= 700 and _G.SelectedSea == "Sea1" then
        return {Level = 700, NPC = "Military Detective", QName = "IceAdmiral", QID = 1, Enemy = "Ice Admiral", Spawn = CFrame.new(-5000, 30, 3500)}
    end
    if lvl >= 1500 and _G.SelectedSea == "Sea2" then
        return {Level = 1500, NPC = "King Red Head", QName = "DonSwan", QID = 1, Enemy = "Don Swan", Spawn = CFrame.new(100, 30, 100)}
    end
    
    local seaData = QuestLocations[_G.SelectedSea]
    if lvl >= 2000 and _G.SelectedSea == "Sea1" then
        return seaData[#seaData]
    end
    
    local bestQuest = seaData[1]
    for _, q in pairs(seaData) do
        if lvl >= q.Level then
            bestQuest = q
        end
    end
    return bestQuest
end

-- [[ HÀM HỖ TRỢ ]] --
local function GetNPC(npcName)
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == npcName then return v end
    end
    return nil
end

local function GetEnemy(enemyName)
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == enemyName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then return v end
    end
    return nil
end

local function AutoClick()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(1280, 672))
end

-- [[ TÍNH NĂNG RƯƠNG NHANH ]] --
local function GetClosestChest()
    local closest, minDistance = nil, math.huge
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent.Name:find("Chest") then
            local distance = (v.Parent.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < minDistance then
                closest = v.Parent
                minDistance = distance
            end
        end
    end
    return closest
end

-- [[ VÒNG LẶP CHÍNH ]] --
RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        
        -- NoClip
        if _G.AutoFarm or _G.AutoChest or _G.BringMobs then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        -- LOGIC GOM QUÁI
        if _G.BringMobs then
            local currentQuest = GetCurrentQuest()
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == currentQuest.Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    v.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, -2, 0)
                end
            end
        end

        -- LOGIC AUTO FARM (BAY MƯỢT)
        if _G.AutoFarm and not _G.AutoChest then
            local currentQuest = GetCurrentQuest()
            
            if not LocalPlayer.PlayerGui.Main:FindFirstChild("Quest") then
                local npc = GetNPC(currentQuest.NPC)
                if npc then
                    SmoothFly(npc.HumanoidRootPart.CFrame)
                    task.wait(0.5)
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", currentQuest.QName, currentQuest.QID)
                    task.wait(0.5)
                else
                    SmoothFly(currentQuest.Spawn)
                end
            else
                local enemy = GetEnemy(currentQuest.Enemy)
                if enemy then
                    if not _G.BringMobs then
                        SmoothFly(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                    end
                    AutoClick()
                else
                    SmoothFly(currentQuest.Spawn)
                end
            end
        end

        -- LOGIC NHẶT RƯƠNG NHANH
        if _G.AutoChest then
            local chest = GetClosestChest()
            if chest then
                root.CFrame = chest.CFrame
                task.wait(0.1)
            else
                print("Hết rương, Server Hop!")
            end
        end
    end
end)

-- [[ ESP & GIAO DIỆN SIÊU CẤP ]] --
RunService.RenderStepped:Connect(function()
    if _G.MonsterESP then
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") then
                if not v.HumanoidRootPart:FindFirstChild("yutakjin_MonsterESP") then
                    local bbg = Instance.new("BillboardGui", v.HumanoidRootPart)
                    bbg.Name = "yutakjin_MonsterESP"
                    bbg.AlwaysOnTop = true
                    bbg.Size = UDim2.new(0, 100, 0, 30)
                    bbg.StudsOffset = Vector3.new(0, 3, 0)
                    local txt = Instance.new("TextLabel", bbg)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.TextSize = 10
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.BackgroundTransparency = 1
                    txt.TextStrokeTransparency = 0
                end
                v.HumanoidRootPart.yutakjin_MonsterESP.Enabled = true
                v.HumanoidRootPart.yutakjin_MonsterESP.TextLabel.Text = v.Name
            end
        end
    else
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart:FindFirstChild("yutakjin_MonsterESP") then
                v.HumanoidRootPart.yutakjin_MonsterESP.Enabled = false
            end
        end
    end

    if _G.FruitESP then
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Model") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                if not v.Handle:FindFirstChild("yutakjin_FruitESP") then
                    local bbg = Instance.new("BillboardGui", v.Handle)
                    bbg.Name = "yutakjin_FruitESP"
                    bbg.AlwaysOnTop = true
                    bbg.Size = UDim2.new(0, 100, 0, 40)
                    local txt = Instance.new("TextLabel", bbg)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.Text = "🍎 " .. v.Name
                    txt.TextColor3 = Color3.fromRGB(255, 0, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextStrokeTransparency = 0
                end
                v.Handle.yutakjin_FruitESP.Enabled = true
            elseif v:IsA("Model") and v:FindFirstChild("Handle") and v.Handle:FindFirstChild("yutakjin_FruitESP") then
                v.Handle.yutakjin_FruitESP.Enabled = false
            end
        end
    else
        for _, v in pairs(Workspace:GetChildren()) do
            if v:FindFirstChild("Handle") and v.Handle:FindFirstChild("yutakjin_FruitESP") then
                v.Handle.yutakjin_FruitESP.Enabled = false
            end
        end
    end
end)

-- Giao diện chiêu cuối
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "yutakjin_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true -- Luôn hiện GUI

local Bubble = Instance.new("ImageButton", ScreenGui)
Bubble.Size = UDim2.new(0, 55, 0, 55)
Bubble.Position = UDim2.new(0, 15, 0, 150)
Bubble.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Bubble.Image = "rbxassetid://6031280882"
Bubble.Draggable = true
Instance.new("UICorner", Bubble).CornerRadius = Enum.CornerRadius.new(1, 0)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 470)
Main.Position = UDim2.new(0, 75, 0, 150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Visible = false -- Menu ẩn mặc định
Instance.new("UICorner", Main)

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "yutakjin V12"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", Title)

local function CreateBtn(text, color)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn)
    return btn
end

-- Nút chức năng
local FarmBtn = CreateBtn("AUTO FARM: TẮT", Color3.fromRGB(200, 50, 50))
local ChestBtn = CreateBtn("AUTO RƯƠNG: TẮT", Color3.fromRGB(70, 70, 70))
local BringBtn = CreateBtn("GOM QUÁI: TẮT", Color3.fromRGB(150, 0, 200))
local MonsterESPBtn = CreateBtn("ESP QUÁI: TẮT", Color3.fromRGB(70, 70, 70))
local ESPBtn = CreateBtn("ESP TRÁI: TẮT", Color3.fromRGB(70, 70, 70))

local SeaLabel = Instance.new("TextLabel", Main)
SeaLabel.Size = UDim2.new(1, 0, 0, 30)
SeaLabel.Text = "Sea Chọn: " .. _G.SelectedSea
SeaLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
SeaLabel.BackgroundTransparency = 1

local Sea1Btn = CreateBtn("SEA 1", Color3.fromRGB(0, 100, 200))
local Sea2Btn = CreateBtn("SEA 2", Color3.fromRGB(0, 100, 200))
local Sea3Btn = CreateBtn("SEA 3", Color3.fromRGB(0, 100, 200))

-- [[ SỰ KIỆN CHIÊU CUỐI ]] --
Bubble.MouseButton1Click:Connect(function() 
    Main.Visible = not Main.Visible 
end)

-- Sử dụng sự kiện thay thế nếu Click không hoạt động
Bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Main.Visible = not Main.Visible
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: BẬT" or "AUTO FARM: TẮT"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 50, 50)
    if _G.AutoFarm then _G.AutoChest = false; ChestBtn.Text = "AUTO RƯƠNG: TẮT"; ChestBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end
end)
ChestBtn.MouseButton1Click:Connect(function()
    _G.AutoChest = not _G.AutoChest
    ChestBtn.Text = _G.AutoChest and "AUTO RƯƠNG: BẬT" or "AUTO RƯƠNG: TẮT"
    ChestBtn.BackgroundColor3 = _G.AutoChest and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(70, 70, 70)
    if _G.AutoChest then _G.AutoFarm = false; FarmBtn.Text = "AUTO FARM: TẮT"; FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) end
end)
BringBtn.MouseButton1Click:Connect(function()
    _G.BringMobs = not _G.BringMobs
    BringBtn.Text = _G.BringMobs and "GOM QUÁI: BẬT" or "GOM QUÁI: TẮT"
    BringBtn.BackgroundColor3 = _G.BringMobs and Color3.fromRGB(100, 0, 150) or Color3.fromRGB(150, 0, 200)
end)
MonsterESPBtn.MouseButton1Click:Connect(function()
    _G.MonsterESP = not _G.MonsterESP
    MonsterESPBtn.Text = _G.MonsterESP and "ESP QUÁI: BẬT" or "ESP QUÁI: TẮT"
    MonsterESPBtn.BackgroundColor3 = _G.MonsterESP and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(70, 70, 70)
end)
ESPBtn.MouseButton1Click:Connect(function()
    _G.FruitESP = not _G.FruitESP
    ESPBtn.Text = _G.FruitESP and "ESP TRÁI: BẬT" or "ESP TRÁI: TẮT"
    ESPBtn.BackgroundColor3 = _G.FruitESP and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(70, 70, 70)
end)

Sea1Btn.MouseButton1Click:Connect(function() 
    _G.SelectedSea = "Sea1" 
    SeaLabel.Text = "Sea Chọn: Sea1"
end)
Sea2Btn.MouseButton1Click:Connect(function() 
    _G.SelectedSea = "Sea2" 
    SeaLabel.Text = "Sea Chọn: Sea2"
end)
Sea3Btn.MouseButton1Click:Connect(function() 
    _G.SelectedSea = "Sea3" 
    SeaLabel.Text = "Sea Chọn: Sea3"
end)

print("yutakjin V12 Fix v3 Loaded! Ultimate GUI Loaded!")
