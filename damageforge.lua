-- سكريبت: اعتراض الـ Blarant فور ظهوره ونقله إليك
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- 1. الجزر المستهدفة (حيث يرسبن الـ Blarant عادة)
local targetIslands = {
    Vector3.new(3135.0, 10.0, 0.0),
    Vector3.new(3490.0, 10.0, 0.0),
    Vector3.new(3853.0, 10.0, 0.0),
    Vector3.new(4164.5, 10.0, 0.0)
}

-- 2. التحقق مما إذا كان الـ Blarant قد رسبن فوق الجزر
local function isBlarantOnIslands(blarant)
    for _, islandPos in ipairs(targetIslands) do
        if (blarant.Position - islandPos).Magnitude < 150 then
            return true
        end
    end
    return false
end

-- 3. نقل الـ Blarant إلى مكانك فوراً
local function teleportBlarantToMe(blarant)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- نقل الـ Blarant إلى موقعك (أمامك مباشرة)
    blarant.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 3, 0))
    blarant.CanCollide = false -- حتى لا يزعجك
    print("✅ تم اعتراض Blarant ونقله إليك")
end

-- 4. مراقبة الأجزاء الجديدة التي تظهر في الـ workspace
local function startMonitoring()
    workspace.ChildAdded:Connect(function(child)
        -- انتظر قليلاً حتى يتم تهيئة الـ Part بالكامل
        task.wait(0.1)
        
        -- إذا كان الطفل جزءاً (Part) وغير مثبت وغير متصادم
        if child:IsA("Part") and not child.Anchored and not child.CanCollide then
            if isBlarantOnIslands(child) then
                teleportBlarantToMe(child)
            end
        end
    end)
    
    -- أيضاً مراقبة الأجزاء التي تضاف داخل أجزاء أخرى (مثل Model)
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Part") and not descendant.Anchored and not descendant.CanCollide then
            task.wait(0.1)
            if isBlarantOnIslands(descendant) then
                teleportBlarantToMe(descendant)
            end
        end
    end)
end

-- 5. إنشاء واجهة التحكم (للعلم فقط، لا تحتاج إلى أزرار)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlarantInterceptor"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 50)
frame.Position = UDim2.new(0.5, -110, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 200, 0, 30)
label.Position = UDim2.new(0.5, -100, 0.5, -15)
label.Text = "💀 اعتراض Blarant (شغال)"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 0, 0)
label.TextSize = 12
label.Font = Enum.Font.GothamBold
label.Parent = frame

-- تشغيل المراقبة
startMonitoring()

print("✅ سكريبت اعتراض الـ Blarant يعمل - أي Blarant يرسبن سيأتي إليك فوراً")
