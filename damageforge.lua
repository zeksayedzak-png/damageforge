-- سكريبت: Ghost Stalker (إيهام اللعبة بأنك فوق Blarant)
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

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

-- 3. إيهام اللعبة (دون تحريك الشخصية)
local function fakePosition(blarantPos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- حفظ الموقع الحقيقي
    local realPos = hrp.CFrame
    
    -- إيهام اللعبة (نغير الموقع للحظة ثم نعيده فوراً)
    hrp.CFrame = CFrame.new(blarantPos + Vector3.new(0, 5, 0))
    runService.RenderStepped:Wait() -- أسرع من Heartbeat
    hrp.CFrame = realPos
end

-- 4. إنشاء واجهة التحكم
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostStalker"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 80)
frame.Position = UDim2.new(0.5, -90, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(150, 0, 255)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 70, 0, 45)
startButton.Position = UDim2.new(0.05, 0, 0.5, -22)
startButton.Text = "👻 تشغيل"
startButton.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 12
startButton.Parent = frame

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0, 70, 0, 45)
stopButton.Position = UDim2.new(0.55, 0, 0.5, -22)
stopButton.Text = "⏹ إيقاف"
stopButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 12
stopButton.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 170, 0, 18)
label.Position = UDim2.new(0.5, -85, 0, 4)
label.Text = "👻 وضع الشبح (إيهام)"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(150, 0, 255)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- 5. منطق التشغيل (إيهام مستمر)
local active = false
local currentTarget = nil
local ghostCoroutine = nil

local function ghostMode()
    while active do
        local blarants = findBlarants()
        if #blarants == 0 then
            currentTarget = nil
            label.Text = "👻 لا يوجد Blarant"
            wait(0.5)
        else
            if not currentTarget or not currentTarget.Parent then
                currentTarget = blarants[math.random(1, #blarants)]
                label.Text = "🎯 إيهام فوق Blarant"
            end
            
            -- إيهام اللعبة بأنك فوق Blarant (كل 0.3 ثانية)
            fakePosition(currentTarget.Position)
            wait(0.3) -- يكفي لإظهار زر الإمساك (بدون إرهاق اللعبة)
        end
    end
    currentTarget = nil
    label.Text = "👻 متوقف"
end

startButton.MouseButton1Click:Connect(function()
    if active then return end
    active = true
    if ghostCoroutine then coroutine.close(ghostCoroutine) end
    ghostCoroutine = coroutine.wrap(ghostMode)
    ghostCoroutine()
end)

stopButton.MouseButton1Click:Connect(function()
    active = false
end)

print("✅ وضع الشبح يعمل - اضغط 'تشغيل' لإيهام اللعبة بأنك فوق Blarant")
