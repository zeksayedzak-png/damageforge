-- سكريبت: Rapid Stalker V2 (أقصى سرعة)
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

local targetIslands = {
    Vector3.new(3135.0, 10.0, 0.0),
    Vector3.new(3490.0, 10.0, 0.0),
    Vector3.new(3853.0, 10.0, 0.0),
    Vector3.new(4164.5, 10.0, 0.0)
}

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

local function rapidTeleport(targetPos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local oldPos = hrp.CFrame
    hrp.CFrame = CFrame.new(targetPos)
    runService.Heartbeat:Wait()
    hrp.CFrame = oldPos
end

-- واجهة التحكم
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RapidStalkerV2"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 70)
frame.Position = UDim2.new(0.5, -100, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 255)
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
label.Text = "⚡ أقصى سرعة"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0, 255, 255)
label.TextSize = 11
label.Font = Enum.Font.Gotham
label.Parent = frame

-- منطق التشغيل (أقصى سرعة = بدون wait)
local active = false
local currentTarget = nil
local stalkerCoroutine = nil

local function stalk()
    while active do
        local blarants = findBlarants()
        if #blarants == 0 then
            currentTarget = nil
            label.Text = "⚡ لا يوجد Blarant"
            wait(0.5) -- هذا الـ wait ضروري حتى لا يستهلك المعالج بدون فائدة
        else
            if not currentTarget or not currentTarget.Parent then
                currentTarget = blarants[math.random(1, #blarants)]
                label.Text = "🎯 ملاحقة Blarant"
            end
            
            -- النقل بأقصى سرعة (بدون أي wait بين النقلات)
            rapidTeleport(currentTarget.Position + Vector3.new(0, 5, 0))
            -- لا يوجد wait هنا ← أقصى سرعة ممكنة
        end
    end
    currentTarget = nil
    label.Text = "⚡ متوقف"
end

startButton.MouseButton1Click:Connect(function()
    if active then return end
    active = true
    if stalkerCoroutine then coroutine.close(stalkerCoroutine) end
    stalkerCoroutine = coroutine.wrap(stalk)
    stalkerCoroutine()
end)

stopButton.MouseButton1Click:Connect(function()
    active = false
end)

print("✅ أقصى سرعة - اضغط 'تشغيل'")
