local Player = game:GetService("Players").LocalPlayer
local Character = character or Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Torso = Character:WaitForChild("Torso") 
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Mouse = Player:GetMouse()

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local RAD = math.rad
local SIN = math.sin
local COS = math.cos
local ANGLES = CFrame.Angles
local CF = CFrame.new

local DefaultAnimate = Character:FindFirstChild("Animate")
if DefaultAnimate then
	DefaultAnimate:Destroy()
end
for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
	track:Stop()
end

local ROOTJOINT = RootPart:WaitForChild("RootJoint")
local NECK = Torso:WaitForChild("Neck")
local RIGHTSHOULDER = Torso:WaitForChild("Right Shoulder")
local LEFTSHOULDER = Torso:WaitForChild("Left Shoulder")
local RIGHTHIP = Torso:WaitForChild("Right Hip")
local LEFTHIP = Torso:WaitForChild("Left Hip")

local ROOTC0 = CF(0, 0, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local NECKC0 = CF(0, 1, 0) * ANGLES(RAD(-90), RAD(0), RAD(180))
local RIGHTSHOULDERC0 = CF(-0.5, 0, 0) * ANGLES(RAD(0), RAD(90), RAD(0))
local LEFTSHOULDERC0 = CF(0.5, 0, 0) * ANGLES(RAD(0), RAD(-90), RAD(0))
local RIGHTHIPC0 = CF(0.5, 1, 0) * ANGLES(RAD(0), RAD(90), RAD(0))
local LEFTHIPC0 = CF(-0.5, 1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0))

local HOLD = Instance.new("Weld")
HOLD.Name = "HoldWeld"
local GRIPC0 = CFrame.new(0, 0, 0)

local SINE = 0
local ANIM_SPEED = 1.5
local WALKSPEEDVALUE = 12

local ATTACKING = false
local SUBMERGED = false
local SITTING = false
local HITFLOOR = true

local function Clerp(a, b, t)
	return a:Lerp(b, t)
end

local function AttackSwing()
	if ATTACKING or SUBMERGED then return end
	ATTACKING = true
	
	task.spawn(function()
		-- Wind up
		for i = 1, 15 do
			SINE = SINE + 1
			ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, 0) * ANGLES(RAD(0), RAD(0), RAD(-10)), 1.5 / ANIM_SPEED)
			NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0, 0) * ANGLES(RAD(-10), RAD(5), RAD(0)), 1.5 / ANIM_SPEED)
			RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(90)) * ANGLES(RAD(25), RAD(180), RAD(0)) * RIGHTSHOULDERC0, 2 / ANIM_SPEED)
			LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(-5), RAD(-10), RAD(0)) * LEFTSHOULDERC0, 1.5 / ANIM_SPEED)
			RunService.RenderStepped:Wait()
		end
		-- Swing
		for i = 1, 15 do
			SINE = SINE + 1
			ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, 0) * ANGLES(RAD(0), RAD(0), RAD(10)), 1.5 / ANIM_SPEED)
			NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0, 0) * ANGLES(RAD(-10), RAD(5), RAD(-10)), 1.5 / ANIM_SPEED)
			RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.1, 0.5, -0.85) * ANGLES(RAD(0), RAD(0), RAD(-90)) * RIGHTSHOULDERC0, 0.65 / ANIM_SPEED)
			LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(-20), RAD(0), RAD(-15)) * LEFTSHOULDERC0, 1.5 / ANIM_SPEED)
			RunService.RenderStepped:Wait()
		end
		
		ATTACKING = false
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Q submerged
	if input.KeyCode == Enum.KeyCode.Q then
		if not ATTACKING then
			SUBMERGED = not SUBMERGED
			if SUBMERGED then
				Humanoid.WalkSpeed = 24
			else
				Humanoid.WalkSpeed = 16
			end
		end
	end
	-- G scream
	if input.KeyCode == Enum.KeyCode.G then
		if not ATTACKING and not SUBMERGED then
			ATTACKING = true
			task.spawn(function()
				for i = 1, 60 do 
					SINE = SINE + 1
					ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, -0.2) * ANGLES(RAD(0), RAD(0), RAD(10)), 2 / ANIM_SPEED)
					NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0, 0) * ANGLES(RAD(25 + math.random(-5, 5)), RAD(5), RAD(math.random(-5, 5))), 2 / ANIM_SPEED)
					RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.5, 0.7, 0) * ANGLES(RAD(25), RAD(15), RAD(0)) * RIGHTSHOULDERC0, 2 / ANIM_SPEED)
					LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.5, 0.5, -0.3) * ANGLES(RAD(45), RAD(-10), RAD(25)) * LEFTSHOULDERC0, 2 / ANIM_SPEED)
					RunService.RenderStepped:Wait()
				end
				ATTACKING = false
			end)
		end
	end
end)

Mouse.Button1Down:Connect(AttackSwing)
UserInputService.TouchTap:Connect(AttackSwing)

RunService.Stepped:Connect(function()
	if SUBMERGED then
		for _, part in ipairs(Character:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	SINE = SINE + 1
	local TORSOVELOCITY = (RootPart.Velocity * Vector3.new(1, 0, 1)).Magnitude
	SITTING = Humanoid.Sit
	local ray = Ray.new(RootPart.Position, Vector3.new(0, -3.5, 0))
	local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Character})
	HITFLOOR = hit ~= nil
	if not SUBMERGED and (TORSOVELOCITY <= 1 or not HITFLOOR or SITTING) then
		RIGHTHIP.C1 = Clerp(RIGHTHIP.C1, CF(0.5, 1, 0) * ANGLES(RAD(0), RAD(90), RAD(0)), 0.2)
		LEFTHIP.C1 = Clerp(LEFTHIP.C1, CF(-0.5, 1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)), 0.2)
		ROOTJOINT.C1 = Clerp(ROOTJOINT.C1, ROOTC0, 0.2)
	end
	if not ATTACKING then
		if SUBMERGED then
			ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, -3.5) * ANGLES(RAD(90), RAD(0), RAD(0)), 0.15)
			NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0, 0) * ANGLES(RAD(20), RAD(0), RAD(0)), 0.15)
			RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(15)) * RIGHTSHOULDERC0, 0.15)
			LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(0), RAD(0), RAD(-15)) * LEFTSHOULDERC0, 0.15)
			RIGHTHIP.C0 = Clerp(RIGHTHIP.C0, CF(1, -1, 0) * ANGLES(RAD(0), RAD(90), RAD(0)), 0.15)
			LEFTHIP.C0 = Clerp(LEFTHIP.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-90), RAD(0)), 0.15)
		elseif SITTING then
			ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, -0.5) * ANGLES(RAD(0), RAD(0), RAD(0)), 0.2)
			NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0, 0) * ANGLES(RAD(0), RAD(0), RAD(0)), 0.2)
			RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(50), RAD(10), RAD(-45)) * RIGHTSHOULDERC0, 0.2)
			LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(50), RAD(-10), RAD(45)) * LEFTSHOULDERC0, 0.2)
		elseif not HITFLOOR then
			ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, 0) * ANGLES(RAD(-10), RAD(0), RAD(0)), 0.2)
			NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0 , 0) * ANGLES(RAD(20), RAD(0), RAD(0)), 0.2)
			RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(-25), RAD(0), RAD(15)) * RIGHTSHOULDERC0, 0.2)
			LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(-25), RAD(0), RAD(-15)) * LEFTSHOULDERC0, 0.2)
		elseif TORSOVELOCITY > 1 then
			ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, -0.05) * ANGLES(RAD(5), RAD(0), RAD(0)), 0.2)
			NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0, 0) * ANGLES(RAD(5 - 1 * SIN(SINE / (WALKSPEEDVALUE / 2))), RAD(0), RAD(0)), 0.2)
			RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(25), RAD(20), RAD(5)) * RIGHTSHOULDERC0, 0.2)
			LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.45, 0.5, -0.5) * ANGLES(RAD(95), RAD(-5), RAD(-5)) * LEFTSHOULDERC0, 0.2)
			RIGHTHIP.C1 = Clerp(RIGHTHIP.C1, CF(0.5, 0.875 - 0.3 * SIN(SINE / WALKSPEEDVALUE), -0.5 * COS(SINE / WALKSPEEDVALUE) + 0.2 + 0.2 * COS(SINE / WALKSPEEDVALUE)) * ANGLES(RAD(0), RAD(90), RAD(0)) * ANGLES(RAD(0), RAD(0), RAD(35 * COS(SINE / WALKSPEEDVALUE))), 0.6 / ANIM_SPEED)
			LEFTHIP.C1 = Clerp(LEFTHIP.C1, CF(-0.5, 0.875 + 0.3 * SIN(SINE / WALKSPEEDVALUE), 0.5 * COS(SINE / WALKSPEEDVALUE) + 0.2 - 0.2 * COS(SINE / WALKSPEEDVALUE)) * ANGLES(RAD(0), RAD(-90), RAD(0)) * ANGLES(RAD(0), RAD(0), RAD(35 * COS(SINE / WALKSPEEDVALUE))), 0.6 / ANIM_SPEED)
			ROOTJOINT.C1 = Clerp(ROOTJOINT.C1, ROOTC0 * CF(0, 0, -0.015 * COS(SINE / (WALKSPEEDVALUE / 2))) * ANGLES(RAD(0), RAD(0), RAD(0)), 2 * (WALKSPEEDVALUE / 16) / ANIM_SPEED)
		else
			ROOTJOINT.C0 = Clerp(ROOTJOINT.C0, ROOTC0 * CF(0, 0, 0) * ANGLES(RAD(0), RAD(0), RAD(10)), 0.2)
			NECK.C0 = Clerp(NECK.C0, NECKC0 * CF(0, 0, 0) * ANGLES(RAD(-10), RAD(5), RAD(0)), 0.2)
			RIGHTSHOULDER.C0 = Clerp(RIGHTSHOULDER.C0, CF(1.5, 0.5, 0) * ANGLES(RAD(25), RAD(15), RAD(0)) * RIGHTSHOULDERC0, 0.2)
			LEFTSHOULDER.C0 = Clerp(LEFTSHOULDER.C0, CF(-1.5, 0.5, 0) * ANGLES(RAD(-10), RAD(-10), RAD(0)) * LEFTSHOULDERC0, 0.2)
			RIGHTHIP.C0 = Clerp(RIGHTHIP.C0, CF(1, -1, 0) * ANGLES(RAD(0), RAD(65), RAD(0)) * ANGLES(RAD(-5), RAD(0), RAD(0)), 0.2)
			LEFTHIP.C0 = Clerp(LEFTHIP.C0, CF(-1, -1, 0) * ANGLES(RAD(0), RAD(-100), RAD(0)) * ANGLES(RAD(-1), RAD(0), RAD(0)), 0.2)
		end
	end
end)