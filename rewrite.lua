-- ===== Load self-contained WallV3 clonezzzzzzzzzzz =====
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

    -- Main ScreenGui (use PlayerGui so it shows for this player)
    win.Gui = Create("ScreenGui",{Name=title,ResetOnSpawn=false,IgnoreGuiInset=true}, game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))

    -- Constants
    local HEADER_H = 36
    local WIDTH = 420
    local MAX_CONTENT_H = 260

    -- Main window frame (includes header + content)
    win.Frame = Create("Frame",{
        Name="Window",
        Size=UDim2.new(0,WIDTH,0,HEADER_H), -- start header-only to mimic minimize behavior
        Position=UDim2.new(0.3,0,0.3,0),
        BackgroundColor3=Theme.Window,
        Active=true,
        ClipsDescendants=true
    }, win.Gui)
    Create("UICorner",{CornerRadius=UDim.new(0,8)}, win.Frame)

    -- Header
    win.Header = Create("Frame",{
        Parent=win.Frame,
        Size=UDim2.new(1,0,0,HEADER_H),
        BackgroundTransparency=1
    })
    win.TitleLabel = Create("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=Theme.Text,
        Font=Enum.Font.SourceSansBold,
        TextSize=18,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        Position=UDim2.new(0,12,0,0)
    }, win.Header)

    -- Minimize / Toggle button
    win.ToggleBtn = Create("TextButton",{
        Size=UDim2.new(0,36,0,24),
        Position=UDim2.new(1,-44,0.5,-12),
        BackgroundColor3=Theme.Button,
        Text="+", -- start collapsed
        TextColor3=Theme.Text,
        Font=Enum.Font.SourceSansBold,
        TextSize=20,
        AutoButtonColor=false,
    }, win.Header)
    Create("UICorner",{CornerRadius=UDim.new(0,6)}, win.ToggleBtn)

    -- Content area (scrolling to contain folder buttons + their element containers)
    win.Content = Create("ScrollingFrame",{
        Parent=win.Frame,
        Name="Content",
        Position=UDim2.new(0,0,0,HEADER_H),
        Size=UDim2.new(1,0,0,0), -- will be resized when expanded
        BackgroundTransparency=1,
        ScrollBarThickness=6,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        BorderSizePixel=0
    })
    local contentLayout = Create("UIListLayout",{Parent=win.Content, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)})
    Create("UIPadding",{Parent=win.Content, PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)})

    -- State
    local expanded = false

    local function setExpanded(exp)
        expanded = not not exp
        if expanded then
            win.Content.Visible = true
            local contentH = math.min(MAX_CONTENT_H, math.max(60, contentLayout.AbsoluteContentSize.Y))
            win.Content:TweenSize(UDim2.new(1,0,0, contentH), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            win.Frame:TweenSize(UDim2.new(0,WIDTH,0, HEADER_H + contentH), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            win.ToggleBtn.Text = "—"
        else
            win.Content:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            win.Frame:TweenSize(UDim2.new(0,WIDTH,0, HEADER_H), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            win.ToggleBtn.Text = "+"
            -- hide after tween to prevent interaction / accidental visibility flicker
            delay(0.16, function()
                if not expanded then win.Content.Visible = false end
            end)
        end
    end

    win.ToggleBtn.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    -- when content grows, if expanded adjust sizes (keeps within max)
    win.Content:GetPropertyChangedSignal("CanvasSize"):Connect(function()
        if expanded then
            setExpanded(true) -- recompute based on layout size (uses contentLayout.AbsoluteContentSize)
        end
    end)

    -- Folder creation
    function win:CreateFolder(name)
        local folder = {}
        folder.Name = name
        folder.Elements = {}
        folder.Opened = false

        -- Folder button (top-level item in the scrolling content)
        folder.Button = Create("TextButton",{
            Size=UDim2.new(1,0,0,30),
            BackgroundColor3=Theme.Folder,
            Text=name,
            TextColor3=Theme.Text,
            Font=Enum.Font.SourceSansBold,
            TextSize=16,
            LayoutOrder = #win.Folders * 2, -- keep ordering stable
            Parent = win.Content
        })
        Create("UICorner",{CornerRadius=UDim.new(0,6)}, folder.Button)

        -- Elements container (will be sized to contents)
        folder.ElementsFrame = Create("Frame",{
            Size=UDim2.new(1,0,0,0),
            BackgroundTransparency=1,
            Parent=win.Content,
            Visible=false,
            LayoutOrder = #win.Folders * 2 + 1
        })
        local elemsLayout = Create("UIListLayout",{Parent=folder.ElementsFrame, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4)})
        Create("UIPadding",{Parent=folder.ElementsFrame, PaddingLeft=UDim.new(0,6), PaddingBottom=UDim.new(0,6), PaddingTop=UDim.new(0,6)})

        -- auto-size elements frame when its children change
        elemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            folder.ElementsFrame.Size = UDim2.new(1,0,0, elemsLayout.AbsoluteContentSize.Y)
            -- update content visible size as well
            if expanded then
                setExpanded(true)
            end
        end)

        -- open/close folder
        folder.Button.MouseButton1Click:Connect(function()
            folder.Opened = not folder.Opened
            folder.ElementsFrame.Visible = folder.Opened
            -- ensure content is expanded so user can see
            if folder.Opened and not expanded then setExpanded(true) end
        end)

        -- helper to add elements
        local function AddElement(type, props)
            local elem
            if type=="Button" then
                elem = Create("TextButton",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label,
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=15,
                    Parent=folder.ElementsFrame
                })
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                elem.MouseButton1Click:Connect(props.Callback)
            elseif type=="Toggle" then
                elem = Create("Frame",{Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Parent=folder.ElementsFrame})
                local lbl = Create("TextLabel",{Parent=elem,Size=UDim2.new(0.7,0,1,0),BackgroundTransparency=1,Text=props.Label,TextColor3=Theme.Text,Font=Enum.Font.SourceSans,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,8,0,0)})
                local btn = Create("TextButton",{Parent=elem, Size=UDim2.new(0,28,0,20), Position=UDim2.new(1,-36,0.5,-10), BackgroundColor3=Theme.ToggleOff, Text="", AutoButtonColor=false})
                Create("UICorner",{CornerRadius=UDim.new(0,4)}, btn)
                props.State = props.State or false
                btn.MouseButton1Click:Connect(function()
                    props.State = not props.State
                    btn.BackgroundColor3 = props.State and Theme.ToggleOn or Theme.ToggleOff
                    if props.Callback then props.Callback(props.State) end
                end)
            elseif type=="Box" then
                elem = Create("TextBox",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label or "",
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSans,
                    TextSize=15,
                    Parent=folder.ElementsFrame
                })
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                elem.FocusLost:Connect(function(enter)
                    if enter and props.Callback then props.Callback(elem.Text) end
                end)
            else
                elem = Create("TextLabel",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label or tostring(type),
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSans,
                    TextSize=15,
                    Parent=folder.ElementsFrame
                })
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
            end
            table.insert(folder.Elements, elem)
            return elem
        end

        -- simple API
        folder.ButtonElement = AddElement
        folder.Button = function(lbl, cb) AddElement("Button",{Label=lbl, Callback=cb}) end
        folder.Toggle = function(lbl, cb) AddElement("Toggle",{Label=lbl, Callback=cb, State=false}) end
        folder.Box = function(lbl, typ, cb) AddElement("Box",{Label=lbl, BoxType=typ, Callback=cb}) end

        table.insert(win.Folders, folder)
        return folder
    end

    -- expose helpers
    win.ToggleUI = function() setExpanded(not expanded) end
    win.DestroyGui = function() if win and win.Gui then win.Gui:Destroy() end end

    -- initial state (ensure UI consistent)
    setExpanded(false)

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
