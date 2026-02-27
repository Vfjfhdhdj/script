-- [[V1]] --
local URL_RAW_KEY = "https://raw.githubusercontent.com/Vfjfhdhdj/nd/refs/heads/main/key.txt" -- Link Raw chứa Key của bạn
local MY_GETKEY_LINK = "https://link4m.com/EOmecR" -- Link để user lấy key
local SCRIPT_CHINH = "https://raw.githubusercontent.com/Vfjfhdhdj/script/main/script.lua"

-- [[ui]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local KeyInput = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local CheckBtn = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")
local CopyBtn = Instance.new("TextButton")
local UICorner_4 = Instance.new("UICorner")

-- Setup ScreenGui
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "KeySystem_V1"

-- Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -85)
MainFrame.Size = UDim2.new(0, 250, 0, 170)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame

-- Title
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "X-SCRIPT SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

-- Box nhập Key
KeyInput.Name = "KeyInput"
KeyInput.Parent = MainFrame
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Nhập Key tại đây..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14

UICorner_2.Parent = KeyInput

-- Nút Check
CheckBtn.Name = "CheckBtn"
CheckBtn.Parent = MainFrame
CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
CheckBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
CheckBtn.Size = UDim2.new(0.38, 0, 0, 35)
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.Text = "VÀO GAME"
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.TextSize = 12

UICorner_3.Parent = CheckBtn

-- Nút Get Key (Copy Link)
CopyBtn.Name = "CopyBtn"
CopyBtn.Parent = MainFrame
CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
CopyBtn.Position = UDim2.new(0.52, 0, 0.6, 0)
CopyBtn.Size = UDim2.new(0.38, 0, 0, 35)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.Text = "LẤY KEY"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 12

UICorner_4.Parent = CopyBtn

-- [[ XỬ LÝ LOGIC ]] --

-- Hàm Copy Link Get Key
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(MY_GETKEY_LINK)
        CopyBtn.Text = "ĐÃ COPY!"
        wait(1.5)
        CopyBtn.Text = "LẤY KEY"
    else
        CopyBtn.Text = "LỖI COPY"
    end
end)

-- Hàm Kiểm Tra và Load Script
CheckBtn.MouseButton1Click:Connect(function()
    local input = KeyInput.Text
    CheckBtn.Text = "ĐANG CHECK..."
    
    -- Lấy Key từ GitHub (Dùng os.time để ép server cập nhật mới nhất)
    local success, serverKey = pcall(function()
        return game:HttpGet(URL_RAW_KEY .. "?t=" .. os.time())
    end)
    
    if success then
        serverKey = serverKey:gsub("%s+", "") -- Loại bỏ khoảng trắng/xuống dòng
        
        if input == serverKey then
            CheckBtn.Text = "OK! LOADING..."
            CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            wait(1)
            ScreenGui:Destroy() -- Xóa UI Get Key
            
            -- CHẠY SCRIPT CHÍNH CỦA BẠN
            local runScript = pcall(function()
                loadstring(game:HttpGet(SCRIPT_CHINH))()
            end)
            
            if not runScript then
                warn("Lỗi khi tải Script chính. Kiểm tra lại link GitHub của script!")
            end
        else
            CheckBtn.Text = "SAI KEY!"
            CheckBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            wait(1.5)
            CheckBtn.Text = "VÀO GAME"
            CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    else
        CheckBtn.Text = "LỖI KẾT NỐI"
        warn("Không thể lấy dữ liệu từ GitHub. Kiểm tra lại link Raw!")
        wait(1.5)
        CheckBtn.Text = "VÀO GAME"
    end
end)
