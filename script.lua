-- Tác giả: yutakjin --
--bản v3 nâng cấp🗿--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Biến trạng thái
_G.AutoFarm = false
_G.FruitESP = false

-- [[ DỮ LIỆU SEA & QUÁI ]] --
local function GetLevelFarm()
    local lvl = LocalPlayer.Data.Level.Value
    if lvl < 15 then return "Bandit", "Bandits", 1
    elseif lvl < 30 then return "Monkey", "Monkeys", 1
    elseif lvl < 60 then return "Gorilla", "Gorillas", 2
    elseif lvl < 120 then return "Chief Pirate", "ChiefPirates", 2
    elseif lvl < 210 then return "Yeti", "Yetis", 2
    -- Bạn có thể thêm các mốc level tiếp theo ở đây
    else return "Military Soldier", "MilitarySoldiers", 1 end 
end

-- [[ HÀM TỰ ĐỘNG ĐÁNH ]] --
local function AutoAttack()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(1280, 672))
end

-- [[ HÀM ESP TRÁI CÂY ]] --
local function UpdateESP()
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
            if not v.Handle:FindFirstChild("FruitESP") then
                local billboard = Instance.new("BillboardGui", v.Handle)
                billboard.Name = "FruitESP"
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.Adornee = v.Handle
                
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.Text = "🍎 " .. v.Name
                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                label.BackgroundTransparency = 1
                label.TextStrokeTransparency = 0
            end
            v.Handle.FruitESP.Enabled = _G.FruitESP
        end
    end
end

-- [[ LOGIC AUTO FARM ]] --
RunService.Stepped:Connect(function()
    if _G.AutoFarm then
        local monster, qName, qID = GetLevelFarm()
        
        -- Nhận Quest nếu chưa có
        if not LocalPlayer.PlayerGui.Main:FindFirstChild("Quest") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", qName, qID)
        end

        -- Tìm quái
        for _, v in pairs(Workspace.Enemies:GetChildren()) do
            if v.Name == monster and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                -- Tắt va chạm
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                    -- Teleport trên đầu quái
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    AutoAttack()
                end
                break
            end
        end
    end
    UpdateESP()
end)

-- [[ GIAO DIỆN BONG BÓNG MESSENGER ]] --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- Nút tròn (Bong bóng)
local Bubble = Instance.new("ImageButton", ScreenGui)
Bubble.Size = UDim2.new(0, 50, 0, 50)
Bubble.Position = UDim2.new(0, 10, 0, 200)
Bubble.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
Bubble.Image = "rbxassetid://6031280882" -- Icon hình tròn
Bubble.Draggable = true -- Có thể kéo đi

local UICorner = Instance.new("UICorner", Bubble)
UICorner.CornerRadius = Enum.CornerRadius.new(1, 0)

-- Menu chính
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 220)
MainFrame.Position = UDim2.new(0, 70, 0, 200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false

local Layout = Instance.new("UIListLayout", MainFrame)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "YUTAKJIN V4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local StatsLabel = Instance.new("TextLabel", MainFrame)
StatsLabel.Size = UDim2.new(0.9, 0, 0, 50)
StatsLabel.Text = "Loading Stats..."
StatsLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
StatsLabel.BackgroundTransparency = 1

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0.9, 0, 0, 40)
FarmBtn.Text = "Auto Farm: TẮT"
FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ESPBtn = Instance.new("TextButton", MainFrame)
ESPBtn.Size = UDim2.new(0.9, 0, 0, 40)
ESPBtn.Text = "ESP Trái: TẮT"
ESPBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- [[ SỰ KIỆN ]] --
Bubble.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "Auto Farm: BẬT" or "Auto Farm: TẮT"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
end)

ESPBtn.MouseButton1Click:Connect(function()
    _G.FruitESP = not _G.FruitESP
    ESPBtn.Text = _G.FruitESP and "ESP Trái: BẬT" or "ESP Trái: TẮT"
    ESPBtn.BackgroundColor3 = _G.FruitESP and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(100, 100, 100)
end)

-- Cập nhật Stats mỗi giây
spawn(function()
    while wait(1) do
        local lvl = LocalPlayer.Data.Level.Value
        local exp = LocalPlayer.Data.Exp.Value
        StatsLabel.Text = "Level: " .. lvl .. "\nExp: " .. exp
    end
end)

print("yutakjin V4 Loaded! Bấm vào bong bóng xanh để mở menu.")
