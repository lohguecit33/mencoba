-- Made by RIP#6666
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

-- Script FPS Booster
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

local Players, Lighting, StarterGui, MaterialService = game:GetService("Players"), game:GetService("Lighting"), game:GetService("StarterGui"), game:GetService("MaterialService")
local ME, CanBeEnabled = Players.LocalPlayer, {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function PartOfCharacter(Inst)
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Inst:IsDescendantOf(v.Character) then
            return true
        end
    end
    return false
end

local function DescendantOfIgnore(Inst)
    for i, v in pairs(_G.Ignore) do
        if Inst:IsDescendantOf(v) then
            return true
        end
    end
    return false
end

local function CheckIfBad(Inst)
    if not Inst:IsDescendantOf(Players) and (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Inst) 
    or not _G.Settings.Players["Ignore Others"]) and (_G.Settings.Players["Ignore Me"] and ME.Character and not Inst:IsDescendantOf(ME.Character) 
    or not _G.Settings.Players["Ignore Me"]) and (_G.Ignore and not table.find(_G.Ignore, Inst) and not DescendantOfIgnore(Inst) 
    or (not _G.Ignore or type(_G.Ignore) ~= "table" or #_G.Ignore <= 0)) then
        
        if Inst:IsA("DataModelMesh") then
            if _G.Settings.Meshes.Destroy then
                Inst:Destroy()
            elseif _G.Settings.Meshes.LowDetail then
                if Inst:IsA("SpecialMesh") then
                    Inst.MeshId = ""
                    Inst.TextureId = ""
                end
            end
        elseif Inst:IsA("FaceInstance") then
            if _G.Settings.Images.Invisible then
                Inst.Transparency = 1
            end
            if _G.Settings.Images.Destroy then
                Inst:Destroy()
            end
        elseif Inst:IsA("ShirtGraphic") then
            if _G.Settings.Images.Invisible then
                Inst.Graphic = ""
            end
            if _G.Settings.Images.Destroy then
                Inst:Destroy()
            end
        elseif table.find(CanBeEnabled, Inst.ClassName) then
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
end

-- Apply settings
if _G.SendNotifications then
    StarterGui:SetCore("SendNotification", {
        Title = "FPS Booster",
        Text = "Loading...",
        Duration = 5,
        Button1 = "Okay"
    })
end

-- FPS Cap
if _G.Settings.Other["FPS Cap"] and setfpscap then
    setfpscap(10)
    if _G.SendNotifications then
        StarterGui:SetCore("SendNotification", {
            Title = "FPS Booster",
            Text = "FPS Capped to 10",
            Duration = 5,
            Button1 = "Okay"
        })
    end
end

-- Graphics Settings
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

-- Process existing instances
local Descendants = game:GetDescendants()
for i, v in pairs(Descendants) do
    CheckIfBad(v)
end

-- Process new instances
game.DescendantAdded:Connect(function(Inst)
    task.wait(0.1)
    CheckIfBad(Inst)
end)

if _G.SendNotifications then
    StarterGui:SetCore("SendNotification", {
        Title = "FPS Booster",
        Text = "Loaded successfully! FPS: 10",
        Duration = 5,
        Button1 = "Okay"
    })
end

print("FPS Booster Loaded - FPS Cap: 10")
