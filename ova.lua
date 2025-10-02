-- Simple FPS Booster with Permanent FPS Cap
local TARGET_FPS = 10

if not game:IsLoaded() then
    repeat task.wait() until game:IsLoaded()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ME = Players.LocalPlayer

-- Buat FPS Overlay
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSOverlay"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 100, 0, 40)
frame.Position = UDim2.new(0.5, -50, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 1, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextSize = 14
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.Parent = frame

frame.Parent = screenGui
screenGui.Parent = ME:WaitForChild("PlayerGui")

-- Variables
local frameCount = 0
local lastTime = tick()
local currentFPS = 0
local fpsCheckCounter = 0

-- AGGRESSIVE FPS CAP SYSTEM
local function ForceFPSCap()
    if setfpscap then
        setfpscap(TARGET_FPS)
        return true
    end
    return false
end

-- Apply immediately and multiple times
for i = 1, 5 do
    ForceFPSCap()
    task.wait(0.1)
end

-- MAIN SYSTEM - Single connection untuk semua
RunService.Heartbeat:Connect(function()
    -- FPS Counting
    frameCount = frameCount + 1
    fpsCheckCounter = fpsCheckCounter + 1
    
    local currentTime = tick()
    
    -- Update display setiap 1 detik
    if currentTime - lastTime >= 1 then
        currentFPS = math.floor(frameCount)
        frameCount = 0
        lastTime = currentTime
        
        fpsLabel.Text = "FPS: " .. currentFPS
        
        -- Color coding
        if currentFPS >= TARGET_FPS - 1 then
            fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        elseif currentFPS >= TARGET_FPS - 3 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        else
            fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
    
    -- AGGRESSIVE FPS CAP ENFORCEMENT
    -- Check setiap 2 detik (120 frames) dan force cap
    if fpsCheckCounter >= 120 then
        fpsCheckCounter = 0
        ForceFPSCap()
        
        -- Extra enforcement jika FPS masih tinggi
        if currentFPS > TARGET_FPS + 2 then
            for i = 1, 3 do
                ForceFPSCap()
                task.wait(0.01)
            end
        end
    end
    
    -- EXTRA: Force cap jika FPS terlalu tinggi
    if currentFPS > TARGET_FPS + 5 then
        ForceFPSCap()
    end
end)

-- Additional enforcement loops untuk pastikan cap tetap
-- Loop 1: Every 3 seconds
spawn(function()
    while true do
        ForceFPSCap()
        task.wait(3)
    end
end)

-- Loop 2: Every 5 seconds (backup)
spawn(function()
    while true do
        ForceFPSCap()
        task.wait(5)
    end
end)

-- Loop 3: Every 10 seconds (super backup)
spawn(function()
    while true do
        ForceFPSCap()
        task.wait(10)
    end
end)

-- Re-apply ketika character respawn
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for i = 1, 10 do
        ForceFPSCap()
        task.wait(0.05)
    end
end)

-- Re-apply ketika player join game
game:GetService("ReplicatedFirst").FinishedLoading:Connect(function()
    task.wait(2)
    for i = 1, 5 do
        ForceFPSCap()
        task.wait(0.1)
    end
end)

print("PERMANENT FPS CAP: " .. TARGET_FPS .. " - Multiple Enforcement Systems Active")
