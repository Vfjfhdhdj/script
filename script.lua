-- Tác giả: yutakjin
-- Chức năng: Auto Quest, Select Level Farm, Display Stats (Level, Sea, Exp)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- Biến cấu hình
local AutoFarm_Enabled = false
local Selected_Level_Farm = "Bandit" -- Mặc định

-- Dữ liệu quái và level (Bạn có thể thêm vào list này)
local FarmList = {
    ["Bandit"] = {Level = 1, QuestNPC = "Bandit Quest Giver", QuestName = "Bandits", QuestID = 1},
    ["Monkey"] = {Level = 15, QuestNPC = "Monkey Quest Giver", QuestName = "Monkeys", QuestID = 1},
    ["Gorilla"] = {Level = 25, QuestNPC = "Gorilla Quest Giver", QuestName = "Gorillas", QuestID = 2},
}

-- Hàm nhận diện Sea hiện tại
local function GetCurrentSea()
    local placeId = game.PlaceId
    if placeId == 2753915520 then return "Sea 1"
    elseif placeId == 4442245441 then return "Sea 2"
    elseif placeId == 7449923569 then return "Sea 3"
    else return "Unknown" end
end

-- Hàm nhận nhiệm vụ từ xa
local function AutoGetQuest()
    local data = FarmList[Selected_Level_Farm]
    if data then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", data.QuestName, data.QuestID)
    end
end

-- Hàm tìm quái mục tiêu
local function GetTarget()
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == Selected_Level_Farm and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
    return nil
end

-- Logic Auto Farm Bay trên cao
RunService.Stepped:Connect(function()
    if AutoFarm_Enabled then
        local target = GetTarget()
        
        -- Nếu chưa có nhiệm vụ thì tự nhận
        if not LocalPlayer.PlayerGui.Main:FindFirstChild("Quest") then
            AutoGetQuest()
        end

        if target and target:FindFirstChild("HumanoidRootPart") then
            -- Tắt va chạm
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            
            -- Bay trên đầu quái 7 đơn vị để né skill
            Root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            
            -- Tấn công
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
        end
    end
end)

-- [[ GIAO DIỆN UI CHUYÊN NGHIỆP ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "YutakjinV2"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 250)
MainFrame.Position = UDim2.new(0.5, -110, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "YUTAKJIN V2 - AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Parent = MainFrame

-- Hiển thị thông số (Stats)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(0.9, 0, 0, 60)
StatsLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextSize = 14
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = MainFrame

-- Nút Bật/Tắt Farm
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
ToggleBtn.Text = "BẮT ĐẦU FARM"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Parent = MainFrame

-- Danh sách chọn quái (Ví dụ đơn giản)
local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(0.9, 0, 0, 30)
SelectBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
SelectBtn.Text = "Chọn Quái: " .. Selected_Level_Farm
SelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.Parent = MainFrame

-- Cập nhật Stats liên tục
spawn(function()
    while wait(1) do
        local lvl = LocalPlayer.Data.Level.Value
        local exp = LocalPlayer.Data.Exp.Value
        local maxExp = LocalPlayer.Data.MaxExp.Value
        StatsLabel.Text = string.format("Level: %d\nSea: %s\nExp: %d/%d", lvl, GetCurrentSea(), exp, maxExp)
    end
end)

-- Chức năng nút
ToggleBtn.MouseButton1Click:Connect(function()
    AutoFarm_Enabled = not AutoFarm_Enabled
    ToggleBtn.Text = AutoFarm_Enabled and "ĐANG FARM..." or "BẮT ĐẦU FARM"
    ToggleBtn.BackgroundColor3 = AutoFarm_Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 150, 100)
end)

SelectBtn.MouseButton1Click:Connect(function()
    -- Logic xoay vòng danh sách quái để chọn
    if Selected_Level_Farm == "Bandit" then Selected_Level_Farm = "Monkey"
    elseif Selected_Level_Farm == "Monkey" then Selected_Level_Farm = "Gorilla"
    else Selected_Level_Farm = "Bandit" end
    SelectBtn.Text = "Chọn Quái: " .. Selected_Level_Farm
end)

-- Phím M ẩn/hiện
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Script yutakjin V2 Loaded!")
