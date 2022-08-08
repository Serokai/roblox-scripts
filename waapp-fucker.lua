local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local localPlayer = Players.LocalPlayer

local locations = {
    [1] = {
        ["Name"] = "🍕 • Pizza Place",
        ["Locations"] = {
            [1] = {"Cashier Area", ("44, 4, 81")},
            [2] = {"Cooking Area", ("44, 4, 66")},
            [3] = {"Boxing Area", ("47, 4, 20")},
            [4] = {"Delivering Area", ("59, 4, -18")},
            [5] = {"Supplying Area", ("7, 13, -1032")},
			[6] = {"Unloading Area", ("20, 9, -20")},
            [7] = {"Manager Office", ("37, 4, 6")},
            [8] = {"Kick Manager", ("16, 4, 21")},
            [9] = {"Hideout", ("76, 10, 66")},
            [10] = {"Parking Lots", ("66, 3, -80")}
        }
    },
    [2] = {
        ["Name"] = "🏝️ • Islands",
        ["Locations"] = {
            [1] = {"Pirate Island", ("-953, 8, 685")},
            [2] = {"Treasure Island", ("-1761, 100, -1333")},
            [3] = {"Jordan's Island", ("1520, 0, 1359")}
        }
    },
    [3] = {
        ["Name"] = "✨ • Miscellaneous",
        ["Locations"] = {
            [1] = {"Spawn Area", ("47, 3, 185")},
            [2] = {"Skeleton Cave", ("-251, -23, -950")},
            [3] = {"The Dump", ("37, 3, -182")},
            [4] = {"Party Island", ("81, 3, -276")},
            [5] = {"Port", ("-477, 3, -355")},
            [6] = {"Krusty Crab Game", ("-478, -22, -544 ")},
            [7] = {"Treasure Chest", ("-1765, 6, -1275")}
        }
    }
}

local outfits = {
	["Luffy Gear 5"] = {
		["Shirt"] = 9287093540,
		["Pants"] = 9287096036,
		["HairAccessory"] = 9483681003,
		["Face"] = 20298988,
		["BackAccessory"] = 7859409322,
		["WaistAccessory"] = 8144108900
	},
}

local jobs = {"Cashier", "Cook", "Pizza Boxer", "Delivery", "Supplier", "On Break"}
local JOB_LOOP_DELAY = 0.25
local jobLoop = false

local UNICORN_LOOP_DELAY = 0.5
local spamUnicorn = false

local rainbowCarLoop = false
local chosenCar = nil
local RAINBOW_CAR_LOOP_DELAY = 0.5

local noClip = false

local partyIslandPosition = Workspace["Teleport to Party Island"].Head.Position
local removeManagerPosition = Workspace["Remove Manager"].Head.Position
local lostCoordinates = Vector3.new(999, 999, 999)

local wappWindow = OrionLib:MakeWindow({
    Name = "🍕 · WAAPP Fucker",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "waaap-fucker-cfg",
    IntroEnabled = false
}) 

local playerTab = wappWindow:MakeTab({
	Name = "Player",
	Icon = "rbxassetid://6034287594",
	PremiumOnly = false
})

local playerTeleport = playerTab:AddSection({
	Name = "🌌 • Teleport"
})

local playerWalkspeed = playerTab:AddSection({
	Name = "⚡ • Walkspeed"
})

local playerJumpPower = playerTab:AddSection({
	Name = "🦘 • Jump Power"
})

local playerAvatar = playerTab:AddSection({
	Name = "🗿 • Avatar"
})

local playerServer = playerTab:AddSection({
	Name = "📫 • Server"
})

local playerOther = playerTab:AddSection({
	Name = "📁 • Other"
})

local playerWalkspeedSlider = playerWalkspeed:AddSlider({
	Name = "Walkspeed",
	Min = 1,
	Max = 150,
	Default = 16,
	Color = Color3.fromRGB(39, 165, 223),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(walkSpeed)
		localPlayer.Character.Humanoid.WalkSpeed = walkSpeed
	end
})

playerWalkspeed:AddButton({
	Name = "Reset Walkspeed",
	Callback = function()
		localPlayer.Character.Humanoid.WalkSpeed = 16
		playerWalkspeedSlider:Set(16)
  	end
})

local playerJumpPowerSlider = playerJumpPower:AddSlider({
	Name = "Jump Power",
	Min = 1,
	Max = 350,
	Default = 50,
	Color = Color3.fromRGB(25, 242, 9),
	Increment = 5,
	ValueName = "Jump Power",
	Callback = function(jumpPower)
		localPlayer.Character.Humanoid.JumpPower = jumpPower
	end
})

playerJumpPower:AddButton({
	Name = "Reset Jump Power",
	Callback = function()
		localPlayer.Character.Humanoid.JumpPower = 50
		playerJumpPowerSlider:Set(50)
  	end
})

local function getOutfits()
	local availableOutfits = {}

	for outfit, _ in pairs(outfits) do
		table.insert(availableOutfits, outfit)
	end

	return availableOutfits
end

playerAvatar:AddDropdown({
	Name = "Custom Outfit",
	Default = "...",
	Options = getOutfits(),
	Callback = function(outfit)
		for accessoryType, accessoryId in pairs(outfits[outfit]) do
			print(accessoryType, accessoryId)
			ReplicatedStorage.PlayerChannel:FireServer("LoadAvatarAsset", accessoryId, accessoryType)
			task.wait(0.25)
		end
	end
})

playerAvatar:AddButton({
	Name = "Reset Outfit",
	Callback = function()
		ReplicatedStorage.PlayerChannel:FireServer("ResetAvatarAppearance", true)
  	end
})

playerOther:AddToggle({
	Name = "NoClip",
	Default = false,
	Callback = function(state)
		noClip = state

		RunService.Stepped:Connect(function()
			if noClip then
				localPlayer.Character.Head.CanCollide = false
				localPlayer.Character.Torso.CanCollide = false
			end
		end)
	end
})

playerOther:AddButton({
	Name = "Reset Character",
	Callback = function()
		local oldPlayerPosition = localPlayer.Character.HumanoidRootPart.CFrame
		localPlayer.Character.Humanoid.Health = 0
		localPlayer.CharacterAdded:Wait()
		task.wait(1)
		localPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = oldPlayerPosition
  	end
})

playerServer:AddButton({
	Name = "Rejoin Server",
	Callback = function()
		TeleportService:Teleport(game.PlaceId, localPlayer)
  	end
})

playerServer:AddButton({
	Name = "Server Hop",
	Callback = function()
		local servers = game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/192800/servers/Public?sortOrder=Asc&limit=100"))

		for _, server in pairs(servers.data) do
			if server.playing ~= server.maxPlayers then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
			end
		end
	end
})

local function GetPlayers()
	local players = {}

	for _, player in pairs(Players:GetPlayers()) do
		if player == localPlayer then continue end

		table.insert(players, player.Name)
	end

	return players
end

local playerTeleportDropdown = playerTeleport:AddDropdown({
	Name = "Teleport to Player",
	Default = "...",
	Options = GetPlayers(),
	Callback = function(player)
		if Players:FindFirstChild(player) then
			localPlayer.Character.HumanoidRootPart.CFrame = Players:FindFirstChild(player).Character.HumanoidRootPart.CFrame
		end
	end
})

local jobsTab = wappWindow:MakeTab({
	Name = "Jobs",
	Icon = "rbxassetid://6031075939",
	PremiumOnly = false
})

local jobsTeleporters = jobsTab:AddSection({
	Name = "👔 • Select Job"
})

local jobsSpam = jobsTab:AddSection({
	Name = "🎯 • Job Spam"
})

local jobsSettings = jobsTab:AddSection({
	Name = "⚙️ • Job Settings"
})

local function changeJob(job)
	if job == "On Break" then
		ReplicatedStorage.PlayerChannel:FireServer("ChangeJob", "On Break")
	elseif Workspace.JobButtons[job] then
		local jobButton = Workspace.JobButtons[job]
		jobButton.Transparency = 1
		jobButton.HumanoidBillboardGui.Enabled = false

		local jobButtonPosition = jobButton.Position
		jobButton.Position = localPlayer.Character.HumanoidRootPart.Position
		task.wait(0.025)

		jobButton.HumanoidBillboardGui.Enabled = true
		jobButton.Transparency = 0
		jobButton.Position = jobButtonPosition
	end
end

jobsTeleporters:AddDropdown({
	Name = "Selected Job",
	Default = "...",
	Options = {"Cashier", "Cook", "Pizza Boxer", "Delivery", "Supplier", "On Break"},
	Callback = function(job)
		changeJob(job)
	end
})

jobsSpam:AddToggle({
	Name = "Spam",
	Default = false,
	Callback = function(state)
		jobLoop = state
		local jobNumber = 1

		while jobLoop and task.wait(JOB_LOOP_DELAY) do
			changeJob(jobs[jobNumber])
			if jobNumber >= 6 then
				jobNumber = 1
			else
				jobNumber += 1
			end
		end
	end
})

jobsSpam:AddSlider({
	Name = "Delay",
	Min = 0.05,
	Max = 1,
	Default = 0.5,
	Color = Color3.fromRGB(255, 30, 0),
	Increment = 0.05,
	ValueName = "Second(s)",
	Callback = function(delaySeconds)
		JOB_LOOP_DELAY = delaySeconds
	end
})

jobsSettings:AddToggle({
	Name = "Notifications",
	Default = true,
	Callback = function(state)
		localPlayer.PlayerGui.MainGui.Notifications.JobChange.Visible = state
	end
})

local locationsTab = wappWindow:MakeTab({
	Name = "Locations",
	Icon = "rbxassetid://6034684937",
	PremiumOnly = false
})

for _, value in ipairs(locations) do
    local dropdownLocations = {}

	local zoneSection = locationsTab:AddSection({
		Name = value["Name"]
	})

	for _, areaValue in pairs(value["Locations"]) do
        table.insert(dropdownLocations, areaValue[1])
		zoneSection:AddButton({
			Name = areaValue[1],
			Callback = function()
				localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(areaValue[2]:match("(.+), (.+), (.+)")))
			end
		})
	end
end

local itemsTab = wappWindow:MakeTab({
	Name = "Items",
	Icon = "rbxassetid://6035056487",
	PremiumOnly = false
})

local itemsGears = itemsTab:AddSection({
	Name = "⚔️ • Gears"
})

local itemsFood = itemsTab:AddSection({
	Name = "🍗 • Food"
})

local itemsOther = itemsTab:AddSection({
	Name = "📁 Other"
})

local food = {"Bloxy Cola", "Ice Cream", "Turkey Leg", "Popcorn Machine", "Cotton Candy Machine", "Treat Bowl", "Toaster", "Blender", "Pizza", "Witch's Brew", "Sprite", "Dr Pepper", "Coke", "Monster", "Mountain Dews", "Pepsi", "Grill", "Coffee Maker"}
local sodas = {"Sprite", "Dr Pepper", "Coke", "Monster", "Mountain Dews", "Pepsi"}
local foundFood = {}

local gears = {
	["Fire Extinguisher"] = Workspace.Extinguisher.Extinguisher.ClickDetector.Detector
}
local foundGear = {}

local function findSoda(soda)
	for _, instance in pairs(Workspace:GetChildren()) do
		if instance.Name == "SodaTemplate" and instance:IsA("Tool") then
			if instance.SodaName.Value == soda then
				return instance
			end
		end
	end

	return nil
end

for _, detectorRemote in pairs(Workspace.Houses:GetDescendants()) do
	if detectorRemote:IsA("RemoteEvent") and detectorRemote.Name == "Detector" and table.find(food, detectorRemote.Parent.Parent.Name) and not table.find(foundFood, detectorRemote.Parent.Parent.Name) then
		local instance = detectorRemote.Parent.Parent
		table.insert(foundFood, instance.Name)

		itemsFood:AddButton({
			Name = instance.Name,
			Callback = function()
				detectorRemote:FireServer()

				if instance.Name == "Blender" then
					detectorRemote:FireServer()
				end

				if table.find(sodas, instance.Name) then
					task.wait(1)
					local soda = findSoda(instance.Name)

					if soda == nil then return end
					soda.Handle.CanCollide = false
					soda.Handle.Position = localPlayer.Character.HumanoidRootPart.Position
				end
			end
		})
	end
end

for gearName, remoteDetector in pairs(gears) do
	itemsGears:AddButton({
		Name = gearName,
		Callback = function()
			if gearName == "Fire Extinguisher" then
				Workspace.GameService.ExtinguisherUnequiped:FireServer()
			end

			task.wait(0.5)
			remoteDetector:FireServer()
		end
	})
end

itemsOther:AddButton({
	Name = "Inventory Clear",
	Callback = function()
		for _, tool in pairs(Workspace:FindFirstChild(localPlayer.Name):GetChildren()) do
			if tool:IsA("Tool") then
				ReplicatedStorage.PlayerChannel:FireServer("RemoveGear", tool)
			end
		end

		for _, tool in pairs(localPlayer.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				ReplicatedStorage.PlayerChannel:FireServer("RemoveGear", tool)
			end
		end
  	end
})

local killTab = wappWindow:MakeTab({
	Name = "Kill",
	Icon = "rbxassetid://6034989550",
	PremiumOnly = false
})

local function getSharkHouse()
	for _, houseInstance in pairs(Workspace.Houses:GetDescendants()) do
		if houseInstance.Name == "Shark" and houseInstance:FindFirstChild("BodyGyro") then
			return houseInstance:FindFirstAncestor("Furniture").Parent.Name
		end
	end
end

local function killPlayer(playerName)
	if Players:FindFirstChild(playerName) then
		Workspace.Houses[getSharkHouse()].Furniture["Shark Tank"].TouchEvent:FireServer(Workspace:FindFirstChild(playerName).Head, Workspace.Houses[getSharkHouse()].Furniture["Shark Tank"].Shark)
	end
end

local killDropdown = killTab:AddDropdown({
	Name = "Kill Player",
	Default = "...",
	Options = GetPlayers(),
	Callback = function(player)
		local success, _ = pcall(function()
			killPlayer(player)
		end)

		if not success then
			OrionLib:MakeNotification({
				Name = "Failed to kill player",
				Content = "Targeted player's health: " .. Workspace:FindFirstChild(player).Humanoid.Health,
				Image = "rbxassetid://6034989550",
				Time = 5
			})
		end
	end
})

local killItem = false
local canKillItem = true

function GetNearestPlayer()
    local part = localPlayer.Character.HumanoidRootPart
	local maxDistance = 25

	local nearestPlayer, nearestDistance
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name == localPlayer.Name then continue end

		local character = player.Character
		local distance = player:DistanceFromCharacter(part.Position)
		if not character or 
			distance > maxDistance or
			(nearestDistance and distance >= nearestDistance)
		then
			continue
		end
		nearestDistance = distance
		nearestPlayer = player
	end
	
	return nearestPlayer
end

killTab:AddToggle({
	Name = "Kill Item",
	Default = false,
	Callback = function(state)
		killItem = state
	end
})

local mouse = localPlayer:GetMouse()

mouse.Button1Down:Connect(function()
	if killItem and canKillItem == true then
		killPlayer(GetNearestPlayer().Name)

		canKillItem = false
		task.defer(function()
			task.wait(0.5)
			canKillItem = true
		end)
	end
end)

local autofarmTab = wappWindow:MakeTab({
	Name = "Autofarm",
	Icon = "rbxassetid://6035202043",
	PremiumOnly = false
})

local miscTab = wappWindow:MakeTab({
	Name = "Miscellaneous",
	Icon = "rbxassetid://6034509993",
	PremiumOnly = false
})

local miscCar = miscTab:AddSection({
	Name = "🌈 • Rainbow Car"
})

local miscUnicorn = miscTab:AddSection({
	Name = "🦄 • Unicorn"
})

local miscOther = miscTab:AddSection({
	Name = "📁 • Other"
})

local function getMouseTarget()
	local cursorPosition = game:GetService("UserInputService"):GetMouseLocation()
	local oray = game.workspace.CurrentCamera:ViewportPointToRay(cursorPosition.x, cursorPosition.y, 0)
	local ray = Ray.new(game.Workspace.CurrentCamera.CFrame.p,(oray.Direction * 1000))
	return workspace:FindPartOnRay(ray)
end

miscCar:AddBind({
	Name = "Select Car (Hover any car's part)",
	Default = Enum.KeyCode.C,
	Hold = false,
	Callback = function()
		local part, _ = getMouseTarget()

		if part:FindFirstAncestor("Car") and part:FindFirstAncestor("Car") ~= chosenCar then
			chosenCar = part.Parent

			StarterGui:SetCore(
            	"SendNotification",
            	{Title = "✅ - Select Car - ✅", Text = "New car set", Duration = 5}
            )
		else
			StarterGui:SetCore(
                "SendNotification",
            	{Title = "⛔ - Select Car - ⛔", Text = "Selected part is not a car", Duration = 5}
            )
		end
	end
})

local carColors = {"1004", "1017", "1009", "1020", "1019", "1010", "1032", "1031"}
local colorValue = 1

local function changeCarColors(car)
	if colorValue >= 7 then
		colorValue = 1
	end

	for _, carPart in pairs(car:GetChildren()) do
		if carPart:IsA("Part") then
			ReplicatedStorage.VehicleChannel:FireServer("Paint", carPart, "None", tonumber(carColors[colorValue]))
		end
	end

	colorValue += 1
end

rainbowCarToggle = miscCar:AddToggle({
	Name = "Enable Rainbow Car",
	Default = false,
	Callback = function(state)
		rainbowCarLoop = state

		if state == true and chosenCar == nil then
			rainbowCarToggle:Set(false)

			StarterGui:SetCore(
                "SendNotification",
            	{Title = "⛔ - Enable Rainbow Car - ⛔", Text = "No selected car", Duration = 5}
            )
		end

		while rainbowCarLoop and chosenCar ~= nil and task.wait(RAINBOW_CAR_LOOP_DELAY) do
			changeCarColors(chosenCar)
		end
	end
})

miscCar:AddSlider({
	Name = "Rainbow Car's Delay",
	Min = 0.05,
	Max = 1,
	Default = 0.5,
	Color = Color3.fromRGB(228, 34, 0),
	Increment = 0.05,
	ValueName = "Second(s)",
	Callback = function(delaySeconds)
		RAINBOW_CAR_LOOP_DELAY = delaySeconds
	end
})

local unicornToggle = miscUnicorn:AddToggle({
	Name = "Unicorn Spam",
	Default = false,
	Callback = function(state)
		spamUnicorn = state

		while spamUnicorn and task.wait(UNICORN_LOOP_DELAY) do
			ReplicatedStorage.PlayerChannel:FireServer("GiveItem", 84012460)
			mouse1click()
			task.defer(function()
				task.wait(UNICORN_LOOP_DELAY)
				for _, unicorn in pairs(localPlayer.Backpack:GetChildren()) do
					if unicorn:IsA("Tool") and unicorn.Name == "Fluffy Unicorn" then
						ReplicatedStorage.PlayerChannel:FireServer("RemoveGear", localPlayer.Backpack["Fluffy Unicorn"])
					end
				end
			end)
		end
	end
})

miscUnicorn:AddBind({
	Name = "Unicorn Keybind",
	Default = Enum.KeyCode.U,
	Hold = false,
	Callback = function()
		if spamUnicorn == true then
			unicornToggle:Set(false)
		else
			unicornToggle:Set(true)
		end
	end
})

miscUnicorn:AddSlider({
	Name = "Delay",
	Min = 0.05,
	Max = 1,
	Default = 0.5,
	Color = Color3.fromRGB(238, 15, 238),
	Increment = 0.05,
	ValueName = "Second(s)",
	Callback = function(delaySeconds)
		UNICORN_LOOP_DELAY = delaySeconds
	end
})

local function getPlayerHouse(playerName)
	local houses = {}

	for _, house in pairs(Workspace.Houses:GetChildren()) do
		if house.Owner.Value == nil then continue end
		houses[house.Owner.Value] = house
	end

	return table.find(houses, playerName)
end

local houseDropdown = miscOther:AddDropdown({
	Name = "Teleport to House",
	Default = "...",
	Options = GetPlayers(),
	Callback = function(player)
		print(getPlayerHouse(player))
	end
})

miscOther:AddToggle({
	Name = "Disable Party Island",
	Default = false,
	Callback = function(state)
		if state == true then
			Workspace["Teleport to Party Island"].Head.Position = lostCoordinates
		else
			Workspace["Teleport to Party Island"].Head.Position = partyIslandPosition
		end
	end
})

miscOther:AddToggle({
	Name = "Disable Manager Kick",
	Default = false,
	Callback = function(state)
		if state == true then
			Workspace["Remove Manager"].Head.Position = lostCoordinates
		else
			Workspace["Remove Manager"].Head.Position = removeManagerPosition
		end
	end
})

Players.PlayerAdded:Connect(function(player)
	killDropdown:Refresh(GetPlayers(), true)
	houseDropdown:Refresh(GetPlayers(), true)
	playerTeleportDropdown:Refresh(GetPlayers(), true)
end)

Players.PlayerRemoving:Connect(function(player)
	killDropdown:Refresh(GetPlayers(), true)
	houseDropdown:Refresh(GetPlayers(), true)
	playerTeleportDropdown:Refresh(GetPlayers(), true)
end)

OrionLib:Init()