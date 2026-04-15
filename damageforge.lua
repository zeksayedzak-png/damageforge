-- سكريبت: Rapid Stalker V3 (ملاحقة + إلغاء مؤقت + ضغط تلقائي)
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

-- 3. النقل الخاطف
local function rapidTeleport(targetPos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local oldPos = hrp.CFrame
    hrp.CFrame = CFrame.new(targetPos)
    runService.Heartbeat:Wait()
    hrp.CFrame = oldPos
end

-- 4. إلغاء مؤقت زر الإمساك + الضغط التلقائي
local function handleCatchButton()
    for _, btn in ipairs(player.PlayerGui:GetDescendants()) do
        if btn:IsA("TextButton") and (btn.Name:lower():find("catch") or btn.Text:lower():find("امسك")) then
            -- إلغاء المؤقت
            btn.AutoButtonColor = false
            if btn:FindFirstChild("Debounce") then
                btn.Debounce = false
            end
            -- الضغط التلقائي (بسرعة الضوء)
            btn:Click()
            return true
        end
    end
    return false
end

-- 5. واجهة التحكم
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCatchStalker"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 70)
frame.Position = UDim2.new(0.5, -100, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 255)
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
label.Text = "🤖 ضغط تلقائي + ملاحقة"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 0, 255)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- 6. منطق التشغيل الرئيسي
local active = false
local currentTarget = nil
local mainCoroutine = nil

local function autoCatch()
    while active do
        local blarants = findBlarants()
        if #blarants == 0 then
            currentTarget = nil
            label.Text = "🤖 لا يوجد Blarant"
            wait(0.5)
        else
            if not currentTarget or not currentTarget.Parent then
                currentTarget = blarants[math.random(1, #blarants)]
                label.Text = "🎯 استهداف Blarant"
            end
            
            -- النقل الخاطف
            rapidTeleport(currentTarget.Position + Vector3.new(0, 5, 0))
            
            -- محاولة الضغط على زر الإمساك (بسرعة الضوء)
            local caught = handleCatchButton()
            if caught then
                label.Text = "✅ تم الإمساك! انتظر التالي"
                wait(0.5)
            else
                wait(0.1)
            end
        end
    end
    label.Text = "🤖 متوقف"
end

startButton.MouseButton1Click:Connect(function()
    if active then return end
    active = true
    if mainCoroutine then coroutine.close(mainCoroutine) end
    mainCoroutine = coroutine.wrap(autoCatch)
    mainCoroutine()
end)

stopButton.MouseButton1Click:Connect(function()
    active = false
end)

print("✅ السكريبت يعمل: ملاحقة خاطفة + إلغاء مؤقت + ضغط تلقائي (بسرعة الضوء)")
