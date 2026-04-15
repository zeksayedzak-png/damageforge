-- سكريبت: خداع المسافة لظهور زر الإمساك (بدون تحريك)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- 1. الجزر المستهدفة
local targetIslands = {
    { name = "Secret1", pos = Vector3.new(3135.0, -3.0, 0.0) },
    { name = "Secret2", pos = Vector3.new(3490.0, -3.0, 0.0) },
    { name = "Secret3", pos = Vector3.new(3853.0, -3.0, 0.0) },
    { name = "Celestial", pos = Vector3.new(4164.5, -3.0, 0.0) }
}

-- 2. البحث عن Blarant (Part بالحجم المحدد)
local function findBlarant()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Size == Vector3.new(3.3, 6.6, 7.6) then
            for _, island in ipairs(targetIslands) do
                if (obj.Position - island.pos).Magnitude < 100 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- 3. وظيفة خداع المسافة (تظهر الزر ثم تختفي)
local function fakeProximity(blarant)
    local oldCFrame = hrp.CFrame
    -- نقل الشخصية مؤقتاً (لخداع اللعبة)
    hrp.CFrame = CFrame.new(blarant.Position + Vector3.new(0, 5, 0))
    wait(0.2) -- مهلة لظهور الزر
    
    -- البحث عن زر الإمساك (الذي ظهر الآن)
    local catchButton = nil
    for _, btn in ipairs(player.PlayerGui:GetDescendants()) do
        if btn:IsA("TextButton") and (btn.Name:lower():find("catch") or btn.Text:lower():find("امسك")) then
            catchButton = btn
            break
        end
    end
    
    if catchButton then
        catchButton:Click() -- الضغط على الزر
        wait(0.1)
    end
    
    -- إعادة الشخصية إلى مكانها الأصلي
    hrp.CFrame = oldCFrame
    return catchButton ~= nil
end

-- 4. إنشاء واجهة التحكم (زر واحد فقط)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FakeProximityGUI"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 70)
frame.Position = UDim2.new(0.5, -80, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.6
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 215, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local catchButton = Instance.new("TextButton")
catchButton.Size = UDim2.new(0, 140, 0, 45)
catchButton.Position = UDim2.new(0.5, -70, 0.5, -22)
catchButton.Text = "🎣 إمساك Blarant"
catchButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
catchButton.TextColor3 = Color3.fromRGB(0, 0, 0)
catchButton.Font = Enum.Font.GothamBold
catchButton.TextSize = 12
catchButton.Parent = frame

-- 5. وظيفة الزر
catchButton.MouseButton1Click:Connect(function()
    local blarant = findBlarant()
    if not blarant then
        print("❌ لا يوجد Blarant حالياً")
        return
    end
    
    print("🔍 محاولة خداع المسافة...")
    local success = fakeProximity(blarant)
    if success then
        print("✅ تم الإمساك بـ Blarant")
        catchButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        wait(1)
        catchButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    else
        print("❌ فشل الإمساك (لم يظهر الزر)")
    end
end)

print("✅ سكريبت خداع المسافة يعمل - اضغط على الزر لظهور زر الإمساك الأصلي")
