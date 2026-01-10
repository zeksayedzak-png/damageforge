-- ⚡ PICKAXE HITBOX AUTO-MERGER ⚡
-- يدمج هيتبوكس الـPickaxe عن بعد
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PickaxeHitboxMerger"
screenGui.Parent = game.CoreGui

-- ========== PART 1: PICKAXE HITBOX DETECTION ==========
local function findPickaxeHitbox()
    -- البحث عن هيتبوكس الـPickaxe في Workspace
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA("Part") then
            -- تحقق إذا كان هيتبوكس الـPickaxe
            if isPickaxeHitbox(part) then
                return part
            end
        end
    end
    return nil
end

local function isPickaxeHitbox(part)
    -- المعايير:
    -- 1. اسم Hitbox
    if not (part.Name == "Hitbox" or part.Name:find("HitBox")) then
        return false
    end
    
    -- 2. اللون الأحمر النموذجي (1.00, 0.35, 0.35)
    if not (part.Color.R >= 0.9 and part.Color.G <= 0.4 and part.Color.B <= 0.4) then
        return false
    end
    
    -- 3. الخصائص: Anchored = true, CanCollide = false
    if not (part.Anchored == true and part.CanCollide == false) then
        return false
    end
    
    -- 4. الحجم التقريبي (8.1, 7.7, 7.6)
    local size = part.Size
    if not (size.X >= 7 and size.X <= 9 and
            size.Y >= 6 and size.Y <= 8 and
            size.Z >= 6 and size.Z <= 8) then
        return false
    end
    
    return true
end

-- ========== PART 2: MERGE SYSTEM ==========
local function mergePickaxeHitboxes(hitbox1, hitbox2)
    -- إنشاء هيتبوكس مدمج جديد
    local mergedHitbox = hitbox1:Clone()
    
    -- تحديد الخصائص المدمجة
    local newSize = Vector3.new(
        (hitbox1.Size.X + hitbox2.Size.X) / 2,
        (hitbox1.Size.Y + hitbox2.Size.Y) / 2,
        (hitbox1.Size.Z + hitbox2.Size.Z) / 2
    )
    
    local newPosition = Vector3.new(
        (hitbox1.Position.X + hitbox2.Position.X) / 2,
        (hitbox1.Position.Y + hitbox2.Position.Y) / 2,
        (hitbox1.Position.Z + hitbox2.Position.Z) / 2
    )
    
    local newColor = Color3.new(
        (hitbox1.Color.R + hitbox2.Color.R) / 2,
        (hitbox1.Color.G + hitbox2.Color.G) / 2,
        (hitbox1.Color.B + hitbox2.Color.B) / 2
    )
    
    -- تطبيق الخصائص الجديدة
    mergedHitbox.Size = newSize
    mergedHitbox.Position = newPosition
    mergedHitbox.Color = newColor
    mergedHitbox.Name = "Hitbox_MERGED_" .. HttpService:GenerateGUID(false)
    
    -- إضافة بيانات الدمج
    local mergeData = Instance.new("StringValue")
    mergeData.Name = "MergeData"
    mergeData.Value = HttpService:JSONEncode({
        mergedFrom = {hitbox1.Name, hitbox2.Name},
        originalSizes = {hitbox1.Size, hitbox2.Size},
        originalPositions = {hitbox1.Position, hitbox2.Position},
        mergeTime = os.time()
    })
    mergeData.Parent = mergedHitbox
    
    return mergedHitbox
end

-- ========== PART 3: REMOTE MERGE AT DISTANCE ==========
local function remoteMergeAtDistance(distance)
    local origin = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return 0 end
    
    -- البحث عن جميع هيتبوكسات الـPickaxe في المدى
    local hitboxesInRange = {}
    
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA("Part") and isPickaxeHitbox(part) then
            local distanceToHitbox = (origin.Position - part.Position).Magnitude
            if distanceToHitbox <= distance then
                table.insert(hitboxesInRange, part)
            end
        end
    end
    
    -- دمج الهيتبوكسات في أزواج
    local mergesDone = 0
    
    for i = 1, #hitboxesInRange - 1, 2 do
        local hitbox1 = hitboxesInRange[i]
        local hitbox2 = hitboxesInRange[i + 1]
        
        if hitbox1 and hitbox2 then
            -- إنشاء هيتبوكس مدمج
            local mergedHitbox = mergePickaxeHitboxes(hitbox1, hitbox2)
            
            -- وضع الهيتبوكس الجديد في Workspace
            mergedHitbox.Parent = Workspace
            
            -- إزالة الهيتبوكسات الأصلية
            hitbox1:Destroy()
            hitbox2:Destroy()
            
            mergesDone = mergesDone + 1
            
            -- تأثير بصرية للدمج
            createMergeEffect(mergedHitbox.Position)
        end
    end
    
    return mergesDone
end

-- ========== PART 4: TARGETED MERGE ==========
local function targetedMerge(distance, maxMerges)
    local origin = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return 0 end
    
    -- الحصول على الهيتبوكس الأقرب
    local closestHitbox = nil
    local closestDistance = math.huge
    
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA("Part") and isPickaxeHitbox(part) then
            local dist = (origin.Position - part.Position).Magnitude
            if dist < closestDistance and dist <= distance then
                closestDistance = dist
                closestHitbox = part
            end
        end
    end
    
    if not closestHitbox then return 0 end
    
    -- البحث عن هيتبوكس آخر قريب من الهيتبوكس الأقرب
    local secondHitbox = nil
    local secondDistance = math.huge
    
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA("Part") and isPickaxeHitbox(part) and part ~= closestHitbox then
            local dist = (closestHitbox.Position - part.Position).Magnitude
            if dist < secondDistance and dist <= 20 then -- مدى 20 ستاد حول الهيتبوكس
                secondDistance = dist
                secondHitbox = part
            end
        end
    end
    
    if not secondHitbox then return 0 end
    
    -- الدمج
    local mergedHitbox = mergePickaxeHitboxes(closestHitbox, secondHitbox)
    mergedHitbox.Parent = Workspace
    
    closestHitbox:Destroy()
    secondHitbox:Destroy()
    
    createMergeEffect(mergedHitbox.Position)
    
    return 1
end

-- ========== PART 5: VISUAL EFFECTS ==========
local function createMergeEffect(position)
    -- تأثير جزيئات الدمج
    local particles = Instance.new("Part")
    particles.Name = "MergeEffect"
    particles.Size = Vector3.new(5, 5, 5)
    particles.Position = position
    particles.Color = Color3.new(1, 0.5, 0)
    particles.Material = Enum.Material.Neon
    particles.Anchored = true
    particles.CanCollide = false
    particles.Transparency = 0.5
    particles.Parent = Workspace
    
    -- توهج
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 10
    pointLight.Range = 15
    pointLight.Color = Color3.new(1, 0.3, 0)
    pointLight.Parent = particles
    
    -- إزالة التأثير بعد 2 ثانية
    game.Debris:AddItem(particles, 2)
end

-- ========== PART 6: GUI INTERFACE ==========
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.3, 0, 0.35, 0)
mainFrame.Position = UDim2.new(0.65, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 15, 20)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(1, 0.3, 0.3)
mainFrame.Parent = screenGui

-- العنوان
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0.15, 0)
titleBar.BackgroundColor3 = Color3.new(1, 0.3, 0.3)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "⛏️ PICKAXE HITBOX MERGER"
title.Size = UDim2.new(0.9, 0, 1, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Parent = titleBar

-- إدخال المسافة
local distanceFrame = Instance.new("Frame")
distanceFrame.Size = UDim2.new(0.9, 0, 0.15, 0)
distanceFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
distanceFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 25)
distanceFrame.Parent = mainFrame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Text = "📏 DISTANCE:"
distanceLabel.Size = UDim2.new(0.5, 0, 1, 0)
distanceLabel.TextColor3 = Color3.new(1, 1, 1)
distanceLabel.BackgroundTransparency = 1
distanceLabel.Font = Enum.Font.SourceSansBold
distanceLabel.Parent = distanceFrame

local distanceInput = Instance.new("TextBox")
distanceInput.Text = "50"
distanceInput.Size = UDim2.new(0.4, 0, 0.7, 0)
distanceInput.Position = UDim2.new(0.55, 0, 0.15, 0)
distanceInput.BackgroundColor3 = Color3.fromRGB(60, 30, 35)
distanceInput.TextColor3 = Color3.new(1, 1, 1)
distanceInput.Font = Enum.Font.SourceSansBold
distanceInput.Parent = distanceFrame

-- زر المسح
local scanBtn = Instance.new("TextButton")
scanBtn.Text = "🔍 SCAN HITBOXES"
scanBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
scanBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
scanBtn.BackgroundColor3 = Color3.new(0, 0.5, 1)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Font = Enum.Font.SourceSansBold
scanBtn.Parent = mainFrame

-- زر الدمج عن بعد
local mergeBtn = Instance.new("TextButton")
mergeBtn.Text = "⚡ REMOTE MERGE"
mergeBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
mergeBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
mergeBtn.BackgroundColor3 = Color3.new(1, 0.5, 0)
mergeBtn.TextColor3 = Color3.new(1, 1, 1)
mergeBtn.Font = Enum.Font.SourceSansBold
mergeBtn.Parent = mainFrame

-- زر الدمج المستهدف
local targetBtn = Instance.new("TextButton")
targetBtn.Text = "🎯 TARGETED MERGE"
targetBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
targetBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
targetBtn.BackgroundColor3 = Color3.new(0.8, 0, 0.8)
targetBtn.TextColor3 = Color3.new(1, 1, 1)
targetBtn.Font = Enum.Font.SourceSansBold
targetBtn.Parent = mainFrame

-- شريط الحالة
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(0.9, 0, 0.1, 0)
statusBar.Position = UDim2.new(0.05, 0, 0.95, 0)
statusBar.BackgroundColor3 = Color3.fromRGB(20, 10, 15)
statusBar.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "✅ READY"
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.TextColor3 = Color3.new(0, 1, 0.5)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Parent = statusBar

-- ========== PART 7: HITBOX COUNTER ==========
local hitboxCount = Instance.new("TextLabel")
hitboxCount.Text = "⛏️ HITBOXES: 0"
hitboxCount.Size = UDim2.new(0.9, 0, 0.1, 0)
hitboxCount.Position = UDim2.new(0.05, 0, 0.35, 0)
hitboxCount.TextColor3 = Color3.new(1, 0.8, 0.5)
hitboxCount.BackgroundTransparency = 1
hitboxCount.Font = Enum.Font.SourceSansBold
hitboxCount.Parent = mainFrame

local function updateHitboxCount()
    local count = 0
    for _, part in pairs(Workspace:GetChildren()) do
        if part:IsA("Part") and isPickaxeHitbox(part) then
            count = count + 1
        end
    end
    hitboxCount.Text = "⛏️ HITBOXES: " .. count
    return count
end

-- ========== PART 8: BUTTON EVENTS ==========

scanBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "🔍 SCANNING..."
    statusLabel.TextColor3 = Color3.new(1, 1, 0)
    
    local count = updateHitboxCount()
    
    statusLabel.Text = "✅ FOUND " .. count .. " HITBOXES"
    statusLabel.TextColor3 = Color3.new(0, 1, 0)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SCAN COMPLETE",
        Text = count .. " Pickaxe Hitboxes found",
        Duration = 3,
    })
end)

mergeBtn.MouseButton1Click:Connect(function()
    local distance = tonumber(distanceInput.Text) or 50
    
    statusLabel.Text = "⚡ MERGING AT " .. distance .. " STUDS..."
    statusLabel.TextColor3 = Color3.new(1, 0.8, 0)
    
    local mergesDone = remoteMergeAtDistance(distance)
    
    statusLabel.Text = "✅ MERGED " .. mergesDone .. " HITBOXES"
    statusLabel.TextColor3 = Color3.new(0, 1, 0)
    
    mergeBtn.Text = "✅ " .. mergesDone .. " MERGED"
    mergeBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
    
    -- تحديث العدد
    updateHitboxCount()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "MERGE COMPLETE",
        Text = mergesDone .. " hitboxes merged",
        Duration = 3,
    })
    
    -- إعادة تعيين الزر
    spawn(function()
        task.wait(2)
        mergeBtn.Text = "⚡ REMOTE MERGE"
        mergeBtn.BackgroundColor3 = Color3.new(1, 0.5, 0)
    end)
end)

targetBtn.MouseButton1Click:Connect(function()
    local distance = tonumber(distanceInput.Text) or 50
    
    statusLabel.Text = "🎯 TARGETING HITBOX..."
    statusLabel.TextColor3 = Color3.new(1, 0.5, 1)
    
    local mergesDone = targetedMerge(distance, 1)
    
    if mergesDone > 0 then
        statusLabel.Text = "✅ TARGET MERGED"
        statusLabel.TextColor3 = Color3.new(0, 1, 0)
        
        targetBtn.Text = "✅ TARGET HIT"
        targetBtn.BackgroundColor3 = Color3.new(0, 0.8, 0)
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TARGET MERGED",
            Text = "Closest hitboxes merged",
            Duration = 3,
        })
    else
        statusLabel.Text = "❌ NO TARGET FOUND"
        statusLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
    end
    
    -- تحديث العدد
    updateHitboxCount()
    
    -- إعادة تعيين
    spawn(function()
        task.wait(2)
        targetBtn.Text = "🎯 TARGETED MERGE"
        targetBtn.BackgroundColor3 = Color3.new(0.8, 0, 0.8)
    end)
end)

-- ========== PART 9: HOTKEY SYSTEM ==========
local UIS = game:GetService("UserInputService")
local hotkey = Enum.KeyCode.P -- زر P للدمج السريع

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == hotkey then
        mergeBtn:MouseButton1Click()
    end
end)

-- ========== PART 10: AUTO UPDATE COUNTER ==========
spawn(function()
    while mainFrame.Parent do
        updateHitboxCount()
        task.wait(2)
    end
end)

-- ========== PART 11: INITIAL SCAN ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "PICKAXE HITBOX MERGER LOADED",
    Text = "Press P to merge hitboxes remotely",
    Duration = 5,
})

-- المسح الأولي
spawn(function()
    task.wait(1)
    scanBtn:MouseButton1Click()
end)
