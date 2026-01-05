repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
-- Booleans
getgenv().autoStats = false
getgenv().autoDunk = false
getgenv().autoUpgrade = false
getgenv().autoBalls = false
getgenv().autoJerseys = false
getgenv().autoShoes = false
getgenv().autoRebirth = false
getgenv().autoContest = false

-- Paths
local lp = game.Players.LocalPlayer
local ws = game:GetService('Workspace')
local rs = game:GetService("ReplicatedStorage")
local serverEvent = rs.ServerEvent
-- Arrays
local balls = {'Default', 'Allstar', 'Grass', 'Tennis', 'Moon', 'Magma', 'Water', 'Fire', 'White Fire', 'Black Fire', 'Blue Fire', 'Galaxy', 'Blue Orb', 'White Orb', 'Black Orb', 'Ruby Orb', 'Gold', 'Amethyst', 'Gloomy', 'Fire & Ice'}
local jerseys = {'Default', 'Classic', 'Abstract', 'Hearts', 'Sprinkles', 'Checkerboard', 'Floral', 'Jacko', 'Snowflakes', 'Allstar', 'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Galaxy', 'Gold', 'Amethyst', 'Gloomy', 'Fire & Ice'}
local shoes = {'Default', 'Basketball', 'Cow', 'Cloudy', 'Smiley', 'Santa', 'Pink Camo', 'Magma', 'Minecraft', 'Money', 'Lightning', 'Allstar', 'Sapphire', 'Emerald', 'Ruby', 'Diamond', 'Galaxy', 'Gold', 'Amethyst', 'Gloomy', 'Fire & Ice'}
-- Values 
local autoDunkDistance = 10

-- Helper functions
function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end

function touchInterest(part)
    local char = lp.Character
    if char and firetouchinterest then
        local ball = char:FindFirstChild("Ball")
        if ball then
            firetouchinterest(ball, part, 0)
            firetouchinterest(ball, part, 1)
        end
    end
end

function getAccuracy()
    local accuracy = lp.leaderstats.Rebirths.Value * 15 + rs.Items.Jerseys[rs.Players.bartvanm.Equipped.Jerseys.Value].Accuracy.Value + rs.Items.Shoes[rs.Players.bartvanm.Equipped.Shoes.Value].Accuracy.Value
    return accuracy
end

function calculateDistance(accuracy)
    local distance = accuracy/4
    return distance
end

function fly()
	local T = getRoot(lp.Character)
	local SPEED = 0
	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat wait()
				if lp.Character:FindFirstChildOfClass('Humanoid') then
					lp.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
                SPEED = 0
                BV.velocity = Vector3.new(0, 0, 0)
			until not FLYING
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if lp.Character:FindFirstChildOfClass('Humanoid') then
				lp.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
end

function nofly()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if lp.Character:FindFirstChildOfClass('Humanoid') then
		lp.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
end

function autoDunk()
    spawn(function () 
        while wait() do
            if not getgenv().autoDunk then lp.Character.HumanoidRootPart.Anchored = false break end
            lp.Character.HumanoidRootPart.Anchored = false    
            lp.Character.HumanoidRootPart.CFrame = ws.BlueGoal1.Score.CFrame + Vector3.new(autoDunkDistance,0,0)
            
            local ball = lp.Character:FindFirstChild("Ball")
            if ball and ball:FindFirstChildOfClass("RemoteEvent") then
                ball:FindFirstChildOfClass("RemoteEvent"):FireServer('Accuracy', 1)
                ball:FindFirstChildOfClass("RemoteEvent"):FireServer('Start')
            end
            
            for i=1,100 do
                touchInterest(ws.BlueGoal1.Score)
            end
            wait(0.01)
        end
    end)
end

function autoUpgrade()
    spawn(function () 
        while wait() do
            if not getgenv().autoUpgrade then break end
            serverEvent:FireServer('Dunk')
        end
    end)
end

function autoBalls()
    spawn(function () 
        while wait() do
            if not getgenv().autoBalls then break end
            for i, v in pairs(balls) do
                serverEvent:FireServer('Buy', 'Balls', v)
                serverEvent:FireServer('Equip', 'Balls', 'Fire & Ice')
                wait(0.1)
            end
        end
    end)
end

function autoJerseys()
    spawn(function () 
        while wait() do
            if not getgenv().autoJerseys then break end
            for i, v in pairs(jerseys) do
                serverEvent:FireServer('Buy', 'Jerseys', v)
                wait(0.1)
            end
        end
    end)
end

function autoShoes()
    spawn(function () 
        while wait() do
            if not getgenv().autoShoes then break end
            for i, v in pairs(balls) do
                serverEvent:FireServer('Buy', 'Shoes', v)
                wait(0.1)
            end
        end
    end)
end

function autoRebirth()
    spawn(function () 
        while wait() do
            if not getgenv().autoRebirth then break end
            serverEvent:FireServer('Rebirth')
        end
    end)
end

-- GUI
local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()

local w = library:CreateWindow('DUNKING MEISTER') 
local s = w:CreateFolder('Statistics😽')
local f = w:CreateFolder('Farm👨‍🌾')
local m = w:CreateFolder('Player🙉')
local d = w:CreateFolder('Demolish💥') 

s:Toggle('Auto Stats',function(bool)
    getgenv().autoStats = bool
    if bool then 
        autoStats()
    end
end)

f:Toggle('Auto Dunk',function(bool)
    getgenv().autoDunk = bool
    if bool then 
        autoDunk()
    end
end)

f:Slider('Auto Dunk Distance',{
    min = 10,
    max = 10000,
    precise = false
},function(value)
    autoDunkDistance = value 
end)

f:Toggle('Auto Upgrade',function(bool)
    getgenv().autoUpgrade = bool
    if bool then 
        autoUpgrade()
    end
end)

f:Toggle('Auto Balls',function(bool)
    getgenv().autoBalls = bool
    if bool then 
        autoBalls()
    end
end)

f:Toggle('Auto Jerseys',function(bool)
    getgenv().autoJerseys = bool
    if bool then 
        autoJerseys()
    end
end)

f:Toggle('Auto Shoes',function(bool)
    getgenv().autoShoes = bool
    if bool then 
        autoShoes()
    end
end)

f:Toggle('Auto Rebirth',function(bool)
    getgenv().autoRebirth = bool
    if bool then 
        autoRebirth()
    end
end)

m:Button('Fly',function()
    fly()
end)

m:Button('Nofly',function()
    nofly()
end)

d:Button('Teleporters',function()
    if ws.Teleporters then ws.Teleporters:Destroy() end
end)