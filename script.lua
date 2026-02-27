-- Tác giả: yutakjin

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local AutoFarm_Enabled = false

-- [[ DỮ LIỆU NHIỆM VỤ SƠ BỘ ]] --
-- (Lưu ý: Đây là ví dụ, để hoàn hảo cần tọa độ chính xác của hàng trăm NPC)
local QuestData = {
    ["Bandit"] = {Level = 1, NPC = "Bandit Quest Giver", QuestName = "Bandits"},
    ["Monkey"] = {Level = 15, NPC = "Monkey Quest Giver", QuestName = "Monkeys"},
}

-- [[ HÀM NHẬN NHIỆM VỤ ]] --
local function GetQuest()
    -- Logic này giả lập việc gọi hàm nhận quest của game
    -- Trong các bản hack xịn, họ thường dùng RemoteEvent để nhận quest từ xa
    local args = { [1] = "StartQuest", [2] = "Bandits", [3] = 1 }
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
end

-- [[ HÀM TÌM QUÁI THEO NHIỆM VỤ ]] --
local function GetTarget()
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            return v
        end
    end
    return nil
end

-- [[ LOGIC BAY VÀ CHÉM ]] --
RunService.Stepped:Connect(function()
    if AutoFarm_Enabled then
        local target = GetTarget()
        if target then
            -- Tắt va chạm để không bị vướng khi bay
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            
            -- BAY TRÊN CAO: Cách con quái 5-7 đơn vị để nó không chém tới mình
            Root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            
            -- TỰ ĐỘNG CHÉM
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
        end
    end
end)

-- [[ GIAO DIỆN MENU NỔI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 100)
MainFrame.Position = UDim2.new(0.5, -80, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "YUTAKJIN V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.8, 0, 0, 40)
FarmBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
FarmBtn.Text = "BẬT AUTO FARM"
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Parent = MainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.Parent = FarmBtn

FarmBtn.MouseButton1Click:Connect(function()
    AutoFarm_Enabled = not AutoFarm_Enabled
    if AutoFarm_Enabled then
        FarmBtn.Text = "TẮT FARM"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        GetQuest() -- Thử nhận quest khi bật
    else
        FarmBtn.Text = "BẬT AUTO FARM"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    end
end)

-- Nhấn M để ẩn menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Script by yutakjin loaded!")
