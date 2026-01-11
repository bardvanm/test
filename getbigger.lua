-- Scan all buttons in workspace and find highest Cup value
local highestValue = 0
local highestButton = nil
local highestPath = ""

-- Function to extract number from text like "+10000 Cup"
local function extractNumber(text)
    if not text then return 0 end
    local num = text:match("%+?(%d+)")
    return tonumber(num) or 0
end

-- Scan through workspace
for i, child in pairs(workspace:GetChildren()) do
    for j, subchild in pairs(child:GetChildren()) do
        -- Check if it has Cup.BillboardGui.TextLabel structure
        if subchild:FindFirstChild("Cup") then
            local cup = subchild.Cup
            if cup:FindFirstChild("BillboardGui") then
                local billboard = cup.BillboardGui
                if billboard:FindFirstChild("TextLabel") then
                    local textLabel = billboard.TextLabel
                    local text = textLabel.Text
                    local value = extractNumber(text)
                    
                    if value > highestValue then
                        highestValue = value
                        highestButton = subchild
                        highestPath = string.format("workspace:GetChildren()[%d]:GetChildren()[%d]", i, j)
                    end
                    
                    print(string.format("[%d][%d] %s: %s (Value: %d)", i, j, subchild.Name, text, value))
                end
            end
        end
    end
end

print("\n=== HIGHEST VALUE FOUND ===")
print("Value: " .. highestValue)
print("Path: " .. highestPath)
print("Button: " .. (highestButton and highestButton.Name or "None"))
print("Full Path: " .. highestPath .. ".Cup.BillboardGui.TextLabel")

-- Copy to clipboard
if highestValue > 0 then
    setclipboard(highestPath .. ".Cup.BillboardGui.TextLabel")
    print("\n✓ Copied to clipboard: " .. highestPath .. ".Cup.BillboardGui.TextLabel")
end
