-- سكريبت: الاختطاف السريع (نقل، إمساك، عودة في 0.5 ثانية)
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- 1. الجزر المستهدفة (مواقع Blarant التقريبية)
local targetIslands = {
    Vector3.new(3135.0, 10.0, 0.0), -- Secret1
    Vector3.new(3490.0, 10.0, 0.0), -- Secret2
    Vector3.new(3853.0, 10.0, 0.0), -- Secret3
    Vector3.new(4164.5, 10.0, 0.0)  -- Celestial
}

-- 2. البحث عن Blarant (أقرب قطعة غير مثبتة)
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

-- 3. وظيفة الاختطاف السريع
local function rapidAbduct()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local blarant = findNearestBlarant()
    if not hrp or not blarant then
        print("❌ لا يوجد Blarant قريب")
        return false
    end
    
    -- حفظ الموقع الأصلي
    local oldPos = hrp.CFrame
    
    -- النقل إلى موقع Blarant
    hrp.CFrame = CFrame.new(blarant.Position + Vector3.new(0, 5, 0))
    runService.Heartbeat:Wait() -- انتظر إطار واحد
    
    -- البحث عن زر الإمساك والضغط عليه
    local catchButton = nil
    for _, btn in ipairs(player.PlayerGui:GetDescendants()) do
        if btn:IsA("TextButton") and (btn.Name:lower():find("catch") or btn.Text:lower():find("امسك")) then
            catchButton = btn
            break
        end
    end
    
    if catchButton then
        catchButton:Click()
    end
    
    -- العودة الفورية
    hrp.CFrame = oldPos
    
    print(catchButton and "✅ تم الإمساك بـ Blarant" or "⚠️ لم يتم العثور على زر الإمساك")
    return catchButton ~= nil
end

-- 4. إنشاء واجهة التحكم
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RapidAbductGUI"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 70)
frame.Position = UDim2.new(0.5, -75, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local abductButton = Instance.new("TextButton")
abductButton.Size = UDim2.new(0, 130, 0, 45)
abductButton.Position = UDim2.new(0.5, -65, 0.5, -22)
abductButton.Text = "⚡ اختطاف سريع"
abductButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
abductButton.TextColor3 = Color3.fromRGB(255, 255, 255)
abductButton.Font = Enum.Font.GothamBold
abductButton.TextSize = 12
abductButton.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 140, 0, 18)
label.Position = UDim2.new(0.5, -70, 0, 4)
label.Text = "⚡ اختطاف وإمساك فوري"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 0, 0)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- 5. ربط الزر
abductButton.MouseButton1Click:Connect(function()
    abductButton.Text = "⏳ جاري..."
    abductButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    rapidAbduct()
    wait(0.5)
    abductButton.Text = "⚡ اختطاف سريع"
    abductButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end)

print("✅ سكريبت الاختطاف السريع يعمل - اضغط على الزر لاختطاف Blarant والعودة")
