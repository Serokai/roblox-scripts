--?-- [ Services ] --?--

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--?-- [ Library Initialization ] --?--

while not game:IsLoaded() do
	task.wait()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local WAAPP_WINDOW = OrionLib:MakeWindow({
    Name = "๐ ยท WAAPP Fucker",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "waaap-fucker-cfg",
    IntroEnabled = false
})

--?-- [ Common Functions ] --?--

local function sendNotification(title: string, text: number)
	StarterGui:SetCore("SendNotification", {
	Title = title,
	Text = text,
	Duration = 5
	})
end

local function getMouseTarget()
	local cursorPosition = UserInputService:GetMouseLocation()
	local oray = Workspace.CurrentCamera:ViewportPointToRay(cursorPosition.x, cursorPosition.y, 0)
	local ray = Ray.new(Workspace.CurrentCamera.CFrame.p,(oray.Direction * 1000))
	return workspace:FindPartOnRay(ray)
end

---------- ! ---------- [ ๐จ๐ปโ๐ผ Player ๐จ๐ปโ๐ผ ] ---------- ! ----------

local PLAYER_TAB = WAAPP_WINDOW:MakeTab({Name = "Player", Icon = "rbxassetid://6034287594", PremiumOnly = false})
local PLAYER_TELEPORT = PLAYER_TAB:AddSection({Name = "๐ โข Teleport"})
local PLAYER_WALKSPEED = PLAYER_TAB:AddSection({Name = "โก โข Walkspeed"})
local PLAYER_JUMP_POWER = PLAYER_TAB:AddSection({Name = "๐ฆ โข Jump Power"})
local PLAYER_KILL = PLAYER_TAB:AddSection({Name = "๐ช โข Kill"})
local PLAYER_AVATAR = PLAYER_TAB:AddSection({Name = "๐ฟ โข Avatar"})
local PLAYER_SERVER = PLAYER_TAB:AddSection({Name = "๐ซ โข Server"})
local PLAYER_OTHER = PLAYER_TAB:AddSection({Name = "๐ โข Other"})

local LOCAL_PLAYER = Players.LocalPlayer
local clickToKill = false
local loopKillAll = false
local noClip = false

local Outfits = {
	["Luffy Gear 5"] = {
		["Shirt"] = 9287093540,
		["Pants"] = 9287096036,
		["HairAccessory"] = 9483681003,
		["Face"] = 20298988,
		["BackAccessory"] = 7859409322,
		["WaistAccessory"] = 8144108900
	},
	["Roronoa Zoro"] = {
---@diagnostic disable-next-line: duplicate-index
		["HatAccessory"] = 6565124336,
---@diagnostic disable-next-line: duplicate-index
		["HatAccessory"] = 8928807994,
---@diagnostic disable-next-line: duplicate-index
		["HatAccessory"] = 5314840741,
		["Shirt"] = 9647613760,
		["Pants"] = 9647602267,
---@diagnostic disable-next-line: duplicate-index
		["HairAccessory"] = 9647602267,
---@diagnostic disable-next-line: duplicate-index
		["HairAccessory"] = 5158846147,
		["Face"] = 2936946480,
		["FaceAccessory"] = 2936946480,
		["BackAccessory"] = 9121730585,
		["WaistAccessory"] = 6347094572
	},
}

local function killPlayer(playerName: string)
	if Workspace.Houses:FindFirstChild("Shark Tank", true) then
		local sharkTank = Workspace.Houses:FindFirstChild("Shark Tank", true)
		if Players:FindFirstChild(playerName) then
			print(playerName)
			sharkTank.TouchEvent:FireServer(Workspace:FindFirstChild(playerName).Head, sharkTank.Shark)
		end
	end
end

local function findCatalogAssetId(accessory, plr) -- @Q_Q on Devforum
	local char = plr.Character
	local _,assets = pcall(function()return Players:GetCharacterAppearanceInfoAsync(plr.userId).assets end)
	
	if char and assets and type(assets) == "table" then
		
		for _,assetInfo in pairs(assets) do -- Recurse for accessory information.
			if string.find(assetInfo.assetType.name,"Accessory") or assetInfo.assetType.name == "Hat" then
				local attemptedId = assetInfo.id
				local foundHat = nil
				
				local _,Hat = pcall(function()return InsertService:LoadAsset(attemptedId)end)
				local insertedHat = Hat and Hat:GetChildren()[1]
				
				foundHat = insertedHat and char:FindFirstChild(insertedHat.Name)

				if foundHat and foundHat.Name == accessory.Name then
					return attemptedId
				end
			end
		end
	end
end

local function getPlayers()
	local players = {}

	for _, player in pairs(Players:GetPlayers()) do
		if player == LOCAL_PLAYER then continue end

		table.insert(players, player.Name)
	end

	return players
end

local function getOutfits()
	local availableOutfits = {}

	for outfit, _ in pairs(Outfits) do
		table.insert(availableOutfits, outfit)
	end

	return availableOutfits
end

local PLAYER_WALKSPEED_SLIDER = PLAYER_WALKSPEED:AddSlider({
	Name = "Walkspeed",
	Min = 1,
	Max = 150,
	Default = 16,
	Color = Color3.fromRGB(39, 165, 223),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(walkSpeed)
		LOCAL_PLAYER.Character.Humanoid.WalkSpeed = walkSpeed
	end
})

PLAYER_WALKSPEED:AddButton({
	Name = "Reset Walkspeed",
	Callback = function()
		LOCAL_PLAYER.Character.Humanoid.WalkSpeed = 16
		PLAYER_WALKSPEED_SLIDER:Set(16)
  	end
})

local PLAYER_JUMP_POWER_SLIDER = PLAYER_JUMP_POWER:AddSlider({
	Name = "Jump Power",
	Min = 1,
	Max = 350,
	Default = 50,
	Color = Color3.fromRGB(25, 242, 9),
	Increment = 5,
	ValueName = "Jump Power",
	Callback = function(jumpPower)
		LOCAL_PLAYER.Character.Humanoid.JumpPower = jumpPower
	end
})

PLAYER_JUMP_POWER:AddButton({
	Name = "Reset Jump Power",
	Callback = function()
		LOCAL_PLAYER.Character.Humanoid.JumpPower = 50
		PLAYER_JUMP_POWER_SLIDER:Set(50)
  	end
})

local KILL_DROPDOWN = PLAYER_KILL:AddDropdown({
	Name = "Kill Player",
	Default = "...",
	Options = getPlayers(),
	Callback = function(playerName)
		killPlayer(playerName)
	end
})

KILL_LOOP_KILL_ALL = PLAYER_KILL:AddToggle({
	Name = "Loop Kill All",
	Default = false,
	Callback = function(state)
		loopKillAll = state

		while loopKillAll == true and task.wait(0.1) do
			for _, player in pairs(Players:GetPlayers()) do
				if player.Name ~= LOCAL_PLAYER.Name then
					killPlayer(player.Name)
					task.wait(0.25)
				end
			end
		end
	end
})

PLAYER_KILL:AddToggle({
	Name = "Click to Kill",
	Default = false,
	Callback = function(state)
		clickToKill = state
	end
})

PLAYER_AVATAR:AddDropdown({
	Name = "Custom Outfit",
	Default = "...",
	Options = getOutfits(),
	Callback = function(outfit)
		ReplicatedStorage.PlayerChannel:FireServer("ResetAvatarAppearance", true)
		for accessoryType, accessoryId in pairs(Outfits[outfit]) do
			ReplicatedStorage.PlayerChannel:FireServer("LoadAvatarAsset", accessoryId, accessoryType)
			task.wait(0.25)
		end
	end
})

PLAYER_AVATAR:AddButton({
	Name = "Reset Outfit",
	Callback = function()
		ReplicatedStorage.PlayerChannel:FireServer("ResetAvatarAppearance", true)
  	end
})

PLAYER_OTHER:AddToggle({
	Name = "NoClip",
	Default = false,
	Callback = function(state)
		noClip = state

		RunService.Stepped:Connect(function()
			if noClip then
				LOCAL_PLAYER.Character.Head.CanCollide = false
				LOCAL_PLAYER.Character.Torso.CanCollide = false
			end
		end)
	end
})

PLAYER_OTHER:AddButton({
	Name = "Reset Character",
	Callback = function()
		local oldPlayerPosition = LOCAL_PLAYER.Character.HumanoidRootPart.CFrame
		LOCAL_PLAYER.Character.Humanoid.Health = 0
		LOCAL_PLAYER.CharacterAdded:Wait()
		task.wait(1)
		LOCAL_PLAYER.Character:WaitForChild("HumanoidRootPart").CFrame = oldPlayerPosition
  	end
})

PLAYER_SERVER:AddButton({
	Name = "Rejoin Server",
	Callback = function()
		TeleportService:Teleport(game.PlaceId, LOCAL_PLAYER)
  	end
})

PLAYER_SERVER:AddButton({
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

local PLAYER_TELEPORT_DROPDOWN = PLAYER_TELEPORT:AddDropdown({
	Name = "Teleport to Player",
	Default = "...",
	Options = getPlayers(),
	Callback = function(player)
		if Players:FindFirstChild(player) then
			LOCAL_PLAYER.Character.HumanoidRootPart.CFrame = Players:FindFirstChild(player).Character.HumanoidRootPart.CFrame
		end
	end
})

LOCAL_PLAYER:GetMouse().Button1Down:Connect(function()
	local part, _ = getMouseTarget()
	if clickToKill == true then
		if Players:FindFirstChild(part:FindFirstAncestorWhichIsA("Model").Name) and part:FindFirstAncestorWhichIsA("Model").Name ~= LOCAL_PLAYER.Name then
			killPlayer(part:FindFirstAncestorWhichIsA("Model").Name)
		else
			sendNotification("โ โข Click To Kill", "Selected part is not a player")
		end
	end
end)

---------- ! ---------- [ ๐ Jobs ๐ ] ---------- ! ----------

local JOBS_TAB = WAAPP_WINDOW:MakeTab({Name = "Jobs", Icon = "rbxassetid://6031075939", PremiumOnly = false})
local JOBS_TELEPORTERS = JOBS_TAB:AddSection({Name = "๐ โข Select Job"})
local JOBS_SPAM = JOBS_TAB:AddSection({Name = "๐ฏ โข Job Spam"})
local JOBS_SETTINGS = JOBS_TAB:AddSection({Name = "โ๏ธ โข Job Settings"})

local Jobs = {"Cashier", "Cook", "Pizza Boxer", "Delivery", "Supplier", "On Break"}
local JOB_LOOP_DELAY = 0.25
local jobLoop = false

local function changeJob(job: string)
	if job == "On Break" then
		ReplicatedStorage.PlayerChannel:FireServer("ChangeJob", "On Break")
	elseif Workspace.JobButtons[job] then
		local jobButton = Workspace.JobButtons[job]
		jobButton.Transparency = 1
		jobButton.HumanoidBillboardGui.Enabled = false

		local jobButtonPosition = jobButton.Position
		jobButton.Position = LOCAL_PLAYER.Character.HumanoidRootPart.Position
		task.wait(0.025)

		jobButton.HumanoidBillboardGui.Enabled = true
		jobButton.Transparency = 0
		jobButton.Position = jobButtonPosition
	end
end

JOBS_TELEPORTERS:AddDropdown({
	Name = "Selected Job",
	Default = "...",
	Options = {"Cashier", "Cook", "Pizza Boxer", "Delivery", "Supplier", "On Break"},
	Callback = function(job)
		changeJob(job)
	end
})

JOBS_SPAM:AddToggle({
	Name = "Spam",
	Default = false,
	Callback = function(state)
		jobLoop = state
		local jobNumber = 1

		while jobLoop and task.wait(JOB_LOOP_DELAY) do
			changeJob(Jobs[jobNumber])
			if jobNumber >= 6 then
				jobNumber = 1
			else
				jobNumber += 1
			end
		end
	end
})

JOBS_SPAM:AddSlider({
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

JOBS_SETTINGS:AddToggle({
	Name = "Notifications",
	Default = true,
	Callback = function(state)
		LOCAL_PLAYER.PlayerGui.MainGui.Notifications.JobChange.Visible = state
	end
})

---------- ! ---------- [ ๐ Locations ๐ ] ---------- ! ----------

local LOCATIONS_TAB = WAAPP_WINDOW:MakeTab({Name = "Locations", Icon = "rbxassetid://6034684937", PremiumOnly = false})

local Locations = {
    [1] = {
        ["Name"] = "๐ โข Pizza Place",
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
        ["Name"] = "๐๏ธ โข Islands",
        ["Locations"] = {
            [1] = {"Pirate Island", ("-953, 8, 685")},
            [2] = {"Treasure Island", ("-1761, 100, -1333")},
            [3] = {"Jordan's Island", ("1520, 0, 1359")}
        }
    },
    [3] = {
        ["Name"] = "โจ โข Miscellaneous",
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

local function returnCategoryLocations(locations)
	local locationsTable = {}

	for _, value in ipairs(locations) do
		table.insert(locationsTable, value[1])
	end

	return locationsTable
end

local function getLocationCoordinates(locations, locationToTeleport)
	for _, value in ipairs(locations) do
		if value[1] == locationToTeleport then
			return value[2]
		end
	end
end

for _, value in ipairs(Locations) do
	local dropdownLocation = LOCATIONS_TAB:AddDropdown({
		Name = value["Name"],
		Default = "...",
		Options = returnCategoryLocations(value["Locations"]),
		Callback = function(locationToTeleport)
			LOCAL_PLAYER.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(getLocationCoordinates(value["Locations"], locationToTeleport):match("(.+), (.+), (.+)")))
		end
	})
end

---------- ! ---------- [ ๐ท๏ธ Items ๐ท๏ธ ] ---------- ! ----------

local ITEMS_TAB = WAAPP_WINDOW:MakeTab({Name = "Items", Icon = "rbxassetid://6035056487", PremiumOnly = false})
local ITEMS_GEARS = ITEMS_TAB:AddSection({Name = "โ๏ธ โข Gears"})
local ITEMS_FOOD = ITEMS_TAB:AddSection({Name = "๐ โข Food"})
local ITEMS_OTHER = ITEMS_TAB:AddSection({Name = "๐ Other"})

local Food = {"Bloxy Cola", "Ice Cream", "Turkey Leg", "Popcorn Machine", "Cotton Candy Machine", "Treat Bowl", "Toaster", "Blender", "Pizza", "Witch's Brew", "Sprite", "Dr Pepper", "Coke", "Monster", "Mountain Dews", "Pepsi", "Grill", "Coffee Maker"}
local Sodas = {"Sprite", "Dr Pepper", "Coke", "Monster", "Mountain Dews", "Pepsi"}
local FoundFood = {}
local Gears = {
	["Fire Extinguisher"] = Workspace.Extinguisher.Extinguisher.ClickDetector.Detector
}

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

ITEMS_OTHER:AddButton({
	Name = "Inventory Clear",
	Callback = function()
		for _, tool in pairs(Workspace:FindFirstChild(LOCAL_PLAYER.Name):GetChildren()) do
			if tool:IsA("Tool") then
				ReplicatedStorage.PlayerChannel:FireServer("RemoveGear", tool)
			end
		end

		for _, tool in pairs(LOCAL_PLAYER.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				ReplicatedStorage.PlayerChannel:FireServer("RemoveGear", tool)
			end
		end
  	end
})

for _, detectorRemote in pairs(Workspace.Houses:GetDescendants()) do
	if detectorRemote:IsA("RemoteEvent") and detectorRemote.Name == "Detector" and table.find(Food, detectorRemote.Parent.Parent.Name) and not table.find(FoundFood, detectorRemote.Parent.Parent.Name) then
		local instance = detectorRemote.Parent.Parent
		table.insert(FoundFood, instance.Name)

		ITEMS_FOOD:AddButton({
			Name = instance.Name,
			Callback = function()
				detectorRemote:FireServer()

				if instance.Name == "Blender" then
					detectorRemote:FireServer()
				end

				if table.find(Sodas, instance.Name) then
					task.wait(1)
					local soda = findSoda(instance.Name)

					if soda == nil then return end
					soda.Handle.CanCollide = false
					soda.Handle.Position = LOCAL_PLAYER.Character.HumanoidRootPart.Position
				end
			end
		})
	end
end

for gearName, remoteDetector in pairs(Gears) do
	ITEMS_GEARS:AddButton({
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

---------- ! ---------- [ ๐ค Autofarm ๐ค ] ---------- ! ----------

-- local autofarmTab = wappWindow:MakeTab({
-- 	Name = "Autofarm",
-- 	Icon = "rbxassetid://6035202043",
-- 	PremiumOnly = false
-- })

---------- ! ---------- [ โ๏ธ Miscellaneous โ๏ธ ] ---------- ! ----------

local MISC_TAB = WAAPP_WINDOW:MakeTab({Name = "Miscellaneous", Icon = "rbxassetid://6034509993", PremiumOnly = false})
local MISC_CAR = MISC_TAB:AddSection({Name = "๐ โข Rainbow Car"})
local MISC_UNICORN = MISC_TAB:AddSection({Name = "๐ฆ โข Unicorn"})
local MISC_OTHER = MISC_TAB:AddSection({Name = "๐ โข Other"})

local carColors = {"1004", "1017", "1009", "1020", "1019", "1010", "1032", "1031"}
local colorValue = 1
local rainbowCarLoop = false
local chosenCar = nil
local RAINBOW_CAR_LOOP_DELAY = 0.5

local UNICORN_LOOP_DELAY = 0.5
local spamUnicorn = false

local partyIslandPosition = Workspace["Teleport to Party Island"].Head.Position
local removeManagerPosition = Workspace["Remove Manager"].Head.Position
local lostCoordinates = Vector3.new(999, 999, 999)

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

local function getPlayerHouse(playerName)
	local houses = {}

	for _, house in pairs(Workspace.Houses:GetChildren()) do
		if house.Owner.Value == nil then continue end
		houses[house.Owner.Value] = house
	end

	return table.find(houses, playerName)
end

MISC_CAR:AddBind({
	Name = "Select Car (Hover any car's part)",
	Default = Enum.KeyCode.C,
	Hold = false,
	Callback = function()
		local part, _ = getMouseTarget()

		if part:FindFirstAncestor("Car") and part:FindFirstAncestor("Car") ~= chosenCar then
			chosenCar = part.Parent
			sendNotification("โ โข Select Car", "New car set")
		else
			sendNotification("โ โข Select Car", "Selected part is not a car")
		end
	end
})

rainbowCarToggle = MISC_CAR:AddToggle({
	Name = "Enable Rainbow Car",
	Default = false,
	Callback = function(state)
		rainbowCarLoop = state

		if state == true and chosenCar == nil then
			rainbowCarToggle:Set(false)
			sendNotification("โ โข Enable Rainbow Car", "No selected car")
		end

		while rainbowCarLoop and chosenCar ~= nil and task.wait(RAINBOW_CAR_LOOP_DELAY) do
			changeCarColors(chosenCar)
		end
	end
})

MISC_CAR:AddSlider({
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

local unicornToggle = MISC_UNICORN:AddToggle({
	Name = "Unicorn Spam",
	Default = false,
	Callback = function(state)
		spamUnicorn = state

		while spamUnicorn and task.wait(UNICORN_LOOP_DELAY) do
			ReplicatedStorage.PlayerChannel:FireServer("GiveItem", 84012460)
			mouse1click()
			task.defer(function()
				task.wait(UNICORN_LOOP_DELAY)
				for _, unicorn in pairs(LOCAL_PLAYER.Backpack:GetChildren()) do
					if unicorn:IsA("Tool") and unicorn.Name == "Fluffy Unicorn" then
						ReplicatedStorage.PlayerChannel:FireServer("RemoveGear", LOCAL_PLAYER.Backpack["Fluffy Unicorn"])
					end
				end
			end)
		end
	end
})

MISC_UNICORN:AddBind({
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

MISC_UNICORN:AddSlider({
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

local HOUSE_DROPDOWN = MISC_OTHER:AddDropdown({
	Name = "Teleport to House",
	Default = "...",
	Options = getPlayers(),
	Callback = function(player)
		print(getPlayerHouse(player))
	end
})

MISC_OTHER:AddToggle({
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

MISC_OTHER:AddToggle({
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

--?-- [ Connections ] --?--

Players.PlayerAdded:Connect(function(player)
	KILL_DROPDOWN:Refresh(getPlayers(), true)
	HOUSE_DROPDOWN:Refresh(getPlayers(), true)
	PLAYER_TELEPORT_DROPDOWN:Refresh(getPlayers(), true)
end)

Players.PlayerRemoving:Connect(function(player)
	KILL_DROPDOWN:Refresh(getPlayers(), true)
	HOUSE_DROPDOWN:Refresh(getPlayers(), true)
	PLAYER_TELEPORT_DROPDOWN:Refresh(getPlayers(), true)
end)

--?-- [ Orion Init ] --?--

OrionLib:Init()