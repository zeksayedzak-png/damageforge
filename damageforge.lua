-- سكريبت: البحث عن نواة Blarant (للإمساك عن بُعد)
local player = game.Players.LocalPlayer

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

-- البحث عن "نواة" (RemoteEvent أو Value) مرتبطة بـ Blarant
local function findBlarantCore(blarant)
    -- البحث داخل الـ Blarant نفسه
    for _, child in ipairs(blarant:GetChildren()) do
        if child:IsA("RemoteEvent") and child.Name:lower():find("catch") then
            return child, "RemoteEvent"
        elseif child:IsA("IntValue") and child.Name:lower():find("id") then
            return child.Value, "IntValue"
        elseif child:IsA("ObjectValue") then
            return child.Value, "ObjectValue"
        end
    end
    
    -- البحث في الـ workspace عن RemoteEvent مرتبط
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("blarant") then
            return obj, "RemoteEvent (global)"
        end
    end
    return nil, nil
end

-- إنشاء واجهة بسيطة (اختبارية)
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 100)
frame.Position = UDim2.new(0.5, -125, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, -25)
button.Text = "💀 البحث عن نواة Blarant"
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 12
button.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 230, 0, 20)
label.Position = UDim2.new(0.5, -115, 0, 5)
label.Text = "اضغط للبحث عن النواة"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 10
label.Parent = frame

button.MouseButton1Click:Connect(function()
    local blarants = findBlarants()
    if #blarants == 0 then
        label.Text = "❌ لا يوجد Blarant"
        return
    end
    
    for _, blarant in ipairs(blarants) do
        local core, coreType = findBlarantCore(blarant)
        if core then
            label.Text = "✅ وجدت نواة: " .. coreType
            print("Blarant:", blarant.Name, "Core:", core, "Type:", coreType)
        else
            label.Text = "⚠️ لم أجد نواة واضحة"
        end
    end
end)
