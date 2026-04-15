-- سكريبت: جلب Blarant (Teleport Blarant إليك)
local player = game.Players.LocalPlayer

-- 1. الجزر المستهدفة
local targetIslands = {
    Vector3.new(3135.0, 10.0, 0.0),
    Vector3.new(3490.0, 10.0, 0.0),
    Vector3.new(3853.0, 10.0, 0.0),
    Vector3.new(4164.5, 10.0, 0.0)
}

-- 2. البحث عن Blarant
local function findBlarants()
    local blarants = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and not obj.Anchored and not obj.CanCollide then
            for _, islandPos in ipairs(targetIslands) do
                if (obj.Position - islandPos).Magnitude < 150 then
                    table.insert(blarants, obj)
                    break
                end
            end
        end
    end
    return blarants
end

-- 3. جلب Blarant إلى موقعك
local function bringBlarantToMe(blarant)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not blarant then return false end
    
    -- حفظ الموقع الأصلي للـ Blarant (اختياري)
    -- local oldPos = blarant.Position
    
    -- نقل Blarant إلى موقعك
    blarant.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 3, 0))
    
    -- جعل الـ Blarant غير قابل للتصادم (لئلا يزعجك)
    blarant.CanCollide = false
    
    return true
end

-- 4. إنشاء واجهة التحكم
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlarantBringer"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 70)
frame.Position = UDim2.new(0.5, -100, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 165, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 80, 0, 45)
startButton.Position = UDim2.new(0.05, 0, 0.5, -22)
startButton.Text = "▶ تشغيل"
startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
startButton.TextColor3 = Color3.fromRGB(0, 0, 0)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 12
startButton.Parent = frame

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 80, 0, 45)
stopButton.Position = UDim2.new(0.55, 0, 0.5, -22)
stopButton.Text = "⏹ إيقاف"
stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 12
stopButton.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 190, 0, 18)
label.Position = UDim2.new(0.5, -95, 0, 4)
label.Text = "🌀 جلب Blarant"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 165, 0)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- 5. منطق التشغيل
local active = false
local currentTarget = nil
local bringerCoroutine = nil

local function bringer()
    while active do
        local blarants = findBlarants()
        if #blarants == 0 then
            currentTarget = nil
            label.Text = "🌀 لا يوجد Blarant"
            wait(1)
        else
            if not currentTarget or not currentTarget.Parent then
                currentTarget = blarants[math.random(1, #blarants)]
                label.Text = "🎯 جلب Blarant إليك"
            end
            
            -- جلب الـ Blarant إليك
            bringBlarantToMe(currentTarget)
            wait(0.5) -- انتظر نصف ثانية قبل البحث عن التالي
        end
    end
    label.Text = "🌀 متوقف"
end

startButton.MouseButton1Click:Connect(function()
    if active then return end
    active = true
    if bringerCoroutine then coroutine.close(bringerCoroutine) end
    bringerCoroutine = coroutine.wrap(bringer)
    bringerCoroutine()
end)

stopButton.MouseButton1Click:Connect(function()
    active = false
end)

print("✅ سكريبت جلب Blarant يعمل - اضغط 'تشغيل' ليأتي Blarant إليك")
