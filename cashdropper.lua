-- Infinite Spins for Cash Tycoon
local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local spins = player:WaitForChild("Spins")
local spinEvent = RS:WaitForChild("Events"):WaitForChild("SpinEvent")

-- Set initial value
spins.Value = 10

-- Aggressive loop to keep spins at 10
task.spawn(function()
    while task.wait() do -- No delay, runs as fast as possible
        if spins.Value < 10 then
            spins.Value = 10
        end
    end
end)

-- Monitor changes and instantly reset to 10
spins:GetPropertyChangedSignal("Value"):Connect(function()
    if spins.Value < 10 then
        spins.Value = 10
    end
end)

print("Infinite spins enabled! Fire remote with: spinEvent:FireServer()")
print("Or enable auto-spin by uncommenting the loop below")


task.spawn(function()
    while task.wait(0.5) do
        spinEvent:FireServer()
    end
end)

