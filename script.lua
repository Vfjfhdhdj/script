-- Tác giả: yutakjin
-- Chức năng: Fix giật lag, Auto Quest, Stats, Smooth Farm

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local AutoFarm_Enabled = false
local Selected_Enemy = "Bandit" -- Bạn có thể đổi tên quái ở đây

-- [[ HÀM NHẬN QUEST TỪ XA ]] --
local function GetQuest()
    -- Tự động nhận quest tùy theo quái đang chọn (Ví dụ cho Sea 1)
    local args = { [1] = "StartQuest", [2] = "Bandits", [3] = 1 }
    if Selected_Enemy == "Monkey" then args[2] = "Monkeys" args[3] = 1 end
    if Selected_Enemy == "Gorilla" then args[2] = "Gorillas" args[3] = 2 end
    
    ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
end

-- [[ HÀM TÌM QUÁI ]] --
local function GetEnemy()
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == Selected_Enemy and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
    return nil
end

-- [[ LOGIC FARM MƯỢT - FIX GIẬT ]] --
spawn(function()
    while true do
        task.wait() -- Độ trễ cực nhỏ để giảm giật
        if AutoFarm_Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = GetEnemy()
            
            -- Kiểm tra nhiệm vụ
            if not LocalPlayer.PlayerGui.Main:FindFirstChild("Quest") then
                GetQuest()
            end

            if target and target:FindFirstChild("HumanoidRootPart") then
                -- Tắt va chạm để bay xuyên vật cản
                for _, p in pairs(LocalPlayer.Character:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end

                -- DI CHUYỂN MƯỢT: Giữ khoảng cách 6 đơn vị trên đầu quái
                -- Dùng CFrame trực tiếp nhưng có task.wait giúp ổn định vị trí
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0) * CFrame.Angles(math.rad(-90), 0, 0)

                -- TỰ ĐỘNG CHÉM (Cần cầm vũ khí)
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,0))
            end
        end
    end
end)

-- [[ GIAO DIỆN MENU ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 180)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Draggable = true
Main.Active = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "YUTAKJIN V3 - FIX LAG"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Parent = Main

local Stats = Instance.new("TextLabel")
Stats.Size = UDim2.new(1, 0, 0, 60)
Stats.Position = UDim2.new(0, 0, 0.2, 0)
Stats.BackgroundTransparency = 1
Stats.TextColor3 = Color3.fromRGB(0, 255, 150)
Stats.TextSize = 13
Stats.Parent = Main

local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.8, 0, 0, 40)
FarmBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
FarmBtn.Text = "BẬT FARM"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Parent = Main

-- Cập nhật thông số Level/Exp
spawn(function()
    while task.wait(1) do
        local lvl = LocalPlayer.Data.Level.Value
        local exp = LocalPlayer.Data.Exp.Value
        Stats.Text = "Level: "..lvl.."\nExp: "..exp.."\nStatus: "..(AutoFarm_Enabled and "Running" or "Idle")
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    AutoFarm_Enabled = not AutoFarm_Enabled
    FarmBtn.Text = AutoFarm_Enabled and "TẮT FARM" or "BẬT FARM"
    FarmBtn.BackgroundColor3 = AutoFarm_Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 120, 200)
end)

print("yutakjin V3 Loaded!")
