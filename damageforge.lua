-- سكريبت: إظهار زر الإمساك عن بُعد (بدون تحريك)
local player = game.Players.LocalPlayer

-- 1. الجزر المستهدفة
local targetIslands = {
    Vector3.new(3135.0, -3.0, 0.0), -- Secret1
    Vector3.new(3490.0, -3.0, 0.0), -- Secret2
    Vector3.new(3853.0, -3.0, 0.0), -- Secret3
    Vector3.new(4164.5, -3.0, 0.0)  -- Celestial
}

-- 2. البحث عن Blarant
local function findBlarant()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Size == Vector3.new(3.3, 6.6, 7.6) then
            for _, islandPos in ipairs(targetIslands) do
                if (obj.Position - islandPos).Magnitude < 150 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- 3. إنشاء زر "إمساك" وهمي (يحاكي الزر الأصلي)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FakeCatchButton"
screenGui.Parent = player.PlayerGui

local catchButton = Instance.new("TextButton")
catchButton.Size = UDim2.new(0, 200, 0, 60)
catchButton.Position = UDim2.new(0.5, -100, 0.7, 0)
catchButton.Text = "🎣 إمساك Blarant"
catchButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
catchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
catchButton.Font = Enum.Font.GothamBold
catchButton.TextSize = 18
catchButton.Visible = false -- مخفي في البداية
catchButton.Parent = screenGui

-- 4. وظيفة "الإمساك" (استدعاء حدث اللعبة)
local function catchBlarant()
    local blarant = findBlarant()
    if not blarant then
        print("❌ لا يوجد Blarant")
        return
    end
    
    -- محاولة استدعاء RemoteEvent الخاص باللعبة (لإمساك Blarant)
    local success = false
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("catch") or obj.Name:lower():find("blarant")) then
            obj:FireServer(blarant)
            success = true
            print("✅ تم إمساك Blarant عبر RemoteEvent")
            break
        end
    end
    
    if not success then
        print("⚠️ لم يتم العثور على RemoteEvent (قد تحتاج إلى زر أصلي)")
    end
end

-- 5. ربط الزر بوظيفة الإمساك
catchButton.MouseButton1Click:Connect(catchBlarant)

-- 6. مراقبة ظهور Blarant (لإظهار/إخفاء الزر)
local function startMonitoring()
    while true do
        local blarant = findBlarant()
        catchButton.Visible = (blarant ~= nil)
        wait(1)
    end
end

coroutine.wrap(startMonitoring)()

print("✅ سكريبت الزر عن بُعد يعمل - الزر سيظهر تلقائياً عند وجود Blarant")
