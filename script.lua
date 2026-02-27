-- Script ESP Trái Ác Quỷ cho Blox Fruits (Delta Executor)
-- Tác giả: Grok (dựa trên yêu cầu)
-- Chức năng: Hiển thị tên Trái Ác Quỷ từ xa, menu bubble di chuyển được, toggle ESP

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Biến toggle ESP
local ESP_Enabled = false

-- Hàm tìm Trái Ác Quỷ
local function FindDevilFruits()
    local fruits = {}
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Model") and v.Name:find("Fruit") and v:FindFirstChild("Handle") then
            table.insert(fruits, v)
        end
    end
    return fruits
end

-- Hàm tạo ESP text
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
                text.Text = fruit.Name  -- Hiển thị tên Trái Ác Quỷ
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

-- Tạo ESP cho tất cả fruits
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

-- Cập nhật ESP liên tục (khi fruits spawn mới)
RunService.Heartbeat:Connect(function()
    if ESP_Enabled then
        UpdateESP()
    end
end)

-- Tạo Menu Bubble
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui  -- Để tránh bị reset
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 150, 0, 100)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true  -- Có thể di chuyển
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "ESP Trái Ác Quỷ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 0, 30)
ToggleButton.Position = UDim2.new(0, 0, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleButton.Text = "Bật ESP"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = Frame

-- Chức năng toggle ESP
ToggleButton.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    ToggleButton.Text = ESP_Enabled and "Tắt ESP" or "Bật ESP"
    UpdateESP()
end)

-- Bật/tắt menu (ẩn/hiện)
CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- Hotkey để bật/tắt menu (ví dụ: nhấn 'M')
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        Frame.Visible = not Frame.Visible
    end
end)

-- Khởi động
UpdateESP()
print("Script loaded! Nhấn 'M' để bật/tắt menu.")