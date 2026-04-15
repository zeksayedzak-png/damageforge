-- سكريبت: Rapid Stalker V3 (ثانية رايح + ثانية جاي)
local player = game.Players.LocalPlayer
local tweenService = game:GetService("TweenService")

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

-- 3. النقل بسرعة ثابتة (Tween)
local function smoothTeleport(targetPos, duration)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = tweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
end

-- 4. إنشاء واجهة التحكم
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RapidStalkerV3"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 70)
frame.Position = UDim2.new(0.5, -100, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
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
label.Text = "🐌 ملاحقة بطيئة (ثانية/ثانية)"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0, 255, 255)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- 5. منطق التشغيل
local active = false
local currentTarget = nil
local stalkerCoroutine = nil

local function stalk()
    while active do
        local blarants = findBlarants()
        if #blarants == 0 then
            currentTarget = nil
            label.Text = "🐌 لا يوجد Blarant"
            wait(1)
        else
            if not currentTarget or not currentTarget.Parent then
                currentTarget = blarants[math.random(1, #blarants)]
                label.Text = "🎯 ملاحقة Blarant"
            end
            
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local startPos = hrp.Position
                local targetPos = currentTarget.Position + Vector3.new(0, 5, 0)
                
                -- الذهاب إلى Blarant (ثانية واحدة)
                smoothTeleport(targetPos, 1)
                
                -- العودة إلى نقطة البداية (ثانية واحدة)
                smoothTeleport(startPos, 1)
            end
            
            wait(0.1) -- استراحة قصيرة بين الدورات
        end
    end
    currentTarget = nil
    label.Text = "🐌 متوقف"
end

startButton.MouseButton1Click:Connect(function()
    if active then return end
    active = true
    if stalkerCoroutine then coroutine.close(stalkerCoroutine) end
    stalkerCoroutine = coroutine.wrap(stalk)
    stalkerCoroutine()
end)

stopButton.MouseButton1Click:Connect(function()
    active = false
end)

print("✅ سكريبت الملاحقة البطيئة يعمل - اضغط 'تشغيل' للبدء")
