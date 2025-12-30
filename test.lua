-- BartLib v2 Loadstring
-- Upload bartlibv2.lua to GitHub raw and replace the URL below
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bardvanm/bartlib/main/bartlibv2.lua"))()

-- Create window
local win = lib:CreateWindow("BartLib v2 Test")

-- Create folders/tabs
local main = win:CreateFolder("Main")
local features = win:CreateFolder("Features")

-- Main tab
main:Toggle("Test Toggle", function(value)
    print("Toggle:", value)
end)

main:Button("Test Button", function()
    print("Button clicked!")
end)

main:Slider("Speed", {min = 1, max = 10, step = 0.5, default = 5}, function(value)
    print("Speed:", value)
end)

-- Features tab
features:Dropdown("Select Mode", {"Mode 1", "Mode 2", "Mode 3"}, function(value)
    print("Selected:", value)
end)

features:Slider("Range", {min = 10, max = 100, step = 5, default = 50}, function(value)
    print("Range:", value)
end)

features:Button("Execute", function()
    print("Executed!")
end)
