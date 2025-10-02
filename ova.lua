_G.Settings = {
    Players = {
        ["Ignore Me"] = true,
        ["Ignore Others"] = true
    },
    Meshes = {
        Destroy = false,
        LowDetail = true
    },
    Images = {
        Invisible = true,
        LowDetail = false,
        Destroy = false
    },
    Other = {
        ["No Particles"] = true,
        ["No Camera Effects"] = true,
        ["No Explosions"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true,
        ["No Shadows"] = true,
        ["Low Rendering"] = true,
        ["Low Quality Parts"] = true,
        ["FPS Cap"] = 10
    }
}

-- Script FPS Booster (Optimized for RAM)
if not _G.Ignore then
    _G.Ignore = {}
end
if _G.SendNotifications == nil then
    _G.SendNotifications = true
end
if _G.ConsoleLogs == nil then
    _G.ConsoleLogs = false
end

if not game:IsLoaded() then
    repeat
        task.wait()
    until game:IsLoaded()
end

-- Cache services sekali saja
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local ME = Players.LocalPlayer

-- Variabel global untuk mengurangi memory allocation
local TargetFPS = 10
local FPSLockEnabled = true
local LastFPSApply = 0
local frameCount = 0
local lastTime = 0
local currentFPS = 0

-- Optimized FPS Overlay (minimal instances)
local function CreateFPSOverlay()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSOverlay"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 100, 0, 40)
    frame.Position = UDim2.new(1, -110, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsLabel.TextScaled = false
    fpsLabel.TextSize = 14
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextStrokeTransparency = 0.5
    fpsLabel.Parent = frame
    
    screenGui.Parent = ME:WaitForChild("PlayerGui")
    
    return fpsLabel
end

-- Cache FPS label
local fpsLabel = CreateFPSOverlay()

-- Optimized FPS cap function (no unnecessary calls)
local function ApplyFPSCap()
    if setfpscap and FPSLockEnabled then
        setfpscap(TargetFPS)
        LastFPSApply = tick()
        return true
    end
    return false
end

-- Optimized FPS counter dengan memory management
local function UpdateFPS()
    frameCount = frameCount + 1
    local currentTime = tick()
    
    if currentTime - lastTime >= 1 then
        currentFPS = math.floor(frameCount / (currentTime - lastTime))
        frameCount = 0
        lastTime = currentTime
        
        -- Update display hanya jika berubah (mengurangi GC)
        if fpsLabel then
            fpsLabel.Text = "FPS: " .. currentFPS
            
            -- Simple color coding
            if currentFPS >= 8 then
                fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif currentFPS >= 5 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end

-- Optimized maintenance dengan interval lebih lama
local function EnsureFPSCap()
    if FPSLockEnabled and tick() - LastFPSApply > 60 then -- 60 detik sekali
        ApplyFPSCap()
    end
end

-- Optimized instance checking dengan table lookup yang efisien
local CanBeEnabled = {
    ParticleEmitter = true,
    Trail = true,
    Smoke = true,
    Fire = true,
    Sparkles = true
}

local function PartOfCharacter(Inst)
    local character = ME.Character
    if character and Inst:IsDescendantOf(character) then
        return false
    end
    
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Inst:IsDescendantOf(v.Character) then
            return true
        end
    end
    return false
end

-- Optimized CheckIfBad function dengan early returns
local function CheckIfBad(Inst)
    -- Early return untuk instances yang tidak perlu diproses
    if Inst:IsDescendantOf(Players) then
        return
    end
    
    if _G.Settings.Players["Ignore Others"] and PartOfCharacter(Inst) then
        return
    end
    
    if _G.Settings.Players["Ignore Me"] and ME.Character and Inst:IsDescendantOf(ME.Character) then
        return
    end
    
    -- Process instances berdasarkan type
    local instType = Inst.ClassName
    
    if Inst:IsA("DataModelMesh") then
        if _G.Settings.Meshes.Destroy then
            Inst:Destroy()
        elseif _G.Settings.Meshes.LowDetail and Inst:IsA("SpecialMesh") then
            Inst.MeshId = ""
            Inst.TextureId = ""
        end
        
    elseif Inst:IsA("FaceInstance") then
        if _G.Settings.Images.Invisible then
            Inst.Transparency = 1
        elseif _G.Settings.Images.Destroy then
            Inst:Destroy()
        end
        
    elseif Inst:IsA("ShirtGraphic") then
        if _G.Settings.Images.Invisible then
            Inst.Graphic = ""
        elseif _G.Settings.Images.Destroy then
            Inst:Destroy()
        end
        
    elseif CanBeEnabled[instType] then
        if _G.Settings.Other["No Particles"] then
            Inst.Enabled = false
        end
        
    elseif Inst:IsA("PostEffect") and _G.Settings.Other["No Camera Effects"] then
        Inst.Enabled = false
        
    elseif Inst:IsA("Explosion") and _G.Settings.Other["No Explosions"] then
        Inst:Destroy()
        
    elseif (Inst:IsA("Clothing") or Inst:IsA("SurfaceAppearance")) and _G.Settings.Other["No Clothes"] then
        Inst:Destroy()
        
    elseif Inst:IsA("BasePart") and _G.Settings.Other["Low Quality Parts"] then
        Inst.Material = Enum.Material.Plastic
        Inst.Reflectance = 0
    end
end

-- Apply settings dengan garbage collection
local function ApplySettings()
    -- FPS Cap
    if _G.Settings.Other["FPS Cap"] then
        ApplyFPSCap()
    end
    
    -- Graphics Settings (hanya sekali di awal)
    if _G.Settings.Other["Low Water Graphics"] then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
    end
    
    if _G.Settings.Other["No Shadows"] then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end
    
    if _G.Settings.Other["Low Rendering"] then
        settings().Rendering.QualityLevel = 1
    end
    
    -- Process existing instances dengan batch processing
    local Descendants = game:GetDescendants()
    for i = 1, #Descendants do
        CheckIfBad(Descendants[i])
        -- Yield setiap 1000 instances untuk mencegah lag
        if i % 1000 == 0 then
            task.wait()
        end
    end
end

-- Apply settings sekali di awal
ApplySettings()

-- Optimized descendant handler dengan debouncing
local descendantDebounce = false
game.DescendantAdded:Connect(function(Inst)
    if descendantDebounce then return end
    descendantDebounce = true
    
    task.wait(0.5) -- Debounce time
    CheckIfBad(Inst)
    
    descendantDebounce = false
end)

-- Single notification
if _G.SendNotifications then
    StarterGui:SetCore("SendNotification", {
        Title = "FPS Booster",
        Text = "Optimized Load! FPS Cap: 10",
        Duration = 3,
        Button1 = "Okay"
    })
end

-- Optimized loops dengan interval yang lebih panjang
-- FPS counter (priority)
RunService.Heartbeat:Connect(UpdateFPS)

-- Maintenance loop (low priority, jarang)
spawn(function()
    while true do
        EnsureFPSCap()
        wait(30) -- 30 detik sekali saja
    end
end)

-- Cleanup function
local function Cleanup()
    -- Hapus references yang tidak perlu
    fpsLabel = nil
    collectgarbage()
end

-- Auto cleanup saat player keluar
game:BindToClose(Cleanup)

print("Optimized FPS Booster Loaded - RAM Efficient")
