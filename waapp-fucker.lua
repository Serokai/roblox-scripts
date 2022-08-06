local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local localPlayer = Players.LocalPlayer

local locations = {
    [1] = {
        ["Name"] = "Pizza Place",
        ["Locations"] = {
            [1] = {"Cashier Area", ("44, 4, 81")},
            [2] = {"Cooking Area", ("44, 4, 66")},
            [3] = {"Boxing Area", ("47, 4, 20")},
            [4] = {"Delivering Area", ("59, 4, -18")},
            [5] = {"Supplying Area", ("7, 13, -1032")},
            [6] = {"Manager Office", ("37, 4, 6")},
            [7] = {"Kick Manager", ("16, 4, 21")},
            [8] = {"Unloading Area", ("20, 9, -20")},
            [9] = {"Hideout", ("76, 10, 66")},
            [10] = {"Parking Lots", ("66, 3, -80")}
        }
    },
    [2] = {
        ["Name"] = "Islands",
        ["Locations"] = {
            [1] = {"Pirate Island", ("-953, 8, 685")},
            [2] = {"Treasure Island", ("-1761, 100, -1333")},
            [3] = {"Jordan's Island", ("1520, 0, 1359")}
        }
    },
    [3] = {
        ["Name"] = "Miscellaneous",
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

local jobs = {"Cashier", "Cook", "Pizza Boxer", "Delivery", "Supplier", "On Break"}
local JOB_LOOP_DELAY = 0.25
local jobLoop = false

local UNICORN_LOOP_DELAY = 0.5
local spamUnicorn = false

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

playerTab:AddSlider({
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

playerTab:AddSlider({
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

local function GetPlayers()
	local players = {}

	for _, player in pairs(Players:GetPlayers()) do
		if player == localPlayer then continue end

		table.insert(players, player.Name)
	end

	return players
end

playerTab:AddDropdown({
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
	Name = "Select Job"
})

local jobsSpam = jobsTab:AddSection({
	Name = "Job Spam"
})

local jobsAfk = jobsTab:AddSection({
	Name = "Job AFK"
})

local jobsSettings = jobsTab:AddSection({
	Name = "Job Settings"
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

for _, job in pairs(jobs) do
	jobsTeleporters:AddButton({
		Name = job,
		Callback = function()
			changeJob(job)
		end
	})
end

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

local miscUnicorn = miscTab:AddSection({
	Name = "Unicorn"
})

local miscOther = miscTab:AddSection({
	Name = "Others"
})

local unicornToggle = miscUnicorn:AddToggle({
	Name = "Unicorn Spam [U]",
	Default = false,
	Callback = function(state)
		spamUnicorn = state

		while spamUnicorn and task.wait(UNICORN_LOOP_DELAY) do
			ReplicatedStorage.PlayerChannel:FireServer("GiveItem", 84012460)
			mouse1click()
			task.defer(function()
				task.wait(UNICORN_LOOP_DELAY)
				ReplicatedStorage.PlayerChannel:FireServer("RemoveGear", localPlayer.Backpack["Fluffy Unicorn"])
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

miscOther:AddButton({
	Name = "Fire Extinguisher",
	Callback = function()
		Workspace.Extinguisher.Extinguisher.ClickDetector.Detector:FireServer()
  	end
})

miscOther:AddButton({
	Name = "Inventory Clear",
	Callback = function()
		for _, tool in pairs(Workspace:FindFirstChild(localPlayer.Name):GetChildren()) do
			if tool:IsA("Tool")then
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

OrionLib:Init()
