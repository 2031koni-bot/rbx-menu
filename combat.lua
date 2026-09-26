-- COMBAT v4
local CM = _G.CM
if not CM then warn("[CM] core not loaded"); return end
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local P = CM.P
local cam = CM.cam
local page = CM.pages["Combat"]

-- ========== STATE ==========
local aimbotOn = false
local aimbotFOV = 400
local aimbotSmooth = 0
local aimbotPredict = 0
local aimbotPriority = "Crosshair"
local aimbotPart = "Head"
local aimbotLock = 0.15
local aimbotVisible = true
local aimbotLockTarget = nil
local aimbotLockEnd = 0
local aimbotAutoShoot = false
local aimbotAutoShootRate = 0.05
local aimbotTeamCheck = true
local aimbotKey = Enum.KeyCode.Unknown
local aimbotKeyHeld = true
local aimbotFovColor = Color3.fromRGB(0, 170, 255)
local aimbotFovThickness = 1.5
local aimbotFovTransp = 0.35

local triggerOn = false
local triggerFOV = 8
local triggerDelay = 0.02
local lastTrigger = 0

local antiAimOn = false
local antiAimMode = 1
local antiAimAngle = 89

local autoFireOn = false
local autoFireRate = 0.08
local autoFireFOV = 500
local lastFire = 0

local quickStopOn = false
local hitmarkerOn = false

-- ========== AUTO ROTATE ==========
local function updateAutoRotate()
    local h = CM.hum()
    if not h then return end
    if aimbotOn or antiAimOn or autoFireOn then
        h.AutoRotate = false
    else
        h.AutoRotate = true
    end
end

P.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateAutoRotate()
end)

-- ========== CHECKS ==========
local function isVisible(part)
    if not aimbotVisible then return true end
    local origin = cam.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {P.Character, part.Parent}
    local res = workspace:Raycast(origin, dir, params)
    return res == nil or res.Instance:IsDescendantOf(part.Parent)
end

local function isTeammate(plr)
    if not aimbotTeamCheck then return false end
    if not plr.Team or not P.Team then return false end
    return plr.Team == P.Team
end

-- ========== SCORING ==========
local function scoreTarget(plr, part)
    local h = plr.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    if isTeammate(plr) then return nil end

    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
    local toT = (part.Position - cam.CFrame.Position).Unit
    if not onScreen or toT:Dot(cam.CFrame.LookVector) <= 0 then return nil end
    if not isVisible(part) then return nil end

    local center = cam.ViewportSize / 2
    local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
    if screenDist > aimbotFOV then return nil end

    if aimbotPriority == "Crosshair" then
        return screenDist
    elseif aimbotPriority == "Distance" then
        local myPos = CM.hrp() and CM.hrp().Position or cam.CFrame.Position
        return (part.Position - myPos).Magnitude
    elseif aimbotPriority == "Health" then
        return h.Health
    elseif aimbotPriority == "FOV+" then
        local myPos = CM.hrp() and CM.hrp().Position or cam.CFrame.Position
        return screenDist + (part.Position - myPos).Magnitude * 0.01
    end
    return screenDist
end

local function getTarget(fov, prio, partName)
    local best, bestScore = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= P and plr.Character then
            local part = plr.Character:FindFirstChild(partName or "Head")
            if not part then part = plr.Character:FindFirstChild("Head") end
            if part then
                local s = scoreTarget(plr, part)
                if s and s < bestScore then
                    bestScore = s
                    best = part
                end
            end
        end
    end
    return best
end

-- ========== ROTATION ==========
local function safeLookCF(pos, dir)
    if dir.Magnitude < 0.05 then return nil end
    local unit = dir.Unit
    if math.abs(unit.Y) > 0.999 then
        unit = Vector3.new(0.001, unit.Y, 0.001).Unit
    end
    return CFrame.lookAt(pos, pos + unit)
end

local function faceTo(hrp, targetPos, smooth)
    local dir = targetPos - hrp.Position
    local flat = Vector3.new(dir.X, 0, dir.Z)
    if flat.Magnitude < 0.05 then return end
    local targetCF = safeLookCF(hrp.Position, flat.Unit)
    if not targetCF then return end
    if smooth and smooth > 0 then
        local lerped = hrp.CFrame:Lerp(targetCF, 1 / (smooth + 1))
        hrp.CFrame = CFrame.new(hrp.Position) * (lerped - lerped.Position)
    else
        hrp.CFrame = CFrame.new(hrp.Position) * (targetCF - targetCF.Position)
    end
end

-- ========== FOV CIRCLE ==========
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "CM_FOV"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 2147483646
fovGui.Parent = CM.PG

local fovFrame = Instance.new("Frame", fovGui)
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
local fovCorner = Instance.new("UICorner", fovFrame)
fovCorner.CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovFrame)
fovStroke.Color = CM.AC
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.35

RS.RenderStepped:Connect(function()
    if aimbotOn then
        fovFrame.Visible = true
        fovFrame.Size = UDim2.new(0, aimbotFOV * 2, 0, aimbotFOV * 2)
        fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        fovStroke.Color = aimbotFovColor
        fovStroke.Thickness = aimbotFovThickness
        fovStroke.Transparency = aimbotFovTransp
    else
        fovFrame.Visible = false
    end
end)

-- ========== AIMBOT ==========
local fAimbot = CM.feature(page, "aimbot", false, function(v)
    aimbotOn = v
    updateAutoRotate()
end)

-- Priority row
local prioRow = Instance.new("Frame", fAimbot.settings)
prioRow.Size = UDim2.new(1, 0, 0, 32)
prioRow.BackgroundColor3 = CM.BG2
prioRow.BackgroundTransparency = CM.bgT
prioRow.BorderSizePixel = 0
local prc = Instance.new("UICorner", prioRow); prc.CornerRadius = UDim.new(0, 6)
local prLabel = Instance.new("TextLabel", prioRow)
prLabel.Size = UDim2.new(0.35, 0, 1, 0)
prLabel.Position = UDim2.new(0, 12, 0, 0)
prLabel.BackgroundTransparency = 1
prLabel.TextColor3 = CM.TXT
prLabel.Font = Enum.Font.Gotham
prLabel.TextSize = 11
prLabel.TextXAlignment = Enum.TextXAlignment.Left
prLabel.Text = "Priority"

local prBox = Instance.new("Frame", prioRow)
prBox.Size = UDim2.new(0, 260, 1, -6)
prBox.Position = UDim2.new(1, -268, 0, 3)
prBox.BackgroundTransparency = 1
local prLay = Instance.new("UIListLayout", prBox)
prLay.FillDirection = Enum.FillDirection.Horizontal
prLay.Padding = UDim.new(0, 3)

local prioBtn = {}
for _, name in ipairs({"Crosshair", "Distance", "Health", "FOV+"}) do
    local b = Instance.new("TextButton", prBox)
    b.Size = UDim2.new(0, 62, 1, 0)
    b.BackgroundColor3 = CM.BG3
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = CM.TXT
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 9
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0, 4)
    prioBtn[name] = b
    b.MouseButton1Click:Connect(function()
        aimbotPriority = name
        for n, bb in pairs(prioBtn) do
            bb.BackgroundColor3 = (n == name) and CM.AC or CM.BG3
        end
    end)
end
prioBtn["Crosshair"].BackgroundColor3 = CM.AC

-- Hitbox row
local hbRow = Instance.new("Frame", fAimbot.settings)
hbRow.Size = UDim2.new(1, 0, 0, 32)
hbRow.BackgroundColor3 = CM.BG2
hbRow.BackgroundTransparency = CM.bgT
hbRow.BorderSizePixel = 0
local hbc = Instance.new("UICorner", hbRow); hbc.CornerRadius = UDim.new(0, 6)
local hbLabel = Instance.new("TextLabel", hbRow)
hbLabel.Size = UDim2.new(0.35, 0, 1, 0)
hbLabel.Position = UDim2.new(0, 12, 0, 0)
hbLabel.BackgroundTransparency = 1
hbLabel.TextColor3 = CM.TXT
hbLabel.Font = Enum.Font.Gotham
hbLabel.TextSize = 11
hbLabel.TextXAlignment = Enum.TextXAlignment.Left
hbLabel.Text = "Hitbox"

local hbBox = Instance.new("Frame", hbRow)
hbBox.Size = UDim2.new(0, 260, 1, -6)
hbBox.Position = UDim2.new(1, -268, 0, 3)
hbBox.BackgroundTransparency = 1
local hbLay = Instance.new("UIListLayout", hbBox)
hbLay.FillDirection = Enum.FillDirection.Horizontal
hbLay.Padding = UDim.new(0, 3)
local hbBtn = {}
for _, name in ipairs({"Head", "UpperTorso", "Torso", "Nearest"}) do
    local b = Instance.new("TextButton", hbBox)
    b.Size = UDim2.new(0, 62, 1, 0)
    b.BackgroundColor3 = CM.BG3
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = CM.TXT
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 9
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0, 4)
    hbBtn[name] = b
    b.MouseButton1Click:Connect(function()
        aimbotPart = name
        for n, bb in pairs(hbBtn) do
            bb.BackgroundColor3 = (n == name) and CM.AC or CM.BG3
        end
    end)
end
hbBtn["Head"].BackgroundColor3 = CM.AC

CM.slider(fAimbot.settings, "fov", 10, 1000, 400, function(v) aimbotFOV = v end)
CM.slider(fAimbot.settings, "smooth", 0, 20, 0, function(v) aimbotSmooth = v end)
CM.slider(fAimbot.settings, "predict", 0, 10, 0, function(v) aimbotPredict = v / 10 end)
CM.slider(fAimbot.settings, "lock", 0, 50, 15, function(v) aimbotLock = v / 100 end)
CM.toggle(fAimbot.settings, "wallcheck", true, function(v) aimbotVisible = v end)
CM.toggle(fAimbot.settings, "teamcheck", true, function(v) aimbotTeamCheck = v end)
CM.cfgs["aimbot"] = {set=function(v) fAimbot.setState(v) end, get=function() return fAimbot.getState() end}
CM.cfgs["aimwall"] = {set=function(v) aimbotVisible = v end, get=function() return aimbotVisible end}
CM.cfgs["aimteam"] = {set=function(v) aimbotTeamCheck = v end, get=function() return aimbotTeamCheck end}

-- Aim Key row
local akRow = Instance.new("Frame", fAimbot.settings)
akRow.Size = UDim2.new(1, 0, 0, 32)
akRow.BackgroundColor3 = CM.BG2
akRow.BackgroundTransparency = CM.bgT
akRow.BorderSizePixel = 0
local akc = Instance.new("UICorner", akRow); akc.CornerRadius = UDim.new(0, 6)
local akLabel = Instance.new("TextLabel", akRow)
akLabel.Size = UDim2.new(1, -120, 1, 0)
akLabel.Position = UDim2.new(0, 12, 0, 0)
akLabel.BackgroundTransparency = 1
akLabel.TextColor3 = CM.TXT
akLabel.Font = Enum.Font.Gotham
akLabel.TextSize = 12
akLabel.TextXAlignment = Enum.TextXAlignment.Left
akLabel.Text = "Aim Key (hold)"

local akBtn = Instance.new("TextButton", akRow)
akBtn.Size = UDim2.new(0, 100, 0, 24)
akBtn.Position = UDim2.new(1, -112, 0.5, -12)
akBtn.BackgroundColor3 = CM.BG3
akBtn.BorderSizePixel = 0
akBtn.Text = "None"
akBtn.TextColor3 = CM.TXT
akBtn.Font = Enum.Font.GothamMedium
akBtn.TextSize = 11
local akbc = Instance.new("UICorner", akBtn); akbc.CornerRadius = UDim.new(0, 5)
akBtn.MouseButton1Click:Connect(function()
    akBtn.Text = "Press key..."
    akBtn.BackgroundColor3 = Color3.fromRGB(230, 180, 50)
    local conn
    conn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            aimbotKey = input.KeyCode
            akBtn.Text = input.KeyCode.Name
            akBtn.BackgroundColor3 = CM.BG3
            conn:Disconnect()
        end
    end)
    task.delay(5, function()
        if conn then conn:Disconnect()
            if akBtn.Text == "Press key..." then
                akBtn.Text = aimbotKey == Enum.KeyCode.Unknown and "None" or aimbotKey.Name
                akBtn.BackgroundColor3 = CM.BG3
            end
        end
    end)
end)

-- FOV Circle customization
CM.colorRow(fAimbot.settings, "fovcolor", aimbotFovColor, function(c) aimbotFovColor = c end)
CM.slider(fAimbot.settings, "fovthick", 1, 8, 2, function(v) aimbotFovThickness = v end)
CM.slider(fAimbot.settings, "fovtransp", 0, 100, 35, function(v) aimbotFovTransp = v / 100 end)

-- Aim Key state
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == aimbotKey and aimbotKey ~= Enum.KeyCode.Unknown then
        aimbotKeyHeld = true
    end
end)
UIS.InputEnded:Connect(function(input, gp)
    if input.KeyCode == aimbotKey and aimbotKey ~= Enum.KeyCode.Unknown then
        aimbotKeyHeld = false
    end
end)

-- Aimbot loop with key check
RS.RenderStepped:Connect(function()
    if not aimbotOn then aimbotLockTarget = nil; return end
    if aimbotKey ~= Enum.KeyCode.Unknown and not aimbotKeyHeld then return end

    local hrp = CM.hrp()
    if not hrp then return end

    local now = os.clock()
    if aimbotLockTarget and (now > aimbotLockEnd or not aimbotLockTarget.Parent) then
        aimbotLockTarget = nil
    end

    local target
    if aimbotLockTarget and aimbotLockTarget.Parent then
        target = aimbotLockTarget
    else
        target = getTarget(aimbotFOV, aimbotPriority, aimbotPart)
        if target then
            aimbotLockTarget = target
            aimbotLockEnd = now + aimbotLock
        end
    end

    if not target then return end

    local pos = target.Position
    if aimbotPredict > 0 then
        pos = pos + (target.AssemblyLinearVelocity or Vector3.zero) * aimbotPredict
    end

    faceTo(hrp, pos, aimbotSmooth)
end)

-- ========== AUTO-SHOOT ==========
local fAAS = CM.feature(page, "auto shoot", false, function(v) aimbotAutoShoot = v end)
CM.slider(fAAS.settings, "rate", 10, 500, 50, function(v) aimbotAutoShootRate = v / 1000 end)
CM.cfgs["autoshoot"] = {set=function(v) fAAS.setState(v) end, get=function() return fAAS.getState() end}

RS.Heartbeat:Connect(function()
    if not aimbotOn or not aimbotAutoShoot then return end
    if not aimbotLockTarget or not aimbotLockTarget.Parent then return end
    if os.clock() - lastFire < aimbotAutoShootRate then return end
    local c = P.Character
    if c then
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
            lastFire = os.clock()
        end
    end
end)

-- ========== TRIGGER BOT ==========
local fTrigger = CM.feature(page, "trigger bot", false, function(v) triggerOn = v end)
CM.slider(fTrigger.settings, "delay", 0, 50, 2, function(v) triggerDelay = v / 100 end)
CM.cfgs["triggerbot"] = {set=function(v) fTrigger.setState(v) end, get=function() return fTrigger.getState() end}

RS.Heartbeat:Connect(function()
    if not triggerOn then return end
    if os.clock() - lastTrigger < triggerDelay then return end

    local mouse = UIS:GetMouseLocation()
    local ray = cam:ViewportPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {P.Character}
    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)

    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local plr = Players:GetPlayerFromCharacter(model)
            if plr and plr ~= P and not isTeammate(plr) then
                local h = model:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    local c = P.Character
                    if c then
                        local tool = c:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function() tool:Activate() end)
                            lastTrigger = os.clock()
                        end
                    end
                end
            end
        end
    end
end)

-- ========== AUTOFIRE ==========
local fAF = CM.feature(page, "autofire", false, function(v)
    autoFireOn = v
    updateAutoRotate()
end)
CM.slider(fAF.settings, "rate", 20, 500, 80, function(v) autoFireRate = v / 1000 end)
CM.slider(fAF.settings, "fov", 50, 800, 500, function(v) autoFireFOV = v end)
CM.cfgs["autofire"] = {set=function(v) fAF.setState(v) end, get=function() return fAF.getState() end}

RS.Heartbeat:Connect(function()
    if not autoFireOn then return end
    if os.clock() - lastFire < autoFireRate then return end

    local target = getTarget(autoFireFOV, "Crosshair", aimbotPart)
    if not target then return end

    if not aimbotOn and not antiAimOn then
        local hrp = CM.hrp()
        if hrp then faceTo(hrp, target.Position, 0) end
    end

    local c = P.Character
    if c then
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
            lastFire = os.clock()
        end
    end
end)

-- ========== ANTI-AIM ==========
local fAA = CM.feature(page, "anti-aim", false, function(v)
    antiAimOn = v
    updateAutoRotate()
end)

local aaRow = Instance.new("Frame", fAA.settings)
aaRow.Size = UDim2.new(1, 0, 0, 32)
aaRow.BackgroundColor3 = CM.BG2
aaRow.BackgroundTransparency = CM.bgT
aaRow.BorderSizePixel = 0
local aac = Instance.new("UICorner", aaRow); aac.CornerRadius = UDim.new(0, 6)
local aaLabel = Instance.new("TextLabel", aaRow)
aaLabel.Size = UDim2.new(0.35, 0, 1, 0)
aaLabel.Position = UDim2.new(0, 12, 0, 0)
aaLabel.BackgroundTransparency = 1
aaLabel.TextColor3 = CM.TXT
aaLabel.Font = Enum.Font.Gotham
aaLabel.TextSize = 11
aaLabel.TextXAlignment = Enum.TextXAlignment.Left
aaLabel.Text = "Mode"

local aaBox = Instance.new("Frame", aaRow)
aaBox.Size = UDim2.new(0, 260, 1, -6)
aaBox.Position = UDim2.new(1, -268, 0, 3)
aaBox.BackgroundTransparency = 1
local aaLay = Instance.new("UIListLayout", aaBox)
aaLay.FillDirection = Enum.FillDirection.Horizontal
aaLay.Padding = UDim.new(0, 3)

local aaBtn = {}
for i, name in ipairs({"Down", "Back", "Jitter", "Spin", "Random"}) do
    local b = Instance.new("TextButton", aaBox)
    b.Size = UDim2.new(0, 50, 1, 0)
    b.BackgroundColor3 = CM.BG3
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = CM.TXT
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 9
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0, 4)
    aaBtn[i] = b
    b.MouseButton1Click:Connect(function()
        antiAimMode = i
        for n, bb in pairs(aaBtn) do
            bb.BackgroundColor3 = (n == i) and CM.AC or CM.BG3
        end
    end)
end
aaBtn[1].BackgroundColor3 = CM.AC

CM.slider(fAA.settings, "angle", 30, 89, 89, function(v) antiAimAngle = v end)
CM.cfgs["antiaim"] = {set=function(v) fAA.setState(v) end, get=function() return fAA.getState() end}

local aaPhase = 0
local aaRandomAngle = 0
local aaRandomTime = 0

RS.RenderStepped:Connect(function(dt)
    if not antiAimOn or aimbotOn or autoFireOn then return end
    local hrp = CM.hrp()
    if not hrp then return end

    local look = cam.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 0.05 then return end
    flat = flat.Unit

    local pitchRad = math.rad(antiAimAngle)
    local cosP = math.cos(pitchRad)
    local sinP = math.sin(pitchRad)
    local newDir

    if antiAimMode == 1 then
        newDir = Vector3.new(flat.X * cosP, -sinP, flat.Z * cosP).Unit
    elseif antiAimMode == 2 then
        newDir = Vector3.new(-flat.X * cosP, -sinP, -flat.Z * cosP).Unit
    elseif antiAimMode == 3 then
        aaPhase = aaPhase + dt * 12
        local jit = math.sin(aaPhase) * math.rad(50)
        local baseYaw = math.atan2(-flat.Z, flat.X) + jit
        local fwd = Vector3.new(math.cos(baseYaw), 0, -math.sin(baseYaw))
        newDir = Vector3.new(fwd.X * cosP, -sinP, fwd.Z * cosP).Unit
    elseif antiAimMode == 4 then
        aaPhase = aaPhase + dt * 14
        local fwd = Vector3.new(math.cos(aaPhase), 0, math.sin(aaPhase))
        newDir = Vector3.new(fwd.X * cosP, -sinP, fwd.Z * cosP).Unit
    else
        if os.clock() - aaRandomTime > 0.15 then
            aaRandomTime = os.clock()
            aaRandomAngle = math.random() * math.pi * 2
        end
        local fwd = Vector3.new(math.cos(aaRandomAngle), 0, math.sin(aaRandomAngle))
        newDir = Vector3.new(fwd.X * cosP, -sinP, fwd.Z * cosP).Unit
    end

    local cf = safeLookCF(hrp.Position, newDir)
    if cf then
        hrp.CFrame = CFrame.new(hrp.Position) * (cf - cf.Position)
    end
end)

-- ========== QUICK STOP ==========
local fQS = CM.feature(page, "quick stop", false, function(v) quickStopOn = v end)
CM.cfgs["quickstop"] = {set=function(v) fQS.setState(v) end, get=function() return fQS.getState() end}

local quickStopSaved = nil
RS.Heartbeat:Connect(function()
    if not quickStopOn then
        if quickStopSaved then
            local h = CM.hum()
            if h then h.WalkSpeed = quickStopSaved end
            quickStopSaved = nil
        end
        return
    end
    local h = CM.hum()
    if not h then return end
    if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        if not quickStopSaved then
            quickStopSaved = h.WalkSpeed
        end
        h.WalkSpeed = 0
    else
        if quickStopSaved then
            h.WalkSpeed = quickStopSaved
            quickStopSaved = nil
        end
    end
end)

-- ========== HITMARKER ==========
local fHM = CM.feature(page, "hitmarker", false, function(v) hitmarkerOn = v end)
CM.cfgs["hitmarker"] = {set=function(v) fHM.setState(v) end, get=function() return fHM.getState() end}

local function makeHitmarker(isKill)
    local hm = Instance.new("Frame", CM.gui)
    hm.Size = UDim2.new(0, 26, 0, 26)
    hm.Position = UDim2.new(0.5, -13, 0.5, -13)
    hm.BackgroundTransparency = 1
    hm.ZIndex = 100
    local col = isKill and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 255, 255)
    for _, rot in ipairs({45, -45, 135, -135}) do
        local line = Instance.new("Frame", hm)
        line.Size = UDim2.new(1, 0, 0, 2)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.BackgroundColor3 = col
        line.BorderSizePixel = 0
        line.Rotation = rot
        line.ZIndex = 100
    end
    task.delay(0.35, function() hm:Destroy() end)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not hitmarkerOn then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

    local mouse = UIS:GetMouseLocation()
    local ray = cam:ViewportPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {P.Character}
    local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)

    if res and res.Instance then
        local model = res.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local plr = Players:GetPlayerFromCharacter(model)
            if plr and plr ~= P then
                local h = model:FindFirstChildOfClass("Humanoid")
                makeHitmarker(h and h.Health <= 0)
            end
        end
    end
end)

-- ========== BINDS ==========
CM.addBind("Aimbot", fAimbot)
CM.addBind("Auto Shoot", fAAS)
CM.addBind("Trigger Bot", fTrigger)
CM.addBind("AutoFire", fAF)
CM.addBind("Anti-Aim", fAA)
CM.addBind("Quick Stop", fQS)

print("[CM] combat v4 loaded")
