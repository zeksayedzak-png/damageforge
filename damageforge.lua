-- سكريبت: صياد الجزر البعيدة (لـ Blarant/Pets)
local player = game.Players.LocalPlayer

-- 1. الجزر المستهدفة (المواقع التي أرسلتها)
local targetIslands = {
    { name = "Secret1", pos = Vector3.new(3135.0, -3.0, 0.0) },
    { name = "Secret2", pos = Vector3.new(3490.0, -3.0, 0.0) },
    { name = "Secret3", pos = Vector3.new(3853.0, -3.0, 0.0) },
    { name = "Celestial", pos = Vector3.new(4164.5, -3.0, 0.0) }
}

-- 2. وظيفة البحث عن Blarant/Pets فوق الجزر المستهدفة
local function findBlarantOnIslands()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            for _, island in ipairs(targetIslands) do
                -- إذا كان الكائن قريباً من الجزيرة (ضمن مسافة 50)
                if (obj.Position - island.pos).Magnitude < 50 then
                    return obj, island.name
                end
            end
        end
    end
    return nil, nil
end

-- 3. وظيفة "الإمساك" (محاكاة الاقتراب والضغط على الزر)
local function catchBlarant()
    local blarant, islandName = findBlarantOnIslands()
    if not blarant then
        print("❌ لا يوجد Blarant/Pet على الجزر البعيدة حالياً")
        return false
    end
    
    -- محاولة العثور على زر "إمساك" داخل اللعبة
    local catchButton = nil
    for _, btn in ipairs(player.PlayerGui:GetDescendants()) do
        if btn:IsA("TextButton") and (btn.Name:lower():find("catch") or btn.Text:lower():find("امسك")) then
            catchButton = btn
            break
        end
    end
    
    if catchButton then
        -- نقل الشخصية مؤقتاً قريباً من الـ Blarant (لتظهر الزر إذا كان مخفياً)
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local oldPos = hrp and hrp.Position
        if hrp then
            hrp.CFrame = CFrame.new(blarant.Position + Vector3.new(0, 5, 0))
            wait(0.1)
            catchButton:Click()
            wait(0.1)
            hrp.CFrame = CFrame.new(oldPos)
        else
            catchButton:Click()
        end
        print("✅ تم الإمساك بـ " .. (blarant.Name or "Blarant") .. " في جزيرة " .. islandName)
        return true
    else
        print("⚠️ لم يتم العثور على زر الإمساك (قد تكون اللعبة مختلفة)")
        return false
    end
end

-- 4. إنشاء واجهة التحكم (نصف شفافة + قابلة للتحريك)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IslandHunterGUI"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 75)
frame.Position = UDim2.new(0.5, -75, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.6
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 215, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local catchButton = Instance.new("TextButton")
catchButton.Size = UDim2.new(0, 130, 0, 45)
catchButton.Position = UDim2.new(0.5, -65, 0.5, -22)
catchButton.Text = "🎣 إمساك Blarant"
catchButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
catchButton.TextColor3 = Color3.fromRGB(0, 0, 0)
catchButton.Font = Enum.Font.GothamBold
catchButton.TextSize = 12
catchButton.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 140, 0, 18)
label.Position = UDim2.new(0.5, -70, 0, 4)
label.Text = "🔥 صياد الجزر البعيدة"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 215, 0)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- 5. ربط الزر بوظيفة الإمساك
catchButton.MouseButton1Click:Connect(function()
    catchBlarant()
end)

-- 6. مراقبة ظهور Blarant/Pets (إشعار تلقائي)
local function startMonitoring()
    while true do
        local blarant, islandName = findBlarantOnIslands()
        if blarant then
            catchButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            catchButton.Text = "🔥 Blarant موجود! اضغط للإمساك"
        else
            catchButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            catchButton.Text = "🎣 إمساك Blarant"
        end
        wait(2) -- فحص كل 2 ثانية
    end
end

coroutine.wrap(startMonitoring)()
print("✅ صياد الجزر البعيدة يعمل - انتظر ظهور Blarant/Pets")
