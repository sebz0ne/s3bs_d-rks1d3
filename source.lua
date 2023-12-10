getgenv().Config = {
    ["Reach"] = {
        ["ReachEnabled"] = false,
        ["ReachRadius"] = 0,
        ["Lunge_Only"] = false,
        ["Damage_AMP"] = false,
        ["Auto_Swing"] = false,
    }
}

local ReachConfig = getgenv().Config.Reach

-- UI
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local UI = Material.Load({
    Title = string.format("s3bs_d@rks1d3.lua"),
    Style = 1,
    SizeX = 500,
    SizeY = 350,
    Theme = "Dark",
})

local Reach = UI.New({
    Title = "Reach"
})

local Visuals = UI.New({
    Title = "Visuals"
})

local Character = UI.New({
    Title = "Character"
})

local Misc = UI.New({
    Title = "Miscellaneous"
})

local Credits = UI.New({
    Title = "READ ME"
})

local Text = Credits.Label({
    Text = "Made by seb (sebz0ne on discord)."
})

local Texta = Credits.Label({
    Text = "By using this script, you agree to the ToS."
})

-- Reach Page --

local ReachEnabled = Reach.Toggle({
    Text = "Reach Enabled",
    Callback = function(Value)
        ReachConfig.ReachEnabled = Value
    end,
})

local ReachRadius = Reach.TextField({
    Text = "Reach Radius",
    Callback = function(Value)
        ReachConfig.ReachRadius = Value
    end,
    Min = 1,
    Max = 25,
    Def = 1,
    Menu = {
		Information = function(self)
			UI.Banner({
				Text = "THIS HAS TO BE A NUMBER, OR IT WILL ERROR. THIS HAS TO BE A NUMBER, OR IT WILL ERROR. THIS HAS TO BE A NUMBER, OR IT WILL ERROR."
			})
		end
	}
})

local ReachSettings = Reach.ChipSet({
    Text = "Reach Settings",
    Callback = function(ChipSet)
        table.foreach(ChipSet, function(Option, Value)
            ReachConfig[Option] = Value
        end)
    end,

    Options = {
        Lunge_Only = {
            Enabled = false,
            Menu = {
                Information = function(self)
                    UI.Banner({
                        Text = "Only reaches, when sword is lunged."
                    })
                end
            }
        },
        Damage_AMP = {
            Enabled = false,
            Menu = {
                Information = function(self)
                    UI.Banner({
                        Text = "Reach does excessive damage."
                    })
                end
            }
        },
        Auto_Swing = {
            Enabled = false,
            Menu = {
                Information = function(self)
                    UI.Banner({
                        Text = "Automatically lunges your sword."
                    })
                end
            }
        },
    }
})

-- // functionality

local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = PlayerService.LocalPlayer
local LPCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()


local GetHandles = function(Character)
    local Handles = {}

	if not Character and not Character["Right Arm"] then return end

    if Character and Character["Right Arm"] then
        local TableOfParts = workspace:GetPartBoundsInBox(Character["Right Arm"].CFrame * CFrame.new(1,1,0), Vector3.new(4,4,4))

        for _, Handle in pairs(TableOfParts) do
            if Handle:FindFirstChildOfClass("TouchTransmitter") and
            Handle:IsDescendantOf(Character) then
                table.insert(Handles, Handle)
            end
        end
    end

    if #Handles <= 0 then
        for _,x in pairs(LocalPlayer.Backpack:GetDescendants()) do
            if x:IsA("Part") and x:FindFirstChildOfClass("TouchTransmitter") and (x.Parent:IsA("Tool") or x.Parent.Parent:IsA("Tool")) then
                table.insert(Handles, x)
            end
        end
    end

    return Handles
end


local IsLunging = function(Handle)
    local tool; do
        if Handle.Parent:IsA("Tool") then tool = Handle.Parent end
        if Handle.Parent.Parent:IsA("Tool") then tool = Handle.Parent.Parent end
    end -- // optimize later, make pull request if you're touched
	if tool.GripUp == Vector3.new(1,0,0) then
		return true
	end
	return false
end

local function ValidateLimbIntegrity(Limb)
    local RealLimbs = {
        "Right Arm",
        "RightArm",
        "Right Leg",
        "RightLeg",
        "LeftArm",
        "LeftLeg",
        "Left Arm",
        "Left Leg",
        "Torso",
        "Head"
    }

    if Limb:IsA("Part") and Limb.CanTouch then
        local LimbName = Limb.Name
        local LimbChar = Limb.Parent
        local Humanoid = LimbChar:FindFirstChild("Humanoid")

        if Humanoid and table.find(RealLimbs, LimbName) then
            local Validated = Humanoid:GetLimb(Limb)
            if Validated then
                return true
            end
        end
    end

    return false
end


local function FakeTouchEvent(Handle, Limb) -- will be writing more for next update
    firetouchinterest(Handle, Limb, 1)
    firetouchinterest(Handle, Limb, 0)
end

RunService.RenderStepped:Connect(function(deltaTime)
    local d,ebug = pcall(function()
        if LocalPlayer.Character and (LPCharacter ~= LocalPlayer.Character) then LPCharacter = LocalPlayer.Character end
        if not ReachConfig.ReachEnabled then return end
        for _, Player in PlayerService:GetPlayers() do
            if Player ~= LocalPlayer then
                local MainHandle = GetHandles(LPCharacter)[1] -- Likely
                
                if Player.Character and Player.Character.Humanoid and Player.Character.Humanoid.Health ~= 0 then
                    local OppCharacter = Player.Character

                    if OppCharacter:FindFirstChild("HumanoidRootPart") then
            
                        local DistPart2 = OppCharacter:FindFirstChild("HumanoidRootPart")

                        if (MainHandle.Position - DistPart2.Position).Magnitude <= tonumber(ReachConfig.ReachRadius) then
            
                            for _, Limb in OppCharacter:GetChildren() do
                                if ValidateLimbIntegrity(Limb) then
                                    if ReachConfig.Lunge_Only then
                                        if IsLunging(MainHandle) then
                                            for i = 1, ReachConfig.Damage_AMP and 3 or 1 do
                                                FakeTouchEvent(MainHandle, Limb)
                                            end
                                        end
                                    else
                                        for i = 1, ReachConfig.Damage_AMP and 3 or 1 do
                                            FakeTouchEvent(MainHandle, Limb)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    if not d then warn(ebug) end
end)
