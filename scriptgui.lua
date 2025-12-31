-- Simple Script Loader GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SimpleSpy = Instance.new("TextButton")
local InfiniteYield = Instance.new("TextButton")
local InfiniteYieldAI = Instance.new("TextButton")
local DexOld = Instance.new("TextButton")
local DexV4 = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.Size = UDim2.new(0, 180, 0, 240)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 8)

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Script Loader"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

SimpleSpy.Parent = MainFrame
SimpleSpy.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
SimpleSpy.Position = UDim2.new(0.1, 0, 0, 38)
SimpleSpy.Size = UDim2.new(0.8, 0, 0, 32)
SimpleSpy.Font = Enum.Font.Gotham
SimpleSpy.Text = "SimpleSpy V3"
SimpleSpy.TextColor3 = Color3.fromRGB(255, 255, 255)
SimpleSpy.TextSize = 12
Instance.new("UICorner", SimpleSpy).CornerRadius = UDim.new(0, 5)

InfiniteYield.Parent = MainFrame
InfiniteYield.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
InfiniteYield.Position = UDim2.new(0.1, 0, 0, 78)
InfiniteYield.Size = UDim2.new(0.8, 0, 0, 32)
InfiniteYield.Font = Enum.Font.Gotham
InfiniteYield.Text = "Infinite Yield"
InfiniteYield.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteYield.TextSize = 12
Instance.new("UICorner", InfiniteYield).CornerRadius = UDim.new(0, 5)

InfiniteYieldAI.Parent = MainFrame
InfiniteYieldAI.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
InfiniteYieldAI.Position = UDim2.new(0.1, 0, 0, 118)
InfiniteYieldAI.Size = UDim2.new(0.8, 0, 0, 32)
InfiniteYieldAI.Font = Enum.Font.Gotham
InfiniteYieldAI.Text = "Infinite Yield w/ AI"
InfiniteYieldAI.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteYieldAI.TextSize = 12
Instance.new("UICorner", InfiniteYieldAI).CornerRadius = UDim.new(0, 5)

DexOld.Parent = MainFrame
DexOld.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
DexOld.Position = UDim2.new(0.1, 0, 0, 158)
DexOld.Size = UDim2.new(0.8, 0, 0, 32)
DexOld.Font = Enum.Font.Gotham
DexOld.Text = "Dex Explorer (Old)"
DexOld.TextColor3 = Color3.fromRGB(255, 255, 255)
DexOld.TextSize = 12
Instance.new("UICorner", DexOld).CornerRadius = UDim.new(0, 5)

DexV4.Parent = MainFrame
DexV4.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
DexV4.Position = UDim2.new(0.1, 0, 0, 198)
DexV4.Size = UDim2.new(0.8, 0, 0, 32)
DexV4.Font = Enum.Font.Gotham
DexV4.Text = "Dex Explorer V4"
DexV4.TextColor3 = Color3.fromRGB(255, 255, 255)
DexV4.TextSize = 12
Instance.new("UICorner", DexV4).CornerRadius = UDim.new(0, 5)

-- Button Functions
SimpleSpy.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
end)

InfiniteYield.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

InfiniteYieldAI.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.Lua"))()
end)

DexOld.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua"))()
end)

DexV4.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MariyaFurmanova/Library/main/dex2.0"))()
end)

