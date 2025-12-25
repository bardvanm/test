-- ===== Load self-contained WallV3 clone =====
local WallV3 = loadstring([[

-- ===== WALL V3 STYLE GUI REWRITE =====
local WallV3 = {}
WallV3.__index = WallV3

-- Theme colors
local Theme = {
    Window = Color3.fromRGB(30,30,30),
    Folder = Color3.fromRGB(45,45,45),
    Button = Color3.fromRGB(70,70,70),
    ToggleOn = Color3.fromRGB(0,170,255),
    ToggleOff = Color3.fromRGB(100,100,100),
    Slider = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(255,255,255)
}

-- Utility: create UI element
local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

-- ===== Create Window =====
function WallV3:CreateWindow(title)
    local win = {}
    win.Folders = {}
    win.Gui = Create("ScreenGui", {Name=title, ResetOnSpawn=false}, game:GetService("CoreGui"))
    
    -- Window frame
    win.Frame = Create("Frame", {
        Name="WindowFrame",
        Size=UDim2.new(0,400,0,30),
        Position=UDim2.new(0.3,0,0.3,0),
        BackgroundColor3=Theme.Window
    }, win.Gui)
    Create("UICorner",{CornerRadius=UDim.new(0,8)}, win.Frame)
    
    -- Title
    win.TitleLabel = Create("TextLabel", {
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=Theme.Text,
        Font=Enum.Font.SourceSansBold,
        TextSize=20
    }, win.Frame)
    
    -- Make draggable
    win.Frame.Active = true
    win.Frame.Draggable = true

    -- ===== Folder creation =====
    function win:CreateFolder(name)
        local folder = {}
        folder.Name = name
        folder.Elements = {}
        folder.Opened = false
        
        -- Folder frame
        folder.Frame = Create("Frame", {
            Size=UDim2.new(1,-10,0,25),
            BackgroundColor3=Theme.Folder,
            Position=UDim2.new(0,5,0,30 + (#win.Folders * 30))
        }, win.Gui)
        Create("UICorner",{CornerRadius=UDim.new(0,6)}, folder.Frame)
        
        -- Folder label
        folder.Label = Create("TextButton", {
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            Text=name,
            TextColor3=Theme.Text,
            Font=Enum.Font.SourceSansBold,
            TextSize=18
        }, folder.Frame)
        
        -- Container for elements
        folder.ElementsFrame = Create("Frame", {
            Size=UDim2.new(1,0,0,0),
            Position=UDim2.new(0,0,1,0),
            BackgroundTransparency=1
        }, folder.Frame)
        
        folder.Label.MouseButton1Click:Connect(function()
            folder.Opened = not folder.Opened
            if folder.Opened then
                folder.ElementsFrame.Size = UDim2.new(1,0,#folder.Elements * 30,0)
            else
                folder.ElementsFrame.Size = UDim2.new(1,0,0,0)
            end
        end)
        
        -- ===== Element creators =====
        local function AddElement(type, props)
            local elemFrame = Create("Frame", {
                Size=UDim2.new(1,0,0,30),
                BackgroundTransparency=1,
                Parent=folder.ElementsFrame
            })
            local elem
            if type=="Button" then
                elem = Create("TextButton", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16
                }, elemFrame)
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                elem.MouseButton1Click:Connect(props.Callback)
            elseif type=="Toggle" then
                elem = Create("TextButton", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundColor3=Theme.ToggleOff,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16
                }, elemFrame)
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                elem.MouseButton1Click:Connect(function()
                    props.State = not props.State
                    elem.BackgroundColor3 = props.State and Theme.ToggleOn or Theme.ToggleOff
                    props.Callback(props.State)
                end)
            elseif type=="Slider" then
                -- Simplified slider
                elem = Create("TextLabel", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label.." "..props.Min,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16
                }, elemFrame)
            elseif type=="Dropdown" then
                elem = Create("TextButton", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label.." ▼",
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16
                }, elemFrame)
            elseif type=="Bind" then
                elem = Create("TextButton", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label.." ["..tostring(props.Key).."]",
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16
                }, elemFrame)
            elseif type=="ColorPicker" then
                elem = Create("TextButton", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundColor3=props.Color,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16
                }, elemFrame)
            elseif type=="Box" then
                elem = Create("TextBox", {
                    Size=UDim2.new(1,0,1,0),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16
                }, elemFrame)
                elem.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        props.Callback(elem.Text)
                    end
                end)
            end
            table.insert(folder.Elements, elem)
            -- Resize container
            folder.ElementsFrame.Size = UDim2.new(1,0,#folder.Elements * 30,0)
        end
        
        folder.Button = function(label, cb) AddElement("Button",{Label=label,Callback=cb}) end
        folder.Toggle = function(label, cb) AddElement("Toggle",{Label=label,Callback=cb,State=false}) end
        folder.Slider = function(label, options, cb) AddElement("Slider",{Label=label,Min=options.min,Max=options.max,Precise=options.precise,Callback=cb}) end
        folder.Dropdown = function(label, options, replaceTitle, cb) AddElement("Dropdown",{Label=label,Options=options,Callback=cb,Replace=replaceTitle}) end
        folder.Bind = function(label,key,cb) AddElement("Bind",{Label=label,Key=key,Callback=cb}) end
        folder.ColorPicker = function(label,color,cb) AddElement("ColorPicker",{Label=label,Color=color,Callback=cb}) end
        folder.Box = function(label,typ,cb) AddElement("Box",{Label=label,BoxType=typ,Callback=cb}) end
        folder.Open = function() folder.Opened = true folder.ElementsFrame.Size = UDim2.new(1,0,#folder.Elements*30,0) end

        table.insert(win.Folders, folder)
        return folder
    end

    win.ToggleUI = function() print("Toggled UI") end
    win.DestroyGui = function() win.Gui:Destroy() end

    return win
end

return WallV3


]])()

-- ===== Create Window =====
local Window = WallV3:CreateWindow("Ultimate Script Hub")

-- ===== Initialize top-level folders first =====
local Farming = Window:CreateFolder("Farming")
local Combat = Window:CreateFolder("Combat")
local Misc = Window:CreateFolder("Misc")
local Settings = Window:CreateFolder("Settings")

-- ===== Populate Farming folder =====
Farming:Toggle("Farming Section", function() end) -- dummy toggle
Farming:Button("Auto Farm", function() print("Auto Farm clicked") end)
Farming:Slider("Farm Speed",{min=10,max=100,precise=true},function(val) print("Farm Speed:",val) end)
Farming:Dropdown("Select Item",{"Sword","Pickaxe","Potion"},true,function(opt) print("Selected:",opt) end)
Farming:Bind("Farm Bind",Enum.KeyCode.F,function() print("Bind pressed") end)
Farming:ColorPicker("Farm Color",Color3.fromRGB(0,255,0),function(c) print("Color:",c) end)
Farming:Box("Custom Value","number",function(val) print("Box:",val) end)
Farming:Open()

-- ===== Populate Combat folder =====
Combat:Toggle("Combat Section", function() end) -- dummy toggle
Combat:Toggle("Kill Aura",function(state) print("Kill Aura:",state) end)
Combat:Slider("Aura Range",{min=5,max=50,precise=false},function(val) print("Aura Range:",val) end)
Combat:Button("Enable One Hit",function() print("One Hit Enabled") end)
Combat:Dropdown("Attack Mode",{"Normal","Fast","Insane"},true,function(opt) print("Attack Mode:",opt) end)
Combat:ColorPicker("Combat Color",Color3.fromRGB(255,0,0),function(c) print("Combat Color:",c) end)
Combat:Open()

-- ===== Populate Misc folder =====
Misc:Toggle("Misc Section", function() end) -- dummy toggle
Misc:Button("Infinite Jump",function() print("Infinite Jump") end)
Misc:Button("Anti AFK",function() print("Anti AFK Activated") end)
Misc:Toggle("Noclip",function(state) print("Noclip:",state) end)
Misc:Slider("Jump Power",{min=50,max=500,precise=true},function(val) print("Jump Power:",val) end)
Misc:Box("Custom Name","string",function(val) print("Box Input:",val) end)
Misc:Bind("Misc Bind",Enum.KeyCode.M,function() print("Misc Bind pressed") end)
Misc:Open()

-- ===== Populate Settings folder =====
Settings:Toggle("Settings Section", function() end) -- dummy toggle
Settings:Bind("Toggle UI",Enum.KeyCode.RightShift,function() Window:ToggleUI() end)
Settings:Button("Destroy UI",function() Window:DestroyGui() end)
Settings:ColorPicker("Theme Color",Color3.fromRGB(52,120,255),function(c) print("Theme Color:",c) end)
Settings:Open()
