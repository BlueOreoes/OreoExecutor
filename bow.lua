-- Multi-Execution Cleanup
wait(15)
for _, connName in pairs({
	"AimLockLoop", "AimLockInputStart", "AimLockInputEnd",
	"ArrowInputStart", "ArrowInputEnd", "ESPUpdateLoop",
	"FlyingRenderStepped", "NoclipStepped"
}) do
	if getgenv()[connName] then
		getgenv()[connName]:Disconnect()
		getgenv()[connName] = nil
	end
end

function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/BlueOreoes/OreoExecutor/refs/heads/main/bow.lua'))()")
LP.CameraMode = Enum.CameraMode.LockFirstPerson
-- start on join
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local duration = 2 -- total time to move
local stepTime = 0.05 -- how often to teleport (seconds)
local stepSize = 2 -- how far to teleport each step (studs)

local steps = math.floor(duration / stepTime)
local function stepForwardAndJump()
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    -- Fully unsit by removing seat welds
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Weld") or v:IsA("Motor6D") then
            if v.Part0 and v.Part1 and (v.Part0:IsA("Seat") or v.Part1:IsA("Seat")) then
                v:Destroy()
            end
        end
    end
    if humanoid then
        humanoid.Sit = false
    end

    -- Walk forward in steps
    local duration = 3
    local stepTime = 0.05
    local stepSize = 2
    local steps = math.floor(duration / stepTime)

    for i = 1, steps do
        if humanoid then
            humanoid.Sit = false
        end
        hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * stepSize
        task.wait(stepTime)
    end

    -- Jump
    if humanoid then
        humanoid.Jump = true
    end
    if humanoid then
        humanoid.Jump = true
        task.wait(0.1)
        humanoid.Health = 0 -- kill the player
    end
    
    

end
stepForwardAndJump()
if getgenv().ESPObjects then
	for _, obj in pairs(getgenv().ESPObjects) do
		obj:Remove()
	end
end
getgenv().ESPObjects = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Core References
local plr = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Config
local Death = false
local AimPart = "HumanoidRootPart"
local Epitaph = 0.187
local HeadOffset = Vector3.new(0, 2.75, 0)
local FOVRadius = 200
local screenOffset = Vector2.new(0, -25) -- aim higher for crosshair correction
local flyingSpeed = 100

-- States
local holdingF = false
local isHoldingRightClick = false
local lockedTarget = nil
local flying = false
local bv, bg = nil, nil

-- Utility Functions
local function getCharacter()
	return plr.Character or plr.CharacterAdded:Wait()
end

local function noclipCharacter()
	local char = getCharacter()
	for _, part in pairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end


local function shootArrow()
	local char = getCharacter()
	local bow = char:FindFirstChild("Bow") or plr.Backpack:FindFirstChild("Bow")
	if not bow then return end
	local remote = bow:FindFirstChild("RemoteEvent")
	if not remote or not remote:IsA("RemoteEvent") then return end

	local hand = char:FindFirstChild("LeftHand") or char:FindFirstChild("RightHand") or char:FindFirstChild("HumanoidRootPart")
	local arrowOffset = bow:GetAttribute("ArrowSpawnOffset") or Vector3.new(0, 0, 0)
	local spawnCF = hand and hand.CFrame:ToWorldSpace(CFrame.new(arrowOffset)) or char:GetPivot()

	local position = spawnCF.Position
	local direction = camera.CFrame.LookVector
	local arrowId = math.random(100000, 999999)

	remote:FireServer("Shoot", arrowId, position, direction, 1, 1, 1, nil)

	local fired = bow:FindFirstChild("Fired")
	if fired and fired:IsA("RemoteEvent") then
		fired:FireServer()
	end
end

-- ESP Helpers
local function removeESPBox(player)
	if getgenv().ESPObjects[player] then
		getgenv().ESPObjects[player]:Remove()
		getgenv().ESPObjects[player] = nil
	end
end

-- ESP Loop
getgenv().ESPUpdateLoop = RunService.RenderStepped:Connect(function()
	for _, other in pairs(Players:GetPlayers()) do
		if other ~= plr and other.Character then
			local hrp = other.Character:FindFirstChild("HumanoidRootPart")
			local hum = other.Character:FindFirstChild("Humanoid")

			if hrp and hum and hum.Health > 0 then
				local distance = (camera.CFrame.Position - hrp.Position).Magnitude
				if distance <= 2000 then
					if not getgenv().ESPObjects[other] then
						local box = Drawing.new("Square")
						box.Thickness = 1
						box.Filled = true
						box.Color = Color3.fromRGB(255, 0, 0)
						box.Transparency = 0.5
						box.Visible = false
						getgenv().ESPObjects[other] = box
					end

					local box = getgenv().ESPObjects[other]
					local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)

					if onScreen then
						local scale = 1 / (camera.CFrame.Position - hrp.Position).Magnitude * 100
						box.Size = Vector2.new(40, 40) * scale
						box.Position = Vector2.new(pos.X, pos.Y) - box.Size / 2
						box.Visible = true
					else
						box.Visible = false
					end
				else
					removeESPBox(other)
				end
			else
				removeESPBox(other)
			end
		else
			removeESPBox(other)
		end
	end
end)

-- Target validation
local function isValidTarget(player)
	if not player or player == plr or not player.Character then return false end
	local part = player.Character:FindFirstChild(AimPart)
	local hum = player.Character:FindFirstChild("Humanoid")
	if not part or not hum or hum.Health <= 0 then return false end
	if (camera.CFrame.Position - part.Position).Magnitude > 2000 then return false end
	return true
end

-- Get closest player to mouse inside FOV
local function getClosestPlayer()
	local mousePos = UIS:GetMouseLocation()
	local closest, shortest = nil, math.huge

	for _, other in ipairs(Players:GetPlayers()) do
		if isValidTarget(other) then
			local part = other.Character:FindFirstChild(AimPart)
			local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
				if mag < shortest then
					shortest = mag
					closest = other
				end
			end
		end
	end

	return closest
end

-- AimLock Loop
getgenv().AimLockLoop = RunService.RenderStepped:Connect(function()
	if isHoldingRightClick then
		if not isValidTarget(lockedTarget) then
			lockedTarget = getClosestPlayer()
			
		end

		if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild(AimPart) then
			local root = lockedTarget.Character[AimPart]
			local predicted = root.Position + root.Velocity * Epitaph + HeadOffset
			local screenPos = camera:WorldToViewportPoint(predicted)
			local aimPoint = Vector2.new(screenPos.X, screenPos.Y) + screenOffset
			local ray = camera:ViewportPointToRay(aimPoint.X, aimPoint.Y)
			camera.CFrame = CFrame.lookAt(camera.CFrame.Position, ray.Origin + ray.Direction * 100)
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	end
    
    if isHoldingRightClick and not lockedTarget then
        print("hi")
        local player = game.Players.LocalPlayer
        local camera = workspace.CurrentCamera
        
        local function rotateCameraRight(degrees)
            local rotation = CFrame.Angles(0, math.rad(degrees), 0)
            camera.CFrame = camera.CFrame * rotation
        end
        
        -- Example: rotate camera right by 10 degrees once
        rotateCameraRight(10)

    end 
	if holdingF then
		shootArrow()
		wait(0.1)
	end
	local Players = game:GetService("Players")
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()  -- waits for character if not loaded yet
    
    if char:FindFirstChild("Bow") then
        return
    else
        game:GetService("ReplicatedStorage").RemoteEvents.EquipBow:FireServer()
    end
end)

-- Flying Functions
local function startFlying()
	local char = getCharacter()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	flying = true
	hum.PlatformStand = true

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.Parent = hrp

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.P = 9e4
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp

	getgenv().FlyingRenderStepped = RunService.RenderStepped:Connect(function()
		if not flying or not bv or not bv.Parent then return end

		if lockedTarget and isValidTarget(lockedTarget) and hrp then
			local targetPos = lockedTarget.Character[AimPart].Position
			local direction = (targetPos - hrp.Position).Unit
			bv.Velocity = direction * flyingSpeed
			bg.CFrame = CFrame.new(hrp.Position, targetPos)
		else
			bv.Velocity = Vector3.new(0, 0, 0)
		end

		-- Keep noclip active
		noclipCharacter()

		-- Fix torso rotation caused by bow (keep torso facing HRP direction)
		local char = plr.Character
		if char then
			local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
			if torso and hrp then
				local torsoPos = torso.Position
				local hrpLook = hrp.CFrame.LookVector
				torso.CFrame = CFrame.new(torsoPos, torsoPos + hrpLook)
			end
		end
	end)
end

local function stopFlying()
	flying = false
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	if getgenv().FlyingRenderStepped then
		getgenv().FlyingRenderStepped:Disconnect()
		getgenv().FlyingRenderStepped = nil
	end
	if getgenv().NoclipStepped then
		getgenv().NoclipStepped:Disconnect()
		getgenv().NoclipStepped = nil
	end
	local char = plr.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
		for _, part in pairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end



local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local leaderstats = plr:WaitForChild("leaderstats")
local killsStat = leaderstats:WaitForChild("💀 Kills")

-- Function to check kills and do something if under 30
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local mainUI = playerGui:WaitForChild("MainUI")
local function checkKills()
    if mainUI.TopFrame.Container.NukeFrame.Visible == true then
        if killsStat.Value < 29  then
            return
        else
            flying = false
            holdingF = false
            hrp.Anchored = true
            wait(10)
            hrp.Anchored = false
            flying = true
            holdingF = true
        end
    else
        if isHoldingRightClick then
            flying = true
            holdingF = true
        end
    end
end

-- Initial check
checkKills()

-- Listen for changes and check again
killsStat.Changed:Connect(function()
    checkKills()
end)

local HttpService = game:GetService("HttpService")
local TPService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

task.spawn(function()
	while true do
		if #Players:GetPlayers() <= 3 then
			local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
			for _, s in ipairs(servers) do
				if s.playing < s.maxPlayers and s.id ~= game.JobId then
					TPService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
					break
				end
			end
		end
		task.wait(10)
	end
end)

-- Inputs
getgenv().ArrowInputStart = UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.J then
		-- Toggle flying
		if flying then
			stopFlying()
		else
			startFlying()
		end
		-- Toggle holdingF (shooting arrows)
		holdingF = not holdingF
		-- Toggle isHoldingRightClick (aimlock)
		isHoldingRightClick = not isHoldingRightClick
		
		if not isHoldingRightClick then
			lockedTarget = nil
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		else
			lockedTarget = nil -- reset on new toggle
		end
	end
end)

getgenv().ArrowInputEnd = UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		holdingF = false
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		isHoldingRightClick = false
		lockedTarget = nil
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

-- FOV Circle (visual)
local FOVCircle = getgenv().FOVCircle or Drawing.new("Circle")
FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 0, 130)
FOVCircle.Visible = true
FOVCircle.Transparency = 0
FOVCircle.NumSides = 64
FOVCircle.Thickness = 1
getgenv().FOVCircle = FOVCircle

-- Cleanup ESP when players leave
Players.PlayerRemoving:Connect(function(player)
	removeESPBox(player)
end)
-- Cleanup ESP and aimlock target if player leaves
Players.PlayerRemoving:Connect(function(player)
	removeESPBox(player)
	if lockedTarget == player then
		lockedTarget = nil
	end
end)

-- Handle player death and re-trigger J key logic on respawn
-- Simulate J key press twice on respawn
plr.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart") -- wait for character to fully load
	task.wait(1)
    game:GetService("ReplicatedStorage").RemoteEvents.EquipBow:FireServer()
	stopFlying()
    isHoldingRightClick = false
    holdingF = false
    hrp.Anchored = true
	wait(1)
	hrp.Anchored = false
	if humanoid then
        humanoid.Jump = true
    end
	isHoldingRightClick = true
	holdingF = true
    startFlying()
		

	if not isHoldingRightClick then
		lockedTarget = nil
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	else
		lockedTarget = nil
	end

	wait(0.2)
end)


-- Notify Loaded
pcall(function()
	game.StarterGui:SetCore("SendNotification", {
		Title = "Loaded",
		Text = "ESP + AimLock + Flying + Noclip integrated!",
		Duration = 5
	})
end)
