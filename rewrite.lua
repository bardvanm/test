-- huts
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

local UserInputService = game:GetService("UserInputService")

local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    dragHandle.Active = true
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.AbsolutePosition
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            local parentSize = frame.Parent.AbsoluteSize
            local frameSize = frame.AbsoluteSize
            local newX = math.clamp(startPos.X + delta.X, 0, parentSize.X - frameSize.X)
            local newY = math.clamp(startPos.Y + delta.Y, 0, parentSize.Y - frameSize.Y)
            frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
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
        BackgroundTransparency=1,
        ZIndex = 2,
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
        ZIndex = 3
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
        BorderSizePixel=0,
        Visible = false
    })
    local contentLayout = Create("UIListLayout",{Parent=win.Content, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,6)})
    Create("UIPadding",{Parent=win.Content, PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)})

    -- make window draggable by header
    makeDraggable(win.Frame, win.Header)

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

        local idx = #win.Folders + 1

        -- Folder button (top-level item in the scrolling content)
        folder.Button = Create("TextButton",{
            Size=UDim2.new(1,0,0,30),
            BackgroundColor3=Theme.Folder,
            Text=name,
            TextColor3=Theme.Text,
            Font=Enum.Font.SourceSansBold,
            TextSize=16,
            LayoutOrder = idx * 2 - 1, -- keep ordering stable
            Parent = win.Content,
            AutoButtonColor = false,
        })
        folder.Button.TextXAlignment = Enum.TextXAlignment.Left
        Create("UICorner",{CornerRadius=UDim.new(0,6)}, folder.Button)
        Create("UIPadding",{Parent=folder.Button, PaddingLeft=UDim.new(0,12)}) -- left align padding

        -- Elements container (will be sized to contents)
        folder.ElementsFrame = Create("Frame",{
            Size=UDim2.new(1,0,0,0),
            BackgroundTransparency=1,
            Parent=win.Content,
            Visible=false,
            LayoutOrder = idx * 2
        })
        local elemsLayout = Create("UIListLayout",{Parent=folder.ElementsFrame, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4)})
        Create("UIPadding",{Parent=folder.ElementsFrame, PaddingLeft=UDim.new(0,8), PaddingBottom=UDim.new(0,6), PaddingTop=UDim.new(0,6)})

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
            if folder.Opened and not expanded then setExpanded(true) end
        end)

        -- Open/Close helpers
        function folder:Open()
            folder.Opened = true
            folder.ElementsFrame.Visible = true
            if not expanded then setExpanded(true) end
        end
        function folder:Close()
            folder.Opened = false
            folder.ElementsFrame.Visible = false
        end

        -- helper to add elements
        local function AddElement(type, props)
            local elem
            props = props or {}
            if type=="Button" then
                elem = Create("TextButton",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label or "Button",
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSansBold,
                    TextSize=15,
                    Parent=folder.ElementsFrame,
                    AutoButtonColor = false,
                })
                elem.TextXAlignment = Enum.TextXAlignment.Left
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                elem.Padding = Create("UIPadding",{Parent = elem, PaddingLeft = UDim.new(0,8)})
                elem.MouseButton1Click:Connect(function() if props.Callback then pcall(props.Callback) end end)
            elseif type=="Toggle" then
                elem = Create("Frame",{Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Parent=folder.ElementsFrame})
                local lbl = Create("TextLabel",{Parent=elem,Size=UDim2.new(0.7,0,1,0),BackgroundTransparency=1,Text=props.Label or "Toggle",TextColor3=Theme.Text,Font=Enum.Font.SourceSans,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,8,0,0)})
                local btn = Create("TextButton",{Parent=elem, Size=UDim2.new(0,28,0,20), Position=UDim2.new(1,-36,0.5,-10), BackgroundColor3=Theme.ToggleOff, Text="", AutoButtonColor=false})
                Create("UICorner",{CornerRadius=UDim.new(0,4)}, btn)
                props.State = props.State or false
                btn.MouseButton1Click:Connect(function()
                    props.State = not props.State
                    btn.BackgroundColor3 = props.State and Theme.ToggleOn or Theme.ToggleOff
                    if props.Callback then pcall(props.Callback, props.State) end
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
                    if enter and props.Callback then pcall(props.Callback, elem.Text) end
                end)
            elseif type == "Slider" then
                local min = props.min or 0
                local max = props.max or 100
                local precise = props.precise or false
                local value = min
                elem = Create("Frame",{Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, Parent=folder.ElementsFrame})
                local lbl = Create("TextLabel",{Parent=elem,Size=UDim2.new(0.55,0,0,18),Position=UDim2.new(0,8,0,4),BackgroundTransparency=1,Text=props.Label or "Slider",TextColor3=Theme.Text,Font=Enum.Font.SourceSans,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left})
                local valLbl = Create("TextLabel",{Parent=elem,Size=UDim2.new(0.3,0,0,18),Position=UDim2.new(1,-120,0,4),BackgroundTransparency=1,Text=tostring(value),TextColor3=Theme.Text,Font=Enum.Font.SourceSans,TextSize=14,TextXAlignment=Enum.TextXAlignment.Right})
                local track = Create("Frame",{Parent=elem, Size=UDim2.new(1,-140,0,10), Position=UDim2.new(0,8,0,20), BackgroundColor3=Color3.fromRGB(70,70,70)})
                Create("UICorner",{Parent=track, CornerRadius=UDim.new(0,4)})
                local fill = Create("Frame",{Parent=track, Size=UDim2.new(0,0,1,0), BackgroundColor3=Theme.Slider})
                Create("UICorner",{Parent=fill, CornerRadius=UDim.new(0,4)})
                local dragging = false
                local function setFromX(x)
                    local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = (min + (max - min) * rel)
                    if not precise then value = math.floor(value + 0.5) end
                    fill.Size = UDim2.new(rel,0,1,0)
                    valLbl.Text = tostring(math.floor(value * (precise and 100 or 1)) / (precise and 100 or 1))
                    if props.Callback then pcall(props.Callback, value) end
                end
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        setFromX(input.Position.X)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        setFromX(input.Position.X)
                    end
                end)
            elseif type == "Dropdown" then
                elem = Create("Frame",{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=folder.ElementsFrame})
                local btn = Create("TextButton",{Parent=elem, Size=UDim2.new(1,0,0,30), BackgroundColor3=Theme.Button, Text=props.Label or "Select", TextColor3=Theme.Text, AutoButtonColor=false})
                btn.TextXAlignment = Enum.TextXAlignment.Left
                Create("UICorner",{Parent=btn, CornerRadius=UDim.new(0,6)})
                local list = Create("Frame",{Parent=folder.ElementsFrame, Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, Visible=false})
                local listLayout = Create("UIListLayout",{Parent=list, SortOrder=Enum.SortOrder.LayoutOrder})
                Create("UIPadding",{Parent=list, PaddingLeft=UDim.new(0,8), PaddingTop=UDim.new(0,4), PaddingBottom=UDim.new(0,4)})
                btn.MouseButton1Click:Connect(function()
                    list.Visible = not list.Visible
                    if list.Visible and not expanded then setExpanded(true) end
                end)
                for _,opt in ipairs(props.Options or {}) do
                    local oBtn = Create("TextButton",{Parent=list, Size=UDim2.new(1,0,0,26), BackgroundColor3=Theme.Button, Text=opt, TextColor3=Theme.Text, AutoButtonColor=false})
                    oBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Create("UICorner",{Parent=oBtn, CornerRadius=UDim.new(0,6)})
                    oBtn.MouseButton1Click:Connect(function()
                        btn.Text = tostring(opt)
                        list.Visible = false
                        if props.Callback then pcall(props.Callback, opt) end
                    end)
                end
            elseif type == "Bind" then
                elem = Create("Frame",{Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Parent=folder.ElementsFrame})
                local lbl = Create("TextLabel",{Parent=elem,Size=UDim2.new(0.65,0,1,0),BackgroundTransparency=1,Text=props.Label or "Bind",TextColor3=Theme.Text,Font=Enum.Font.SourceSans,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,8,0,0)})
                local kbBtn = Create("TextButton",{Parent=elem, Size=UDim2.new(0,80,0,20), Position=UDim2.new(1,-88,0.5,-10), BackgroundColor3=Theme.Button, Text="None", AutoButtonColor=false})
                Create("UICorner",{Parent=kbBtn, CornerRadius=UDim.new(0,6)})
                local current = nil
                kbBtn.MouseButton1Click:Connect(function()
                    kbBtn.Text = "Press..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(inp, gp)
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            current = inp.KeyCode
                            kbBtn.Text = tostring(current):gsub("Enum.KeyCode.","")
                            if props.Callback then pcall(props.Callback, current) end
                            conn:Disconnect()
                        end
                    end)
                end)
            elseif type == "ColorPicker" then
                elem = Create("Frame",{Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=folder.ElementsFrame})
                local lbl = Create("TextLabel",{Parent=elem,Size=UDim2.new(0.6,0,1,0),BackgroundTransparency=1,Text=props.Label or "Color",TextColor3=Theme.Text,Font=Enum.Font.SourceSans,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,8,0,0)})
                local colorBtn = Create("TextButton",{Parent=elem, Size=UDim2.new(0,36,0,20), Position=UDim2.new(1,-44,0.5,-10), BackgroundColor3=props.Color or Color3.new(1,1,1), Text="", AutoButtonColor=false})
                Create("UICorner",{Parent=colorBtn, CornerRadius=UDim.new(0,6)})
                local picker = Create("Frame",{Parent=folder.ElementsFrame, Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, Visible=false})
                local rBox = Create("TextBox",{Parent=picker, Size=UDim2.new(0.3,0,1,0), Position=UDim2.new(0,8,0,0), Text=tostring(math.floor((props.Color and props.Color.R*255) or 255)), BackgroundColor3=Theme.Button, TextColor3=Theme.Text})
                local gBox = Create("TextBox",{Parent=picker, Size=UDim2.new(0.3,0,1,0), Position=UDim2.new(0.35,0,0,0), Text=tostring(math.floor((props.Color and props.Color.G*255) or 255)), BackgroundColor3=Theme.Button, TextColor3=Theme.Text})
                local bBox = Create("TextBox",{Parent=picker, Size=UDim2.new(0.3,0,1,0), Position=UDim2.new(0.7,0,0,0), Text=tostring(math.floor((props.Color and props.Color.B*255) or 255)), BackgroundColor3=Theme.Button, TextColor3=Theme.Text})
                local function updateColor()
                    local r = tonumber(rBox.Text) or 255
                    local g = tonumber(gBox.Text) or 255
                    local b = tonumber(bBox.Text) or 255
                    local col = Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
                    colorBtn.BackgroundColor3 = col
                    if props.Callback then pcall(props.Callback, col) end
                end
                colorBtn.MouseButton1Click:Connect(function() picker.Visible = not picker.Visible if picker.Visible and not expanded then setExpanded(true) end end)
                rBox.FocusLost:Connect(function(enter) if enter then updateColor() end end)
                gBox.FocusLost:Connect(function(enter) if enter then updateColor() end end)
                bBox.FocusLost:Connect(function(enter) if enter then updateColor() end end)
            else
                -- fallback label (left aligned)
                elem = Create("TextLabel",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundColor3=Theme.Button,
                    Text=props.Label or tostring(type),
                    TextColor3=Theme.Text,
                    Font=Enum.Font.SourceSans,
                    TextSize=15,
                    Parent=folder.ElementsFrame
                })
                elem.TextXAlignment = Enum.TextXAlignment.Left
                Create("UICorner",{CornerRadius=UDim.new(0,6)}, elem)
                Create("UIPadding",{Parent=elem, PaddingLeft=UDim.new(0,8)})
            end
            table.insert(folder.Elements, elem)
            return elem
        end

        -- simple API
        folder.ButtonElement = AddElement
        folder.Button = function(lbl, cb) AddElement("Button",{Label=lbl, Callback=cb}) end
        folder.Toggle = function(lbl, cb) AddElement("Toggle",{Label=lbl, Callback=cb, State=false}) end
        folder.Box = function(lbl, typ, cb) AddElement("Box",{Label=lbl, BoxType=typ, Callback=cb}) end
        folder.Slider = function(lbl, opts, cb) AddElement("Slider",{Label=lbl, min=opts.min, max=opts.max, precise=opts.precise, Callback=cb}) end
        folder.Dropdown = function(lbl, opts, multi, cb) AddElement("Dropdown",{Label=lbl, Options=opts, Multi=multi, Callback=cb}) end
        folder.Bind = function(lbl, key, cb) AddElement("Bind",{Label=lbl, Key=key, Callback=cb}) end
        folder.ColorPicker = function(lbl, col, cb) AddElement("ColorPicker",{Label=lbl, Color=col, Callback=cb}) end
        folder.Open = function() folder:Open() end
        folder.Close = function() folder:Close() end

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
