-- EXTREME Ultra-lightweight alt account script
-- Maximum resource reduction while preventing AFK kick

repeat task.wait() until game:IsLoaded()

-- Services
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Anti-AFK (minimal overhead)
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.zero)
end)

-- ====================================
-- RENDERING OPTIMIZATIONS
-- ====================================

-- Completely disable 3D rendering
RunService:Set3dRenderingEnabled(false)

-- Minimize graphics settings
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01

-- Disable post-processing effects
pcall(function()
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 0
    Lighting.Brightness = 0
end)

-- Disable camera rendering
workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

-- ====================================
-- CHARACTER OPTIMIZATIONS
-- ====================================

local function optimizeCharacter(char)
    task.wait(0.3)
    
    -- Remove accessories
    for _, accessory in ipairs(char:GetChildren()) do
        if accessory:IsA("Accessory") then
            accessory:Destroy()
        end
    end
    
    -- Minimize character parts
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
            part.CastShadow = false
            part.Material = Enum.Material.SmoothPlastic
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part:Destroy()
        elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Beam") or part:IsA("Fire") or part:IsA("Smoke") or part:IsA("Sparkles") then
            part:Destroy()
        elseif part:IsA("SpecialMesh") then
            part:Destroy()
        elseif part:IsA("Sound") then
            part:Destroy()
        end
    end
    
    -- Disable animations
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        animator:Destroy()
    end
end

-- Optimize current character
if player.Character then
    optimizeCharacter(player.Character)
end

-- Handle future spawns
player.CharacterAdded:Connect(optimizeCharacter)

-- ====================================
-- AUDIO OPTIMIZATIONS
-- ====================================

-- Mute all sounds
for _, sound in ipairs(game:GetDescendants()) do
    if sound:IsA("Sound") then
        sound:Stop()
        sound.Volume = 0
        sound:Destroy()
    end
end

-- Prevent new sounds
local function destroySound(obj)
    if obj:IsA("Sound") then
        obj:Stop()
        obj:Destroy()
    end
end

workspace.DescendantAdded:Connect(destroySound)
if player.Character then
    player.Character.DescendantAdded:Connect(destroySound)
end

-- ====================================
-- GUI OPTIMIZATIONS
-- ====================================

-- Disable all GUIs
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end)

local playerGui = player:WaitForChild("PlayerGui", 5)
if playerGui then
    for _, gui in ipairs(playerGui:GetChildren()) do
        gui.Enabled = false
    end
    
    playerGui.ChildAdded:Connect(function(gui)
        gui.Enabled = false
    end)
end

-- ====================================
-- WORKSPACE OPTIMIZATIONS
-- ====================================

-- Create platform under player to prevent death
local function createPlatform()
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Create invisible platform
    local platform = Instance.new("Part")
    platform.Name = "AltPlatform"
    platform.Size = Vector3.new(50, 1, 50)
    platform.Position = hrp.Position - Vector3.new(0, 10, 0)
    platform.Anchored = true
    platform.Transparency = 1
    platform.CanCollide = true
    platform.Parent = workspace
    
    return platform
end

-- Delete everything in workspace except essentials
local function nukeWorkspace()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj ~= player.Character and 
           obj ~= workspace.CurrentCamera and 
           obj ~= workspace.Terrain and
           obj.Name ~= "AltPlatform" then
            pcall(function()
                obj:Destroy()
            end)
        end
    end
end

-- Create platform first
createPlatform()

-- Wait a bit then nuke everything
task.wait(1)
nukeWorkspace()

-- Recreate platform on respawn
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    createPlatform()
end)

-- Prevent new objects from being added (except our platform)
workspace.ChildAdded:Connect(function(obj)
    if obj ~= player.Character and 
       obj ~= workspace.CurrentCamera and 
       obj ~= workspace.Terrain and
       obj.Name ~= "AltPlatform" then
        task.wait(0.1) -- Small delay to avoid issues
        pcall(function()
            obj:Destroy()
        end)
    end
end)

-- ====================================
-- CONNECTION OPTIMIZATIONS
-- ====================================

-- Disable non-essential connections
local connectionsToDisable = {
    RunService.RenderStepped,
    RunService.Stepped,
    RunService.Heartbeat
}

for _, signal in ipairs(connectionsToDisable) do
    pcall(function()
        for _, connection in ipairs(getconnections(signal)) do
            if connection.Function and not tostring(connection.Function):find("Anti") then
                connection:Disable()
            end
        end
    end)
end

-- Disable input processing
if UserInputService then
    pcall(function()
        UserInputService.MouseIconEnabled = false
    end)
end

-- ====================================
-- MEMORY OPTIMIZATIONS
-- ====================================

-- Force garbage collection periodically
task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            setfpscap(10) -- Cap FPS to minimum
            game:GetService("ContentProvider"):PreloadAsync({}) -- Clear cache
        end)
    end
end)

-- ====================================
-- NETWORK OPTIMIZATIONS
-- ====================================

-- Reduce network replication by minimizing character movement
if player.Character then
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.JumpHeight = 0
    end
end
