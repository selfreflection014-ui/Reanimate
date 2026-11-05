-- gObl00x Notification
game:GetService("StarterGui"):SetCore("SendNotification", { 
    Title = "gOb scripts",
    Text = "LOL Time to Exploit!",
    Icon = "rbxassetid://126389658690593",
    Duration = 15
})

if makefolder and not isfolder("Epik Musics") then
    makefolder("Epik Musics")
end

if not isfile("Epik Musics/Friday Theme.mp3") then
       writefile("Epik Musics/Friday Theme.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Friday%20Theme.mp3"))
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local Character = (typeof(character) == "Instance" and character) or (workspace:FindFirstChild(Player.Name .. "_CloneDummy")) or Player.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local RootPart = Character and Character:WaitForChild("HumanoidRootPart", 5)
local Backpack = Player:FindFirstChildOfClass("Backpack") or Player.Backpack

local SS = game:GetService("SoundService")
local RS = game:GetService("ReplicatedStorage")
local IsDancing = false
local currentAnim = nil
IT = Instance.new
V3 = Vector3.new
CF = CFrame.new
RAD = math.rad

if not Character or not Humanoid then
    warn("[gOb scripts]: Dummy character could not be found! Make sure Reanimate is active first.")
    return
end

-- ================= EMBEDDED ANIMATOR 6D PRO V4 =================
if not getgenv().Animator6DLoadedPro then
    getgenv().Animator6DLoadedPro = true

    local LocalAssetCache = {}
    local fullModel = nil
    pcall(function()
        fullModel = game:GetObjects("rbxassetid://107495486817639")[1]
        if fullModel then fullModel.Parent = workspace end
    end)

    local function LoadLocalAsset(id)
        id = tostring(id):gsub("^rbxassetid://", "")
        if LocalAssetCache[id] then return LocalAssetCache[id] end
        local found = fullModel and fullModel:FindFirstChild(id, true)
        if found then LocalAssetCache[id] = found return found end
        local ok, obj = pcall(function() return game:GetObjects("rbxassetid://" .. id)[1] end)
        if ok and obj then LocalAssetCache[id] = obj return obj end
        return nil
    end

    local R6Map = {
        ["Head"] = "Neck",
        ["Torso"] = "RootJoint",
        ["Right Arm"] = "Right Shoulder",
        ["Left Arm"] = "Left Shoulder",
        ["Right Leg"] = "Right Hip",
        ["Left Leg"] = "Left Hip"
    }

    local function ConvertToTable(kfs)
        if not (kfs and typeof(kfs) == "Instance" and kfs:IsA("KeyframeSequence")) then
            if typeof(kfs) == "Instance" then
                for _, obj in ipairs(kfs:GetDescendants()) do
                    if obj:IsA("KeyframeSequence") then kfs = obj break end
                end
            end
        end
        assert(kfs and typeof(kfs) == "Instance" and kfs:IsA("KeyframeSequence"), "Expected KeyframeSequence")
        local seq = {}
        for _, frame in ipairs(kfs:GetKeyframes()) do
            local entry = { Time = frame.Time, Data = {} }
            for _, pose in ipairs(frame:GetDescendants()) do
                if pose:IsA("Pose") and pose.Weight > 0 then
                    entry.Data[pose.Name] = { CFrame = pose.CFrame }
                end
            end
            table.insert(seq, entry)
        end
        table.sort(seq, function(a, b) return a.Time < b.Time end)
        return seq, kfs.Loop
    end

    local function BuildMotorMap(rig)
        local map, lower = {}, {}
        for _, m in ipairs(rig:GetDescendants()) do
            if m:IsA("Motor6D") then map[m.Name] = m lower[string.lower(m.Name)] = m end
        end
        return map, lower
    end

    local function FindMotor(poseName, map, lower)
        local match = R6Map[poseName] or poseName
        return map[match] or lower[string.lower(match)]
    end

    local AnimPlayer = {}
    AnimPlayer.__index = AnimPlayer

    function AnimPlayer.new(rig, kfs)
        local self = setmetatable({}, AnimPlayer)
        self.rig = rig
        self.seq, self.looped = ConvertToTable(kfs)
        self.map, self.lower = BuildMotorMap(rig)
        self.time, self.playing = 0, false
        self.length = self.seq[#self.seq].Time
        self.speed = 1
        self.savedC0 = {}
        for _, m in pairs(self.map) do self.savedC0[m] = m.C0 end
        return self
    end

    function AnimPlayer:Play(speed, loop)
        if self.playing then return end
        self.playing, self.speed = true, speed or 1
        self.looped = (loop == nil) and true or loop

        self.conn = RunService.Heartbeat:Connect(function(dt)
            if not self.playing then return end
            self.time += dt * self.speed
            if self.time > self.length then
                if self.looped then self.time -= self.length else self:Stop(true) return end
            end
            local prev = self.seq[1]
            for i = 1, #self.seq do
                if self.seq[i].Time <= self.time then prev = self.seq[i] else break end
            end
            for joint, data in pairs(prev.Data) do
                local motor = FindMotor(joint, self.map, self.lower)
                if motor then
                    pcall(function() motor.C0 = self.savedC0[motor] * data.CFrame end)
                end
            end
        end)
    end

    function AnimPlayer:Stop(restore)
        self.playing = false
        if self.conn then self.conn:Disconnect() self.conn = nil end
        if restore then
            for motor, origC0 in pairs(self.savedC0) do pcall(function() motor.C0 = origC0 end) end
        else
            for _, m in pairs(self.map) do pcall(function() m.Transform = CFrame.new() end) end
        end
    end

    getgenv().Animator6D = function(idOrInstance, speed, looped)
        local targetChar = (typeof(character) == "Instance" and character) or getgenv().Character or player.Character
        local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
        
        if targetHum then
            for _, track in ipairs(targetHum:GetPlayingAnimationTracks()) do track:Stop(0) end
            local animScript = targetChar:FindFirstChild("Animate")
            if animScript then animScript.Disabled = true end
            local animator = targetHum:FindFirstChildOfClass("Animator")
            if animator then animator:Destroy() end
        end

        local kfs
        if typeof(idOrInstance) == "Instance" then
            kfs = idOrInstance:IsA("KeyframeSequence") and idOrInstance or idOrInstance:FindFirstChildOfClass("KeyframeSequence")
        else
            local asset = LoadLocalAsset(idOrInstance)
            if asset then kfs = asset:FindFirstChildOfClass("KeyframeSequence") or asset end
        end

        if not kfs then return end

        if getgenv().currentAnimator6D then
            pcall(function() getgenv().currentAnimator6D:Stop(true) end)
        end

        local anim = AnimPlayer.new(targetChar, kfs)
        getgenv().currentAnimator6D = anim
        anim:Play(speed or 1, looped)
    end

    getgenv().Animator6DStop = function()
        if getgenv().currentAnimator6D then
            pcall(function() getgenv().currentAnimator6D:Stop(true) end)
            getgenv().currentAnimator6D = nil
        end
    end
end
-- ===============================================================

local Head = Character:FindFirstChild("Head")
RunService.RenderStepped:Connect(function(deltaTime: number)
    local function Alpha(n) return math.clamp(n * deltaTime * 60, 0, 1) end
	if Humanoid and RootPart and Head then
		Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp((RootPart.CFrame * CF(0, 1.5, 0)):PointToObjectSpace(Head.Position), Alpha(0.15))
	end
end)

local function getAssetSafe(assetId)
    local success, result = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(assetId))[1] end)
    if success then return result end
    return nil
end

local walkPackObj = getAssetSafe(11405076389)
local AnimFolder = walkPackObj and walkPackObj:FindFirstChild("R6") and walkPackObj.R6:FindFirstChild("Run + Walk + Jump + Fall R6")
AnimFolder = AnimFolder and AnimFolder:FindFirstChild("AnimSaves")

local idleObj = getAssetSafe(16600175853)
local IdleAnim = idleObj and idleObj:FindFirstChild("AnimSaves") and idleObj.AnimSaves:FindFirstChild("Idle 7") or idleObj
local WalkAnim = AnimFolder and AnimFolder:FindFirstChild("Walk V4")
local JumpAnim = AnimFolder and AnimFolder:FindFirstChild("Jump V2")
local sitObj = getAssetSafe(9904907605)
local SitAnim  = sitObj and sitObj:FindFirstChild("AnimSaves") and sitObj.AnimSaves:FindFirstChild("Bumper Kart")

local PlayerAnims = {
    Idle = { KFS = IdleAnim, IsPlaying = false },
    Walk = { KFS = WalkAnim, IsPlaying = false },
    Jump = { KFS = JumpAnim, IsPlaying = false },
    Sit  = { KFS = SitAnim,  IsPlaying = false },
}

local function playAnim(animName, looped)
    if currentAnim == animName then return end
    if getgenv().Animator6DStop then getgenv().Animator6DStop() end
    local anim = PlayerAnims[animName]
    if anim and anim.KFS then
        for _, data in pairs(PlayerAnims) do data.IsPlaying = false end
        anim.IsPlaying = true
        currentAnim = animName
        getgenv().Animator6D(anim.KFS, 1, looped)
    end
end

RunService.RenderStepped:Connect(function(deltaTime)
	if not Humanoid or not Humanoid.Parent then return end
	local moving = Humanoid.MoveDirection.Magnitude > 0
	local jumping = Humanoid.FloorMaterial == Enum.Material.Air
	local sitting = Humanoid.Sit or (Humanoid:GetState() == Enum.HumanoidStateType.Seated)
	if IsDancing then return end
	if sitting then if not PlayerAnims.Sit.IsPlaying then playAnim("Sit", true) end return end
	if jumping then if not PlayerAnims.Jump.IsPlaying then playAnim("Jump", false) end return end
	if moving then if not PlayerAnims.Walk.IsPlaying then playAnim("Walk", true) end
	else if not PlayerAnims.Idle.IsPlaying then playAnim("Idle", true) end end
end)

local EffectFolder = Character:FindFirstChild("EffectFolder")
if not EffectFolder then
	EffectFolder = IT("Folder")
	EffectFolder.Name = "EffectFolder"
	EffectFolder.Parent = Character
end

local box = IT("SpecialMesh")
box.MeshId = "rbxassetid://1439035575"
box.TextureId = "rbxassetid://1439035619"
box.Scale = V3(1, 1, 1.5)
box.Offset = V3(0, -0.4, 0)
box.Parent = EffectFolder

local maraca = IT("SpecialMesh")
maraca.Name = "Maraca"
maraca.MeshId = "rbxassetid://21334876"
maraca.TextureId = "rbxassetid://21334865"
maraca.Scale = V3(1, 1, 1)
maraca.Offset = V3(0, 1, -0.1)
maraca.Parent = EffectFolder

local function createSound(name)
    local s = IT("Sound")
    s.Name = name
    s.Parent = EffectFolder
    return s
end

local Music1 = createSound("The Hero")
local Music2 = createSound("Two")
local Music3 = createSound("Rat Dance")
local Music4 = createSound("Kazotsky Kick")
local Music5 = createSound("Boppin")
local Music6 = createSound("Moongazer")
local Music7 = createSound("Insanity")
local Music8 = createSound("Wait")
local Music9 = createSound("Goopie")
local Music10 = createSound("Fresh")
local Music11 = createSound("Chinese Dance")
local Music12 = createSound("Mr.WMD Boombox")
local Music13 = createSound("Take The L")
local Music14 = createSound("Secret")
local Music15 = createSound("Caramelldansen")
local Music16 = createSound("Cha Cha")
local Music17 = createSound("Boogie Down")
local Music18 = createSound("Mio Honda Step")
local Music19 = createSound("Fright Funk")
local Music20 = createSound("Shigure")
local Music21 = createSound("Rakuten")
local Music22 = createSound("Hakari")
local Music23 = createSound("Hey Ya")
local Music24 = createSound("Lemon Melon Cookie")
local Music25 = createSound("Doodle")
local Music26 = createSound("Smug")
local Music27 = createSound("The Cat")
local Music28 = createSound("The Sunshine Pogger")
local Music29 = createSound("Summer")
local Music30 = createSound("Locked")

local mainEmotesObj = getAssetSafe(78336237992558)
local R6Emotes = mainEmotesObj and mainEmotesObj:FindFirstChild("Main Emotes") and mainEmotesObj["Main Emotes"]:FindFirstChild("AnimSaves")
if not R6Emotes then R6Emotes = IT("Folder") R6Emotes.Name = "R6EmotesStorage" end
R6Emotes.Parent = RS

local theme = IT("Sound", SS)
theme.Name = "THEME"
theme.SoundId = getcustomasset("Epik Musics/Friday Theme.mp3")
theme.Volume = 0.75
theme.Looped = true
theme:Play()

local function playSoundSafe(soundObj, assetPath)
    if Character and Character.Parent then
        soundObj.Parent = Character
        soundObj.SoundId = getcustomasset(assetPath)
        soundObj.Looped = true
        soundObj:Play()
    end
end

local function stopSoundSafe(soundObj)
    if soundObj.Playing then soundObj:Stop() end
    if EffectFolder and EffectFolder.Parent then soundObj.Parent = EffectFolder end
end

local tool1 = IT("Tool", Backpack)
tool1.Name = "The Hero"
tool1.RequiresHandle = false
if not isfile("Epik Musics/The Hero.mp3") then
       writefile("Epik Musics/The Hero.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/The%20Hero.mp3"))
end
local Hero = R6Emotes and R6Emotes:FindFirstChild("The Hero")

tool1.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 10
        if Hero then getgenv().Animator6D(Hero, 1, true) end
        playSoundSafe(Music1, "Epik Musics/The Hero.mp3")
    end
end)
tool1.Unequipped:Connect(function()
    stopSoundSafe(Music1)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
    Humanoid.WalkSpeed = 16
end)

local tool2 = IT("Tool", Backpack)
tool2.Name = "Two"
tool2.RequiresHandle = false
if not isfile("Epik Musics/Two.mp3") then
       writefile("Epik Musics/Two.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Two.mp3"))
end

tool2.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(107261816578577, 1, true)
        playSoundSafe(Music2, "Epik Musics/Two.mp3")
    end
end)
tool2.Unequipped:Connect(function()
    stopSoundSafe(Music2)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool3 = IT("Tool", Backpack)
tool3.Name = "Rat Dance"
tool3.RequiresHandle = false
if not isfile("Epik Musics/rat.mp3") then
       writefile("Epik Musics/rat.mp3", game:HttpGet("https://github.com/Nitro-GT/music/raw/refs/heads/main/rat.mp3"))
end

tool3.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(117971041844492, 1, true)
        playSoundSafe(Music3, "Epik Musics/rat.mp3")
    end
end)
tool3.Unequipped:Connect(function()
    stopSoundSafe(Music3)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool4 = IT("Tool", Backpack)
tool4.Name = "Kazotsky Kick"
tool4.RequiresHandle = false
if not isfile("Epik Musics/Kazotsky Kick.mp3") then
       writefile("Epik Musics/Kazotsky Kick.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Kazotsky%20Kick.mp3"))
end
local RussianDance = R6Emotes:FindFirstChild("Kazotsky Kick")

tool4.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 6
        if RussianDance then getgenv().Animator6D(RussianDance, 1, true) end
        playSoundSafe(Music4, "Epik Musics/Kazotsky Kick.mp3")
    end
end)
tool4.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music4)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool5 = IT("Tool", Backpack)
tool5.Name = "Boppin"
tool5.RequiresHandle = false
if not isfile("Epik Musics/Boppin.mp3") then
       writefile("Epik Musics/Boppin.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Boppin.mp3"))
end

tool5.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(15710560047, 1, true)
        playSoundSafe(Music5, "Epik Musics/Boppin.mp3")
    end
end)
tool5.Unequipped:Connect(function()
    stopSoundSafe(Music5)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool6 = IT("Tool", Backpack)
tool6.Name = "Moongazer"
tool6.RequiresHandle = false
if not isfile("Epik Musics/Moongazer.mp3") then
       writefile("Epik Musics/Moongazer.mp3", game:HttpGet("https://github.com/Nitro-GT/music/raw/refs/heads/main/Moongazer.mp3"))
end

tool6.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(80947480089411, 1, true)
        playSoundSafe(Music6, "Epik Musics/Moongazer.mp3")
    end
end)
tool6.Unequipped:Connect(function()
    stopSoundSafe(Music6)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool7 = IT("Tool", Backpack)
tool7.Name = "Insanity"
tool7.RequiresHandle = false
if not isfile("Epik Musics/Insanity.mp3") then
       writefile("Epik Musics/Insanity.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Insanity.mp3"))
end
local Insanity = R6Emotes:FindFirstChild("Pop Dance")

tool7.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        if Insanity then getgenv().Animator6D(Insanity, 1, true) end
        playSoundSafe(Music7, "Epik Musics/Insanity.mp3")
    end
end)
tool7.Unequipped:Connect(function()
    stopSoundSafe(Music7)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool8 = IT("Tool", Backpack)
tool8.Name = "Wait"
tool8.RequiresHandle = false
if not isfile("Epik Musics/Wait.mp3") then
       writefile("Epik Musics/Wait.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Wait.mp3"))
end
local WaitAnim = R6Emotes:FindFirstChild("Wait")

tool8.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        if WaitAnim then getgenv().Animator6D(WaitAnim, 1, true) end
        playSoundSafe(Music8, "Epik Musics/Wait.mp3")
    end
end)
tool8.Unequipped:Connect(function()
    stopSoundSafe(Music8)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool9 = IT("Tool", Backpack)
tool9.Name = "Goopie"
tool9.RequiresHandle = false
if not isfile("Epik Musics/Goopie.mp3") then
       writefile("Epik Musics/Goopie.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Goopie.mp3"))
end

tool9.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(13096880262, 1, true)
        playSoundSafe(Music9, "Epik Musics/Goopie.mp3")
    end
end)
tool9.Unequipped:Connect(function()
    stopSoundSafe(Music9)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool10 = IT("Tool", Backpack)
tool10.Name = "Fresh"
tool10.RequiresHandle = false
if not isfile("Epik Musics/Fresh.mp3") then
       writefile("Epik Musics/Fresh.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Fresh.mp3"))
end
local FreshDance = R6Emotes:FindFirstChild("Fresh")

tool10.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 5
        if FreshDance then getgenv().Animator6D(FreshDance, 1, true) end
        playSoundSafe(Music10, "Epik Musics/Fresh.mp3")
    end
end)
tool10.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music10)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool11 = IT("Tool", Backpack)
tool11.Name = "Chinese Dance"
tool11.RequiresHandle = false
if not isfile("Epik Musics/Chinese Dance.mp3") then
       writefile("Epik Musics/Chinese Dance.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Chinese%20Dance.mp3"))
end
local Chinese = R6Emotes:FindFirstChild("CatDance")

tool11.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 0
        if Chinese then getgenv().Animator6D(Chinese, 1, true) end
        playSoundSafe(Music11, "Epik Musics/Chinese Dance.mp3")
    end
end)
tool11.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music11)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool12 = IT("Tool", Backpack)
tool12.Name = "Mr.WMD Boombox"
tool12.RequiresHandle = false

local rightLeg = Character:FindFirstChild("Right Leg")
if rightLeg then
    local handle12 = IT("Part")
    handle12.Name = "Handle"
    handle12.Size = V3(0.01, 0.01, 0.01)
    handle12.CanCollide = false
    handle12.Anchored = false
    handle12.Parent = tool12

    local weld12 = IT("WeldConstraint")
    handle12.CFrame = rightLeg.CFrame * CF(0, -1, 0) * CFrame.Angles(0, RAD(90), 0)
    handle12.Parent = rightLeg
    weld12.Part0 = rightLeg
    weld12.Part1 = handle12
    weld12.Parent = handle12
end

if not isfile("Epik Musics/Wipe me Down.mp3") then
       writefile("Epik Musics/Wipe me Down.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Wipe%20me%20Down.mp3"))
end

tool12.Equipped:Connect(function()
    local handle12 = tool12:FindFirstChild("Handle")
    if Character and box.Parent == EffectFolder and handle12 then
        IsDancing = true
        theme:Stop()
        box.Parent = handle12
        Humanoid.WalkSpeed = 0
        getgenv().Animator6D(92629504992703, 1, true)
        playSoundSafe(Music12, "Epik Musics/Wipe me Down.mp3")
    end
end)
tool12.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music12)
    theme:Play()
    IsDancing = false
    getgenv().Animator6DStop()
    local handle12 = tool12:FindFirstChild("Handle")
    if handle12 and box.Parent == handle12 then
        box.Parent = EffectFolder
    end
end)

local tool13 = IT("Tool", Backpack)
tool13.Name = "Take The L"
tool13.RequiresHandle = false
if not isfile("Epik Musics/L Emote.mp3") then
       writefile("Epik Musics/L Emote.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/L%20Emote.mp3"))
end
local LEmote = R6Emotes:FindFirstChild("Take The L")

tool13.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 6.5
        if LEmote then getgenv().Animator6D(LEmote, 1, true) end
        playSoundSafe(Music13, "Epik Musics/L Emote.mp3")
    end
end)
tool13.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music13)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool14 = IT("Tool", Backpack)
tool14.Name = "It's a Secret"
tool14.RequiresHandle = false
if not isfile("Epik Musics/secret.mp3") then
       writefile("Epik Musics/secret.mp3", game:HttpGet("https://github.com/Nitro-GT/music/raw/refs/heads/main/secret.mp3"))
end
local Secret = R6Emotes:FindFirstChild("StockDance One")

tool14.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 4
        if Secret then getgenv().Animator6D(Secret, 1, true) end
        playSoundSafe(Music14, "Epik Musics/secret.mp3")
    end
end)
tool14.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music14)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool15 = IT("Tool", Backpack)
tool15.Name = "Caramelldansen"
tool15.RequiresHandle = false
if not isfile("Epik Musics/caramell.mp3") then
       writefile("Epik Musics/caramell.mp3", game:HttpGet("https://github.com/Nitro-GT/music/raw/refs/heads/main/caramell.mp3"))
end

tool15.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 2.5
        getgenv().Animator6D(114964447248296, 1, true)
        playSoundSafe(Music15, "Epik Musics/caramell.mp3")
    end
end)
tool15.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music15)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool16 = IT("Tool", Backpack)
tool16.Name = "Cha Cha"
tool16.RequiresHandle = true
if not isfile("Epik Musics/Cha Cha.mp3") then
       writefile("Epik Musics/Cha Cha.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Cha%20Cha.mp3"))
end
local ChaCha = R6Emotes:FindFirstChild("Silly")

local handle16 = IT("Part")
handle16.Name = "Handle"
handle16.Size = V3(1, 4, 1)
handle16.CanCollide = false
handle16.Anchored = false
handle16.Parent = tool16

local confObj = getAssetSafe(688963157)
local conf = confObj and confObj:FindFirstChildOfClass("ParticleEmitter")
if conf then
    conf = conf:Clone()
    conf.Parent = EffectFolder
    conf.Enabled = false
end

tool16.Equipped:Connect(function()
    if Character and Character.Parent and maraca.Parent == EffectFolder and conf and conf.Parent == EffectFolder then
        IsDancing = true
        theme:Stop()
		maraca.Parent = handle16
		conf.Parent = Head
		conf.Enabled = true
        Humanoid.WalkSpeed = 2.5
        if ChaCha then getgenv().Animator6D(ChaCha, 1, true) end
        playSoundSafe(Music16, "Epik Musics/Cha Cha.mp3")
    end
end)
tool16.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music16)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
    if maraca.Parent == handle16 then
       maraca.Parent = EffectFolder
    end
    if conf and conf:IsA("ParticleEmitter") then
       conf.Enabled = false
       conf.Parent = EffectFolder
    end
end)

local tool17 = IT("Tool", Backpack)
tool17.Name = "Boogie Down"
tool17.RequiresHandle = false
if not isfile("Epik Musics/boogie.mp3") then
       writefile("Epik Musics/boogie.mp3", game:HttpGet("https://github.com/Nitro-GT/music/raw/refs/heads/main/boogie.mp3"))
end

tool17.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 1.5
        getgenv().Animator6D(122471664395501, 1, true)
        playSoundSafe(Music17, "Epik Musics/boogie.mp3")
        Music17.PlaybackSpeed = 2
    end
end)
tool17.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music17)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool18 = IT("Tool", Backpack)
tool18.Name = "Mio Honda Step"
tool18.RequiresHandle = false
if not isfile("Epik Musics/Step.mp3") then
       writefile("Epik Musics/Step.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Step.mp3"))
end
local StepWalk = R6Emotes:FindFirstChild("Mio Honda Step")

tool18.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 1.8
        if StepWalk then getgenv().Animator6D(StepWalk, 1, true) end
        playSoundSafe(Music18, "Epik Musics/Step.mp3")
    end
end)
tool18.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music18)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool19 = IT("Tool", Backpack)
tool19.Name = "Fright Funk"
tool19.RequiresHandle = false
if not isfile("Epik Musics/frightfunk.mp3") then
       writefile("Epik Musics/frightfunk.mp3", game:HttpGet("https://github.com/Nitro-GT/music/raw/refs/heads/main/frightfunk.mp3"))
end

tool19.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 10
        getgenv().Animator6D(82437456855605, 1, true)
        playSoundSafe(Music19, "Epik Musics/frightfunk.mp3")
    end
end)
tool19.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music19)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool20 = IT("Tool", Backpack)
tool20.Name = "Shigure"
tool20.RequiresHandle = false
if not isfile("Epik Musics/Loli Dance.mp3") then
       writefile("Epik Musics/Loli Dance.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Loli%20Dance.mp3"))
end

tool20.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 1.8
        getgenv().Animator6D(106801620167778, 1.25, true)
        playSoundSafe(Music20, "Epik Musics/Loli Dance.mp3")
    end
end)
tool20.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music20)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool21 = IT("Tool", Backpack)
tool21.Name = "Rakuten"
tool21.RequiresHandle = false
if not isfile("Epik Musics/Rakuten Lemonade.mp3") then
       writefile("Epik Musics/Rakuten Lemonade.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Rakuten%20Lemonade.mp3"))
end

tool21.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 1.8
        getgenv().Animator6D(121967347012647, 1, true)
        playSoundSafe(Music21, "Epik Musics/Rakuten Lemonade.mp3")
    end
end)
tool21.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music21)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool22 = IT("Tool", Backpack)
tool22.Name = "Hakari"
tool22.RequiresHandle = false
if not isfile("Epik Musics/Hakari.mp3") then
       writefile("Epik Musics/Hakari.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Hakari.mp3"))
end

local CachedEffects22 = {}
tool22.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(17147170140, 1, true)
        local HakariAura = getAssetSafe(17286931410)
        if HakariAura then
            for _, limb in ipairs(Character:GetChildren()) do
            	if limb:IsA("BasePart") then
                    for _, obj in ipairs(HakariAura:GetDescendants()) do
                    	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    		local Aura = obj:Clone()
                    		Aura.Parent = limb
                    		table.insert(CachedEffects22, Aura)
            		    end
            		end
            	end
            end
            HakariAura:Destroy()
        end
        playSoundSafe(Music22, "Epik Musics/Hakari.mp3")
    end
end)
tool22.Unequipped:Connect(function()
    stopSoundSafe(Music22)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
    for _, Aura in pairs(CachedEffects22) do
           Aura:Destroy()
		end
    table.clear(CachedEffects22)
end)

local tool23 = IT("Tool", Backpack)
tool23.Name = "Shuba Duck"
tool23.RequiresHandle = false
if not isfile("Epik Musics/Hey Ya.mp3") then
       writefile("Epik Musics/Hey Ya.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Hey%20Ya.mp3"))
end

tool23.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(77920672554221, 1, true)
        playSoundSafe(Music23, "Epik Musics/Hey Ya.mp3")
    end
end)
tool23.Unequipped:Connect(function()
    stopSoundSafe(Music23)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool24 = IT("Tool", Backpack)
tool24.Name = "Lemon Melon Cookie"
tool24.RequiresHandle = false
if not isfile("Epik Musics/LMC.mp3") then
       writefile("Epik Musics/LMC.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/LMC.mp3"))
end

tool24.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        getgenv().Animator6D(138510336377177, 1, true)
        playSoundSafe(Music24, "Epik Musics/LMC.mp3")
    end
end)
tool24.Unequipped:Connect(function()
    stopSoundSafe(Music24)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool25 = IT("Tool", Backpack)
tool25.Name = "Doodle"
tool25.RequiresHandle = false
if not isfile("Epik Musics/Doodle.mp3") then
       writefile("Epik Musics/Doodle.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Doodle.mp3"))
end

tool25.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 0
        Humanoid.JumpPower = 0
        getgenv().Animator6D(137217645571244, 1, true)
        playSoundSafe(Music25, "Epik Musics/Doodle.mp3")
    end
end)
tool25.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    Humanoid.JumpPower = 50
    stopSoundSafe(Music25)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool26 = IT("Tool", Backpack)
tool26.Name = "Smug"
tool26.RequiresHandle = false
if not isfile("Epik Musics/Dancing.mp3") then
       writefile("Epik Musics/Dancing.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Dancing.mp3"))
end

tool26.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 10
        getgenv().Animator6D(6512463532, 1, true)
        playSoundSafe(Music26, "Epik Musics/Dancing.mp3")
    end
end)
tool26.Unequipped:Connect(function()
    stopSoundSafe(Music26)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
    Humanoid.WalkSpeed = 16
end)

local tool27 = IT("Tool", Backpack)
tool27.Name = "The Cat"
tool27.RequiresHandle = false
if not isfile("Epik Musics/All my Fellas.mp3") then
       writefile("Epik Musics/All my Fellas.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/All%20my%20Fellas.mp3"))
end

tool27.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        Humanoid.WalkSpeed = 10
        getgenv().Animator6D(13326236708, 1, true)
        playSoundSafe(Music27, "Epik Musics/All my Fellas.mp3")
    end
end)
tool27.Unequipped:Connect(function()
    stopSoundSafe(Music27)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
    Humanoid.WalkSpeed = 16
end)

local tool28 = IT("Tool", Backpack)
tool28.Name = "Pog Dance"
tool28.RequiresHandle = false
if not isfile("Epik Musics/Sun FNAF.mp3") then
       writefile("Epik Musics/Sun FNAF.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Sun%20FNAF.mp3"))
end
local Pogger = R6Emotes:FindFirstChild("Pog Dance")

tool28.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        if Pogger then getgenv().Animator6D(Pogger, 1, true) end
        playSoundSafe(Music28, "Epik Musics/Sun FNAF.mp3")
    end
end)
tool28.Unequipped:Connect(function()
    stopSoundSafe(Music28)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool29 = IT("Tool", Backpack)
tool29.Name = "Summer"
tool29.RequiresHandle = false
if not isfile("Epik Musics/Summer.mp3") then
       writefile("Epik Musics/Summer.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/Summer.mp3"))
end
local Summer = R6Emotes:FindFirstChild("Summer")

tool29.Equipped:Connect(function()
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        if Summer then getgenv().Animator6D(Summer, 1, true) end
        playSoundSafe(Music29, "Epik Musics/Summer.mp3")
    end
end)
tool29.Unequipped:Connect(function()
    stopSoundSafe(Music29)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
end)

local tool30 = IT("Tool", Backpack)
tool30.Name = "Locked"
tool30.RequiresHandle = false
if not isfile("Epik Musics/My Ordinary Life.mp3") then
       writefile("Epik Musics/My Ordinary Life.mp3", game:HttpGet("https://github.com/gObl00x/Epik-Musics/raw/refs/heads/main/My%20Ordinary%20Life.mp3"))
end
local Locked = R6Emotes:FindFirstChild("Locked")

local CachedEffects30 = {}
tool30.Equipped:Connect(function()
    Humanoid.WalkSpeed = 0
    if Character and Character.Parent then
        IsDancing = true
        theme:Stop()
        if Locked then getgenv().Animator6D(Locked, 1, true) end
        local RinAura = getAssetSafe(126096744823510)
        if RinAura then
            for _, limb in ipairs(Character:GetChildren()) do
            	if limb:IsA("BasePart") then
                    for _, obj in ipairs(RinAura:GetDescendants()) do
                    	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    		local Aura = obj:Clone()
                    		Aura.Parent = limb
                    		table.insert(CachedEffects30, Aura)
            		    end
            		end
            	end
            end
            RinAura:Destroy()
        end
        playSoundSafe(Music30, "Epik Musics/My Ordinary Life.mp3")
    end
end)
tool30.Unequipped:Connect(function()
    Humanoid.WalkSpeed = 16
    stopSoundSafe(Music30)
    IsDancing = false
    getgenv().Animator6DStop()
    theme:Play()
    for _, Aura in pairs(CachedEffects30) do
           Aura:Destroy()
		end
    table.clear(CachedEffects30)
end)