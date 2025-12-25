-- ===== Load self-contained WallV3 clone =====
local WallV3 = loadstring([[

-- ===== Wall V3 FULL GUI Replacement =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WallV3 = {}
WallV3.__index = WallV3

-- Theme
local Theme = {
    Window = Color3.fromRGB(30,30,30),
    Folder = Color3.fromRGB(45,45,45),
    Button = Color3.fromRGB(70,70,70),
    ToggleOn = Color3.fromRGB(0,170,255),
    ToggleOff = Color3.fromRGB(100,100,100),
    Slider = Color3.fromRGB(0,170,255),
    Text = Color3.fromRGB(255,255,255)
}

local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

function WallV3:CreateWindow(title)
    local win = {}
    win.Folders = {}

    -- Main ScreenGui
    win.Gui = Create("ScreenGui",{Name=title,ResetOnSpawn=false,IgnoreGuiInset=true}, game:GetService("CoreGui"))

    -- Main window frame
    win.Frame = Create("Frame",{
        Name="Window",
        Size=UDim2.new(0,400,0,30),
        Position=UDim2.new(0.3,0,0.3,0),
        BackgroundColor3=Theme.Window,
        Active=true,
        Draggable=true
    }, win.Gui)
    Create("UICorner",{CornerRadius=UDim.new(0,8)}, win.Frame)

    -- Title
    win.TitleLabel = Create("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=Theme.Text,
        Font=Enum.Font.SourceSansBold,
        TextSize=20
    }, win.Frame)

    -- Folder creation
    function win:CreateFolder(name)
        local folder = {}
        folder.Name = name
        folder.Elements = {}
        folder.Opened = false

        -- Folder button
        folder.Button = Create("TextButton",{
            Size=UDim2.new(1,0,0,25),
            BackgroundColor3=Theme.Folder,
            Text=name,
            TextColor3=Theme.Text,
            Font=Enum.Font.SourceSansBold,
            TextSize=16,
            Parent=win.Frame
        })
        Create("UICorner",{CornerRadius=UDim.new(0,6)}, folder.Button)

        -- Elements container
        folder.ElementsFrame = Create("Frame",{
            Size=UDim2.new(1,0,0,0),
            BackgroundTransparency=1,
            Parent=win.Frame,
            Position=UDim2.new(0,0,0,25) -- will adjust later
        })
        Create("UIListLayout",{Padding=UDim.new(0,2), FillDirection=Enum.FillDirection.Vertical, SortOrder=Enum.SortOrder.LayoutOrder}, folder.ElementsFrame)

        -- Toggle folder open
        folder.Button.MouseButton1Click:Connect(function()
            folder.Opened = not folder.Opened
            folder.ElementsFrame.Visible = folder.Opened
            self:UpdateFolderPositions()
        end)

        -- Add element function
        local function AddElement(type, props)
            local elem
            if type=="Button" then
                elem = Create("TextButton",{
                    Size=UDim2.new(1,0,0,25),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16,
                    Parent=folder.ElementsFrame
                })
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                elem.MouseButton1Click:Connect(props.Callback)
            elseif type=="Toggle" then
                elem = Create("TextButton",{
                    Size=UDim2.new(1,0,0,25),
                    BackgroundColor3=Theme.ToggleOff,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16,
                    Parent=folder.ElementsFrame
                })
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                elem.MouseButton1Click:Connect(function()
                    props.State = not props.State
                    elem.BackgroundColor3 = props.State and Theme.ToggleOn or Theme.ToggleOff
                    props.Callback(props.State)
                end)
            elseif type=="Box" then
                elem = Create("TextBox",{
                    Size=UDim2.new(1,0,0,25),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16,
                    Parent=folder.ElementsFrame
                })
                elem.FocusLost:Connect(function(enter)
                    if enter then props.Callback(elem.Text) end
                end)
            else
                -- For simplicity, just create a placeholder TextLabel
                elem = Create("TextLabel",{
                    Size=UDim2.new(1,0,0,25),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label or type,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=16,
                    Parent=folder.ElementsFrame
                })
            end
            table.insert(folder.Elements, elem)
        end

        folder.ButtonElement = AddElement
        folder.Button = function(label,cb) AddElement("Button",{Label=label,Callback=cb}) end
        folder.Toggle = function(label,cb) AddElement("Toggle",{Label=label,Callback=cb,State=false}) end
        folder.Box = function(label,typ,cb) AddElement("Box",{Label=label,BoxType=typ,Callback=cb}) end

        table.insert(win.Folders, folder)
        return folder
    end

    function win:UpdateFolderPositions()
        local offset = 30
        for _,folder in pairs(win.Folders) do
            folder.Button.Position = UDim2.new(0,0,0,offset)
            offset = offset + 25
            if folder.Opened then
                folder.ElementsFrame.Position = UDim2.new(0,0,0,offset)
                folder.ElementsFrame.Visible = true
                offset = offset + #folder.Elements*27
            else
                folder.ElementsFrame.Visible = false
            end
        end
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
