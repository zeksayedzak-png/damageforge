-- سكريبت: إظهار زر الإمساك المخفي عن بُعد (بدون تحريك)
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- 1. الجزر المستهدفة (مواقع الأجزاء التي أرسلتها)
local targetIslands = {
    Vector3.new(3135.0, -3.0, 0.0), -- Secret1
    Vector3.new(3490.0, -3.0, 0.0), -- Secret2
    Vector3.new(3853.0, -3.0, 0.0), -- Secret3
    Vector3.new(4164.5, -3.0, 0.0)  -- Celestial
}

-- 2. البحث عن أي Blarant (أي Part غير مثبت وغير متصادم فوق الجزر)
local function findBlarant()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and not obj.Anchored and not obj.CanCollide then
            for _, islandPos in ipairs(targetIslands) do
                if (obj.Position - islandPos).Magnitude < 150 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- 3. خداع المسافة (دون تحريك الشخصية مرئياً)
local function fakeProximity()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local blarant = findBlarant()
    if not hrp or not blarant then return end
    
    -- حفظ الموقع الأصلي
    local oldPos = hrp.Position
    local oldCF = hrp.CFrame
    
    -- نقل الشخصية (لخداع اللعبة) وإعادتها فوراً (أسرع من أن يراه اللاعب)
    hrp.CFrame = CFrame.new(blarant.Position + Vector3.new(0, 5, 0))
    runService.Heartbeat:Wait() -- انتظر إطار واحد فقط
    hrp.CFrame = oldCF
end

-- 4. إنشاء واجهة التحكم (نصف شفافة، قابلة للتحريك)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlarantHelper"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 70)
frame.Position = UDim2.new(0.5, -80, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 215, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 140, 0, 45)
toggleButton.Position = UDim2.new(0.5, -70, 0.5, -22)
toggleButton.Text = "🔘 تفعيل الإيهام"
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 150, 0, 18)
statusLabel.Position = UDim2.new(0.5, -75, 0, 4)
statusLabel.Text = "⚪ غير نشط"
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

-- 5. منطق التشغيل
local active = false
local monitoringCoroutine = nil

local function startMonitoring()
    while active do
        local blarant = findBlarant()
        if blarant then
            -- إظهار الزر الأصلي (بخداع المسافة)
            fakeProximity()
            statusLabel.Text = "🟢 نشط (Blarant موجود)"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            statusLabel.Text = "🟡 نشط (بلا Blarant)"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        end
        wait(0.5) -- التكرار كل نصف ثانية
    end
    statusLabel.Text = "⚪ غير نشط"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
end

toggleButton.MouseButton1Click:Connect(function()
    active = not active
    if active then
        toggleButton.Text = "🔴 إيقاف الإيهام"
        statusLabel.Text = "🟢 جاري التفعيل..."
        if monitoringCoroutine then coroutine.close(monitoringCoroutine) end
        monitoringCoroutine = coroutine.wrap(startMonitoring)
        monitoringCoroutine()
    else
        toggleButton.Text = "🔘 تفعيل الإيهام"
        statusLabel.Text = "⚪ غير نشط"
        if monitoringCoroutine then coroutine.close(monitoringCoroutine) end
    end
end)

print("✅ سكريبت إظهار الزر المخفي يعمل - اضغط 'تفعيل الإيهام'")
