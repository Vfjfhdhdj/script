-- 🌟 DELTA X BLOX FRUITS - SMART AUTO FARM + ESP + FLOATING BUBBLE MENU 🌟
-- Feb 2026 - TỰ ĐỌC LEVEL + SEA → CÀY QUÁI PHÙ HỢP!
-- Level 2000+ ở Sea 1 → Farm Galley Pirate (mạnh nhất Sea 1 Lv.625)
-- Paste Delta X → Exec → Bong bóng MENU nổi góc dưới phải → Bấm mở!

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Wait Data
player:WaitForChild("Data")
player.Data:WaitForChild("Level")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SmartFarmHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- FLOATING BUBBLE (luôn nổi)
local BubbleBtn = Instance.new("TextButton")
BubbleBtn.Name = "Bubble"
BubbleBtn.Size = UDim2.new(0, 70, 0, 70)
BubbleBtn.Position = UDim2.new(1, -80, 1, -90)
BubbleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
BubbleBtn.Text = "🚀"
BubbleBtn.TextColor3 = Color3.new(1,1,1)
BubbleBtn.Font = Enum.Font.GothamBold
BubbleBtn.TextSize = 30
BubbleBtn.Parent = ScreenGui

local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0)
BubbleCorner.Parent = BubbleBtn

local BubbleStroke = Instance.new("UIStroke")
BubbleStroke.Color = Color3.new(1,1,1)
BubbleStroke.Thickness = 2
BubbleStroke.Parent = BubbleBtn

-- Main Frame (ẩn lúc đầu)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 150)
MainStroke.Thickness = 2.5
MainStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🧠 SMART FARM HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = MainFrame

-- Close Btn
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseBtn

-- ESP Toggle
local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.new(0.9, 0, 0, 50)
EspToggle.Position = UDim2.new(0.05, 0, 0.18, 0)
EspToggle.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
EspToggle.Text = "👁️ ESP QUÁI: OFF"
EspToggle.TextColor3 = Color3.new(1,1,1)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.TextSize = 18
EspToggle.Parent = MainFrame

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 12)
EspCorner.Parent = EspToggle

-- Farm Toggle
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(0.9, 0, 0, 50)
FarmToggle.Position = UDim2.new(0.05, 0, 0.36, 0)
FarmToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
FarmToggle.Text = "🌾 SMART FARM: OFF"
FarmToggle.TextColor3 = Color3.new(1,1,1)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.TextSize = 18
FarmToggle.Parent = MainFrame

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 12)
FarmCorner.Parent = FarmToggle

-- Status (Level + Sea + Farming)
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.9, 0, 0, 80)
Status.Position = UDim2.new(0.05, 0, 0.58, 0)
Status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Status.Text = "Level: -- | Sea: -- | Farming: --"
Status.TextColor3 = Color3.fromRGB(255, 255, 0)
Status.Font = Enum.Font.Gotham
Status.TextSize = 16
Status.TextWrapped = true
Status.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = Status

-- VARS
local espEnabled = false
local farmEnabled = false
local mainVisible = false
local espConns = {}
local farmLoop = nil
local statusConn = nil

-- DRAG MAINFRAME
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- SEA DETECTION (dựa Y position)
local function getSea(pos)
    local y = pos.Y
    if y > 5500 then return "4 (New Sea)"
    elseif y > 2500 then return "3"
    elseif y > 600 then return "2"
    else return "1"
    end
end

-- TARGET MOB (tự đọc level + sea)
local highestMobs = {
    [1] = "Galley Pirate",  -- Mạnh nhất Sea 1 (Lv.625)
    [2] = "Ship Steward",   -- Sea 2 high (Lv.1300)
    [3] = "Cocoa Warrior",  -- Sea 3 (Lv.2300)
    [4] = "Candy Pirate"    -- New high
}
local function getTargetMob(level, sea)
    if level >= 2000 then
        return highestMobs[tonumber(sea)] or "Galley Pirate"
    end
    -- Level based (từ wiki guide)
    if level < 10 then return "Bandit"
    elseif level < 25 then return "Monkey"
    elseif level < 35 then return "Pirate"
    elseif level < 90 then return "Snow Bandit"
    elseif level < 130 then return "Yeti"  -- Boss
    elseif level < 300 then return "Military Soldier"
    elseif level < 625 then return "Galley Pirate"
    else return highestMobs[tonumber(sea)] or "Galley Pirate"
    end
end

-- UPDATE STATUS
local function updateStatus()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local level = player.Data.Level.Value
        local sea = getSea(player.Character.HumanoidRootPart.Position)
        local target = getTargetMob(level, sea)
        Status.Text = string.format("Level: %d\nSea: %s\nFarming: %s", level, sea, target)
    end
end

-- ESP (giữ nguyên)
local function createEsp(mob)
    if mob:FindFirstChild("ESP") or not mob:FindFirstChild("HumanoidRootPart") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP"
    bb.Parent = mob
    bb.Adornee = mob.HumanoidRootPart
    bb.Size = UDim2.new(0, 120, 0, 60)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop = true
    local name = Instance.new("TextLabel", bb)
    name.Size = UDim2.new(1, 0, 0.5, 0)
    name.BackgroundTransparency = 1
    name.Text = mob.Name
    name.TextColor3 = Color3.new(1,1,1)
    name.TextStrokeTransparency = 0
    name.TextStrokeColor3 = Color3.new(0,0,0)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 16
    local hp = Instance.new("Frame", bb)
    hp.Size = UDim2.new(1, -10, 0.4, 0)
    hp.Position = UDim2.new(0, 5, 0.5, 0)
    hp.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    hp.BorderSizePixel = 0
    local hpb = Instance.new("Frame", hp)
    hpb.Size = UDim2.new(1, 0, 1, 0)
    hpb.BackgroundColor3 = Color3.fromRGB(50,50,50)
    hpb.ZIndex = hp.ZIndex - 1
    local hc = Instance.new("UICorner", hp)
    hc.CornerRadius = UDim.new(0, 5)
    local hbc = Instance.new("UICorner", hpb)
    hbc.CornerRadius = UDim.new(0, 5)
    spawn(function()
        while mob.Parent and mob:FindFirstChild("Humanoid") do
            local h = mob.Humanoid
            local perc = h.Health / h.MaxHealth
            hp.Size = UDim2.new(perc, -10, 0.4, 0)
            hp.BackgroundColor3 = Color3.fromRGB(255*(1-perc), 255*perc, 0)
            task.wait(0.3)
        end
        if bb then bb:Destroy() end
    end)
end

-- TOGGLE ESP
EspToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    EspToggle.Text = espEnabled and "👁️ ESP QUÁI: ON" or "👁️ ESP QUÁI: OFF"
    EspToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    if espEnabled then
        for _, m in workspace.Enemies:GetChildren() do createEsp(m) end
        table.insert(espConns, workspace.Enemies.ChildAdded:Connect(function(m) task.spawn(function() task.wait(0.5); createEsp(m) end) end))
    else
        for _, m in workspace.Enemies:GetChildren() do if m:FindFirstChild("ESP") then m.ESP:Destroy() end end
        for _, c in espConns do c:Disconnect() end
        espConns = {}
    end
end)

-- SMART FARM LOOP
local function farmLoop()
    spawn(function()
        while farmEnabled do
            pcall(function()
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait(1); return end
                local hrp = char.HumanoidRootPart
                local level = player.Data.Level.Value
                local sea = getSea(hrp.Position)
                local targetMob = getTargetMob(level, sea)
                
                -- Tìm mob phù hợp gần nhất
                local closest = nil
                local minDist = math.huge
                for _, mob in workspace.Enemies:GetChildren() do
                    if mob.Name:find(targetMob) and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                        local dist = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
                        if dist < minDist and dist < 2000 then  -- Giới hạn range
                            minDist = dist
                            closest = mob
                        end
                    end
                end
                
                if closest then
                    -- Tele + Bring
                    hrp.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
                    task.wait(0.1)
                    -- Bring all target mobs
                    for _, mob in workspace.Enemies:GetChildren() do
                        if mob.Name:find(targetMob) and mob:FindFirstChild("HumanoidRootPart") then
                            mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(math.random(-10,10)/10, -5, math.random(-10,10)/10)
                        end
                    end
                    -- Attack + Skills
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new())
                    pcall(CommF_.InvokeServer, CommF_, "Melee", "Z")
                    pcall(CommF_.InvokeServer, CommF_, "Melee", "X")
                else
                    -- No mob → Tele random area or wait
                    task.wait(2)
                end
            end)
            task.wait(0.25)
        end
    end)
end

-- TOGGLE FARM
FarmToggle.MouseButton1Click:Connect(function()
    farmEnabled = not farmEnabled
    FarmToggle.Text = farmEnabled and "🌾 SMART FARM: ON" or "🌾 SMART FARM: OFF"
    FarmToggle.BackgroundColor3 = farmEnabled and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(100, 200, 100)
    if farmEnabled then farmLoop() end
end)

-- BUBBLE TOGGLE MENU
BubbleBtn.MouseButton1Click:Connect(function()
    mainVisible = not mainVisible
    MainFrame.Visible = mainVisible
    BubbleBtn.Text = mainVisible and "❌" or "🚀"
    BubbleBtn.BackgroundColor3 = mainVisible and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(0, 255, 150)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- INIT STATUS UPDATE
statusConn = RunService.Heartbeat:Connect(function()
    updateStatus()
end)

-- HOVER EFFECTS
local function hoverEffect(btn, hoverC, normalC)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverC}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalC}):Play() end)
end
hoverEffect(BubbleBtn, Color3.fromRGB(255, 255, 100), Color3.fromRGB(0, 255, 150))
hoverEffect(EspToggle, Color3.fromRGB(120, 255, 120), Color3.fromRGB(255, 100, 100))
hoverEffect(FarmToggle, Color3.fromRGB(50, 255, 50), Color3.fromRGB(100, 200, 100))
hoverEffect(CloseBtn, Color3.fromRGB(255, 120, 120), Color3.fromRGB(255, 70, 70))

print("🌟 Smart Farm Hub Loaded! Bong bóng 🚀 nổi sẵn → Bấm mở menu cày quái thông minh!")
print("💡 Level 2000+ Sea 1 → Auto farm Galley Pirate mạnh nhất!")