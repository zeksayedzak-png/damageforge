-- سكريبت: الطيران تحت الأرض (Y = -2.9 ثابت) + سرعة متغيرة + عودة تلقائية
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

-- 1. الجزر المستهدفة (المواقع التي أرسلتها سابقاً)
local targetIslands = {
    Vector3.new(3135.0, 10.0, 0.0),
    Vector3.new(3490.0, 10.0, 0.0),
    Vector3.new(3853.0, 10.0, 0.0),
    Vector3.new(4164.5, 10.0, 0.0)
}

-- 2. البحث عن أقرب Blarant (Part غير مثبت وغير متصادم فوق الجزر)
local function findNearestBlarant()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local minDist = math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and not obj.Anchored and not obj.CanCollide then
            for _, islandPos in ipairs(targetIslands) do
                if (obj.Position - islandPos).Magnitude < 150 then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = obj
                    end
                    break
                end
            end
        end
    end
    return nearest
end

-- 3. الطيران تحت الأرض (ثابت Y = -2.9)
local function flyToPosition(targetPos, speed, callback)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = hrp.Position
    local target = Vector3.new(targetPos.X, -2.9, targetPos.Z) -- نثبت Y
    
    local distance = (target - startPos).Magnitude
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = tweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(target)})
    tween:Play()
    tween.Completed:Connect(callback)
    return tween
end

-- 4. واجهة التحكم
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnderGroundFlyer"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.7, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- زر تشغيل
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 100, 0, 40)
startButton.Position = UDim2.new(0.05, 0, 0.2, 0)
startButton.Text = "▶ تشغيل"
startButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
startButton.TextColor3 = Color3.fromRGB(0, 0, 0)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 12
startButton.Parent = frame

-- زر إيقاف (رجوع)
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 100, 0, 40)
stopButton.Position = UDim2.new(0.55, 0, 0.2, 0)
stopButton.Text = "⏹ إيقاف (رجوع)"
stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 12
stopButton.Parent = frame

-- زر زيادة السرعة
local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0, 40, 0, 40)
speedUp.Position = UDim2.new(0.05, 0, 0.65, 0)
speedUp.Text = "+"
speedUp.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUp.Font = Enum.Font.GothamBold
speedUp.TextSize = 18
speedUp.Parent = frame

-- زر نقص السرعة
local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0, 40, 0, 40)
speedDown.Position = UDim2.new(0.25, 0, 0.65, 0)
speedDown.Text = "-"
speedDown.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDown.Font = Enum.Font.GothamBold
speedDown.TextSize = 18
speedDown.Parent = frame

-- عرض السرعة الحالية
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 80, 0, 30)
speedLabel.Position = UDim2.new(0.6, 0, 0.7, 0)
speedLabel.Text = "سرعة: 50"
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = frame

-- حالة السكريبت
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 230, 0, 20)
statusLabel.Position = UDim2.new(0.5, -115, 0, 5)
statusLabel.Text = "⚡ طيران تحت الأرض (Y = -2.9)"
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

-- 5. منطق التشغيل
local currentSpeed = 50
local active = false
local startPos = nil
local currentTween = nil

speedLabel.Text = "سرعة: " .. currentSpeed

-- تحديث السرعة
speedUp.MouseButton1Click:Connect(function()
    currentSpeed = currentSpeed + 10
    speedLabel.Text = "سرعة: " .. currentSpeed
end)

speedDown.MouseButton1Click:Connect(function()
    currentSpeed = math.max(10, currentSpeed - 10)
    speedLabel.Text = "سرعة: " .. currentSpeed
end)

-- تشغيل الطيران
startButton.MouseButton1Click:Connect(function()
    if active then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    startPos = hrp.Position -- حفظ نقطة البداية
    local blarant = findNearestBlarant()
    if not blarant then
        statusLabel.Text = "❌ لا يوجد Blarant"
        return
    end
    
    active = true
    statusLabel.Text = "✈️ جارٍ الطيران إلى Blarant..."
    
    currentTween = flyToPosition(blarant.Position, currentSpeed, function()
        if active then
            statusLabel.Text = "✅ وصلت تحت Blarant (Y = -2.9)"
        end
    end)
end)

-- إيقاف والعودة إلى نقطة البداية
stopButton.MouseButton1Click:Connect(function()
    if not active then return end
    active = false
    
    if currentTween then
        currentTween:Cancel()
    end
    
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and startPos then
        statusLabel.Text = "🔄 العودة إلى نقطة البداية..."
        local returnTween = flyToPosition(startPos, currentSpeed, function()
            statusLabel.Text = "🏁 تم العودة"
        end)
    else
        statusLabel.Text = "⚠️ لا يمكن العودة"
    end
end)

print("✅ سكريبت الطيران تحت الأرض يعمل - Y = -2.9 ثابت")
