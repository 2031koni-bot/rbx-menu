-- VISUALS
local CM = _G.CM
if not CM then warn("[CM] core not loaded"); return end
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LT = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local P = CM.P
local cam = CM.cam

local page = CM.pages["Visuals"]

-- FOV
local fov = 70
local fFOV = CM.feature(page, "fov", false, function(v)
    if v then cam.FieldOfView = fov else cam.FieldOfView = 70; fov = 70 end
end)
local sFOV = CM.slider(fFOV.settings, "fov", 70, 120, 70, function(v)
    fov = v; if fFOV.getState() then cam.FieldOfView = fov end
end)
CM.btn(fFOV.settings, "reset_fov", function()
    sFOV.setValue(70); if fFOV.getState() then cam.FieldOfView = fov end
end)
CM.cfgs["fov"] = {set=function(v) sFOV.setValue(v) end, get=function() return sFOV.getValue() end}
CM.cfgs["fov_on"] = {set=function(v) fFOV.setState(v) end, get=function() return fFOV.getState() end}

-- Fullbright
local fFB = CM.feature(page, "fullbright", false, function(v)
    if v then
        LT.Brightness = 3; LT.ClockTime = 12
        LT.FogEnd = 100000; LT.GlobalShadows = false
    else
        LT.Brightness = 1; LT.FogEnd = 100000; LT.GlobalShadows = true
    end
end)
CM.cfgs["fullbright"] = {set=function(v) fFB.setState(v) end, get=function() return fFB.getState() end}

-- ESP
local espFill = Color3.fromRGB(0,170,255)
local espOut = Color3.fromRGB(255,255,255)
local espFT = 0.4
local espOn, espTeam = false, true
local espHL = {}

local function clearESP(p)
    if espHL[p] then espHL[p]:Destroy(); espHL[p] = nil end
end
local function makeESP(p)
    if not espOn or p == P then return end
    if espTeam and p.Team and P.Team and p.Team == P.Team then clearESP(p); return end
    local c = p.Character; if not c then return end
    clearESP(p)
    local hl = Instance.new("Highlight")
    hl.FillColor = espFill; hl.OutlineColor = espOut
    hl.FillTransparency = espFT; hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = c; hl.Parent = c
    espHL[p] = hl
end
local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= P then
            if espOn then makeESP(p) else clearESP(p) end
        end
    end
end

local fESP = CM.feature(page, "esp", false, function(v) espOn = v; refreshESP() end)
CM.colorRow(fESP.settings, "color", espFill, function(c) espFill = c; refreshESP() end)
CM.colorRow(fESP.settings, "color", espOut, function(c) espOut = c; refreshESP() end)
CM.slider(fESP.settings, "espft", 0, 100, 40, function(v) espFT = v/100; refreshESP() end)
CM.cfgs["esp"] = {set=function(v) fESP.setState(v) end, get=function() return fESP.getState() end}

local function onPlr(p)
    if p == P then return end
    p.CharacterAdded:Connect(function()
        task.wait(0.5); if espOn then makeESP(p) end
    end)
    if espOn and p.Character then makeESP(p) end
end
for _, p in ipairs(Players:GetPlayers()) do onPlr(p) end
Players.PlayerAdded:Connect(onPlr)
Players.PlayerRemoving:Connect(clearESP)

-- FreeLook
local flYaw, flPitch = 0, 0
local mDelta = Vector2.new(0,0)
local flDist = 6
local flConn
local freelook = false

local function startFL()
    local lk = cam.CFrame.LookVector
    flYaw = math.deg(math.atan2(-lk.X, -lk.Z))
    flPitch = math.deg(math.asin(math.clamp(lk.Y, -1, 1)))
    if flConn then flConn:Disconnect() end
    flConn = RS.RenderStepped:Connect(function()
        if not freelook then return end
        if not CM.frame.Visible then
            flYaw = flYaw - mDelta.X*0.45
            flPitch = math.clamp(flPitch - mDelta.Y*0.45, -85, 85)
        end
        mDelta = Vector2.new(0,0)
        local c = P.Character
        local hd = c and c:FindFirstChild("Head")
        if hd then
            local lkCF = CFrame.Angles(0, math.rad(flYaw), 0) * CFrame.Angles(math.rad(flPitch), 0, 0)
            local cp = hd.Position - lkCF.LookVector * flDist
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.new(cp) * lkCF
        end
    end)
end
local function stopFL()
    if flConn then flConn:Disconnect(); flConn = nil end
    cam.CameraType = Enum.CameraType.Custom
end
UIS.InputChanged:Connect(function(i)
    if freelook and not CM.frame.Visible and i.UserInputType == Enum.UserInputType.MouseMovement then
        mDelta = Vector2.new(i.Delta.X, i.Delta.Y)
    end
end)

local fFL = CM.feature(page, "freelook", false, function(v)
    freelook = v
    if v then startFL() else stopFL() end
end)
CM.slider(fFL.settings, "radius", 0, 20, 6, function(v) flDist = v end)
CM.cfgs["freelook"] = {set=function(v) fFL.setState(v) end, get=function() return fFL.getState() end}

-- Halo
local haloOn = false
local haloCol = Color3.fromRGB(255,255,255)
local haloModel, haloConn, haloParts = nil, nil, {}
local function removeHalo()
    if haloConn then haloConn:Disconnect(); haloConn = nil end
    if haloModel then haloModel:Destroy(); haloModel = nil end
    haloParts = {}
end
local function createHalo()
    removeHalo()
    local c = P.Character
    local hd = c and c:FindFirstChild("Head"); if not hd then return end
    haloModel = Instance.new("Model", workspace); haloModel.Name = "Halo"
    for i = 1, 18 do
        local ang = (i/18) * math.pi * 2
        local seg = Instance.new("Part")
        seg.Size = Vector3.new(0.3,0.3,0.3); seg.Shape = Enum.PartType.Ball
        seg.Material = Enum.Material.Neon; seg.Color = haloCol
        seg.Anchored = true
        seg.CanCollide = false; seg.CanQuery = false; seg.CanTouch = false
        seg.CastShadow = false; seg.Massless = true
        seg.Parent = haloModel
        local lt = Instance.new("PointLight", seg)
        lt.Brightness = 2; lt.Range = 6; lt.Color = haloCol; lt.Shadows = false
        table.insert(haloParts, {p=seg, a=ang, l=lt})
    end
    haloConn = RS.RenderStepped:Connect(function()
        if not haloOn then return end
        local cc = P.Character
        local hh = cc and cc:FindFirstChild("Head"); if not hh then return end
        local t = os.clock()
        local tiltX = math.sin(t*1.6)*math.rad(8)
        local tiltZ = math.cos(t*1.3)*math.rad(5.6)
        local bob = math.sin(t*1.8)*0.06
        local spin = t*1.6
        local base = hh.CFrame * CFrame.new(0, 2 + bob, 0) * CFrame.Angles(tiltX, spin, tiltZ)
        for _, s in ipairs(haloParts) do
            if s.p and s.p.Parent then
                s.p.CFrame = base * CFrame.new(math.cos(s.a)*3.5, 0, math.sin(s.a)*3.5)
                s.p.Color = haloCol
                if s.l then s.l.Color = haloCol end
            end
        end
    end)
end
local fHalo = CM.feature(page, "halo", false, function(v)
    haloOn = v
    if v then createHalo() else removeHalo() end
end)
CM.colorRow(fHalo.settings, "color", haloCol, function(c) haloCol = c end)
CM.cfgs["halo"] = {set=function(v) fHalo.setState(v) end, get=function() return fHalo.getState() end}

-- Aura
local auraOn = false
local auraCol = Color3.fromRGB(0,200,255)
local auraAtt, auraEmit
local function removeAura()
    if auraAtt then auraAtt:Destroy() end
    auraAtt, auraEmit = nil, nil
end
local function createAura()
    removeAura()
    local c = P.Character
    local r = c and c:FindFirstChild("HumanoidRootPart"); if not r then return end
    local a = Instance.new("Attachment", r)
    local e = Instance.new("ParticleEmitter", a)
    e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    e.Color = ColorSequence.new(auraCol)
    e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,0.6),NumberSequenceKeypoint.new(1,0)})
    e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.3,0),NumberSequenceKeypoint.new(1,1)})
    e.Lifetime = NumberRange.new(1.5,2.5); e.Rate = 80
    e.Speed = NumberRange.new(2,5); e.SpreadAngle = Vector2.new(180,180)
    e.LightEmission = 1; e.LightInfluence = 0
    e.Acceleration = Vector3.new(0,2,0)
    auraAtt, auraEmit = a, e
end
local fAura = CM.feature(page, "aura", false, function(v)
    auraOn = v; if v then createAura() else removeAura() end
end)
CM.colorRow(fAura.settings, "color", auraCol, function(c)
    auraCol = c; if auraEmit then auraEmit.Color = ColorSequence.new(c) end
end)
CM.cfgs["aura"] = {set=function(v) fAura.setState(v) end, get=function() return fAura.getState() end}

P.CharacterAdded:Connect(function()
    task.wait(0.5)
    if haloOn then createHalo() end
    if auraOn then createAura() end
end)

print("[CM] visuals loaded")
