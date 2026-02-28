-- [[V1 - UI Giao diện mới]] --
local URL_RAW_KEY = "https://raw.githubusercontent.com/Vfjfhdhdj/nd/refs/heads/main/key.txt"
local MY_GETKEY_LINK = "https://link4m.com/EOmecR" -- link rút gọn
local SCRIPT_CHINH = "https://raw.githubusercontent.com/Vfjfhdhdj/script/main/script.lua"

-- [[ui - components]] --
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
local UIStroke = Instance.new("UIStroke") -- Thêm viền cho đẹp

-- Setup ScreenGui
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "KeySystem_V1"

-- Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35) -- Màu tối sáng hơn tí
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -85)
MainFrame.Size = UDim2.new(0, 250, 0, 170)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 10) -- Bo góc nhiều hơn
UICorner.Parent = MainFrame

-- Viền UI
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 1

-- Title
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "X-Script System" -- Chữ hoa chữ thường nhìn đẹp hơn
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

-- Box nhập Key
KeyInput.Name = "KeyInput"
KeyInput.Parent = MainFrame
KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50) -- Màu nền box
KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Nhập key tại đây..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(220, 220, 220)
KeyInput.TextSize = 14
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)

UICorner_2.CornerRadius = UDim.new(0, 6)
UICorner_2.Parent = KeyInput

-- Nút Check
CheckBtn.Name = "CheckBtn"
CheckBtn.Parent = MainFrame
CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100) -- Màu xanh tươi hơn
CheckBtn.Position = UDim2.new(0.1, 0, 0.62, 0)
CheckBtn.Size = UDim2.new(0.38, 0, 0, 35)
CheckBtn.Font = Enum.Font.GothamMedium
CheckBtn.Text = "load key" -- Chữ thường
CheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckBtn.TextSize = 13

UICorner_3.CornerRadius = UDim.new(0, 6)
UICorner_3.Parent = CheckBtn

-- Nút Get Key (Copy Link)
CopyBtn.Name = "CopyBtn"
CopyBtn.Parent = MainFrame
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 190) -- Màu xanh dương đẹp hơn
CopyBtn.Position = UDim2.new(0.52, 0, 0.62, 0)
CopyBtn.Size = UDim2.new(0.38, 0, 0, 35)
CopyBtn.Font = Enum.Font.GothamMedium
CopyBtn.Text = "copy link" -- Chữ thường
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 13

UICorner_4.CornerRadius = UDim.new(0, 6)
UICorner_4.Parent = CopyBtn

-- [[ XỬ LÝ LOGIC ]] --

-- Hàm Copy Link Get Key
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(MY_GETKEY_LINK)
        CopyBtn.Text = "Đã copy!"
        wait(1.5)
        CopyBtn.Text = "copy link"
    else
        CopyBtn.Text = "Lỗi copy"
        wait(1.5)
        CopyBtn.Text = "copy link"
    end
end)

-- Hàm Kiểm Tra và Load Script
CheckBtn.MouseButton1Click:Connect(function()
    local input = KeyInput.Text
    CheckBtn.Text = "Đang check..."
    
    -- Lấy Key từ GitHub
    local success, serverKey = pcall(function()
        return game:HttpGet(URL_RAW_KEY .. "?t=" .. os.time())
    end)
    
    if success then
        serverKey = serverKey:gsub("%s+", "") -- Loại bỏ khoảng trắng/xuống dòng
        
        if input == serverKey then
            CheckBtn.Text = "Thành công!"
            CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            wait(1)
            ScreenGui:Destroy() -- Xóa UI Get Key
            
            -- CHẠY SCRIPT CHÍNH CỦA BẠN
            local runScript = pcall(function()
                loadstring(game:HttpGet(SCRIPT_CHINH))()
            end)
            
            if not runScript then
                warn("Lỗi khi load script chính")
            end
        else
            CheckBtn.Text = "Sai key"
            CheckBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            wait(1.5)
            CheckBtn.Text = "load key"
            CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        end
    else
        CheckBtn.Text = "Lỗi kết nối"
        warn("Không thể lấy dữ liệu từ GitHub. Kiểm tra lại link Raw!")
        wait(1.5)
        CheckBtn.Text = "load key"
    end
end)
