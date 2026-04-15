-- سكريبت: النقل العشوائي إلى الجزر البعيدة (لإمساك Blarant يدويًا)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- 1. الجزر المستهدفة (الإحداثيات التي أرسلتها)
local targetIslands = {
    { name = "Secret1", pos = Vector3.new(3135.0, 10.0, 0.0) },  -- رفع y قليلاً لتجنب السقوط
    { name = "Secret2", pos = Vector3.new(3490.0, 10.0, 0.0) },
    { name = "Secret3", pos = Vector3.new(3853.0, 10.0, 0.0) },
    { name = "Celestial", pos = Vector3.new(4164.5, 10.0, 0.0) }
}

-- 2. وظيفة النقل العشوائي
local function teleportToRandomIsland()
    local randomIndex = math.random(1, #targetIslands)
    local target = targetIslands[randomIndex]
    
    if hrp then
        hrp.CFrame = CFrame.new(target.pos)
        print("✅ تم النقل إلى " .. target.name)
    else
        print("❌ لم يتم العثور على HumanoidRootPart")
    end
end

-- 3. إنشاء واجهة التحكم (نصف شفافة، قابلة للتحريك)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 70)
frame.Position = UDim2.new(0.5, -70, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 120, 0, 45)
teleportButton.Position = UDim2.new(0.5, -60, 0.5, -22)
teleportButton.Text = "🌀 نقل عشوائي"
teleportButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
teleportButton.TextColor3 = Color3.fromRGB(0, 0, 0)
teleportButton.Font = Enum.Font.GothamBold
teleportButton.TextSize = 12
teleportButton.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 130, 0, 18)
label.Position = UDim2.new(0.5, -65, 0, 4)
label.Text = "🌀 النقل إلى الجزر"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- 4. ربط الزر بوظيفة النقل
teleportButton.MouseButton1Click:Connect(teleportToRandomIsland)

print("✅ سكريبت النقل العشوائي يعمل - اضغط على الزر للانتقال إلى جزيرة عشوائية")
