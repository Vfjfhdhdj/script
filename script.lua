-- Tác giả: yutakjin --
-- Phiên bản: V10 --

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
_G.AutoFarm = false
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
    -- Sea 1
    ["Sea1"] = {
        [1] = {Level = 1, NPC = "Bandit Quest Giver", QName = "Bandits", QID = 1, Enemy = "Bandit", Spawn = CFrame.new(1100, 30, 1600)},                
        [2] = {Level = 15, NPC = "Monkey Quest Giver", QName = "Monkeys", QID = 1, Enemy = "Monkey", Spawn = CFrame.new(-1450, 30, 200)},
        [3] = {Level = 30, NPC = "Gorilla Quest Giver", QName = "Gorillas", QID = 2, Enemy = "Gorilla", Spawn = CFrame.new(-1200, 30, -450)},
        [4] = {Level = 100, NPC = "Marine Quest Giver", QName = "Marine", QID = 2, Enemy = "Chief Petty Officer", Spawn = CFrame.new(-2450, 30, -3200)},
    },
    -- Sea 2 (Ví dụ vài quái)
    ["Sea2"] = {
        [1] = {Level = 700, NPC = "Cafe", QName = "Raids", QID = 1, Enemy = "Fordo", Spawn = CFrame.new(-550, 30, 100)},
    },
    -- Sea 3 (Ví dụ vài quái)
    ["Sea3"] = {
        [1] = {Level = 1500, NPC = "Port Town", QName = "Pirates", QID = 1, Enemy = "Pirate", Spawn = CFrame.new(100, 30, 100)},
    }
}

-- Biến lưu Sea hiện tại đang chọn để farm
_G.SelectedSea = "Sea1" 

-- [[ LOGIC CHỌN QUÁI THÔNG MINH THEO SEA ]] --
local function GetCurrentQuest()
    local lvl = LocalPlayer.Data.Level.Value
    local seaData = QuestLocations[_G.SelectedSea]
    
    -- NẾU LEVEL > 2000 VÀ ĐANG Ở SEA 1, FARM CON MẠNH NHẤT SEA 1
    if lvl >= 2000 and _G.SelectedSea == "Sea1" then
        return seaData[#seaData]
    end
    
    -- CHECK THEO MỐC LEVEL TRONG SEA
    local bestQuest = seaData[1]
    for _, q in pairs(seaData) do
        if lvl >= q.Level then
            bestQuest = q
        end
    end
    return bestQuest
end

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

-- [[ VÒNG LẶP CHÍNH ]] --
RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        
        -- NoClip
        if _G.AutoFarm or _G.BringMobs then
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
        if _G.AutoFarm then
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
    end
end)

-- [[ ESP & GIAO DIỆN ]] --
-- ESP Quái
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

    -- ESP Trái
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

-- Giao diện
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Bubble = Instance.new("ImageButton", ScreenGui)
Bubble.Size = UDim2.new(0, 55, 0, 55)
Bubble.Position = UDim2.new(0, 15, 0, 150)
Bubble.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
Bubble.Image = "rbxassetid://6031280882"
Bubble.Draggable = true
Instance.new("UICorner", Bubble).CornerRadius = Enum.CornerRadius.new(1, 0)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 420) -- Tăng chiều cao
Main.Position = UDim2.new(0, 75, 0, 150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Visible = false
Instance.new("UICorner", Main)

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "yutakjin V10"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

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
local BringBtn = CreateBtn("GOM QUÁI: TẮT", Color3.fromRGB(150, 0, 200))
local MonsterESPBtn = CreateBtn("ESP QUÁI: TẮT", Color3.fromRGB(70, 70, 70))
local ESPBtn = CreateBtn("ESP TRÁI: TẮT", Color3.fromRGB(70, 70, 70))

-- Dòng chữ Sea hiện tại
local SeaLabel = Instance.new("TextLabel", Main)
SeaLabel.Size = UDim2.new(1, 0, 0, 30)
SeaLabel.Text = "Sea Chọn: " .. _G.SelectedSea
SeaLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
SeaLabel.BackgroundTransparency = 1

-- Nút Sea
local Sea1Btn = CreateBtn("SEA 1", Color3.fromRGB(0, 100, 200))
local Sea2Btn = CreateBtn("SEA 2", Color3.fromRGB(0, 100, 200))
local Sea3Btn = CreateBtn("SEA 3", Color3.fromRGB(0, 100, 200))

-- [[ SỰ KIỆN ]] --
Bubble.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: BẬT" or "AUTO FARM: TẮT"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 50, 50)
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

-- Sự kiện nút Sea
Sea1Btn.MouseButton1Click:Connect(function() 
    _G.SelectedSea = "Sea1" 
    SeaLabel.Text = "Sea Chọn: Sea1"
    -- Lệnh teleport qua sea 1 (cần id map)
    -- TeleportService:Teleport(2753915520, LocalPlayer) 
end)
Sea2Btn.MouseButton1Click:Connect(function() 
    _G.SelectedSea = "Sea2" 
    SeaLabel.Text = "Sea Chọn: Sea2"
    -- Lệnh teleport qua sea 2
    -- TeleportService:Teleport(4442245441, LocalPlayer)
end)
Sea3Btn.MouseButton1Click:Connect(function() 
    _G.SelectedSea = "Sea3" 
    SeaLabel.Text = "Sea Chọn: Sea3"
    -- Lệnh teleport qua sea 3
    -- TeleportService:Teleport(7449923569, LocalPlayer)
end)

print("yutakjin V10 Loaded! Check 2000+ Level + Sea Manager.")
