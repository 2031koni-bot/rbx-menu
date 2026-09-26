-- VISUALS v3.3 FULL
local CM = _G.CM
if not CM then warn("[CM] core not loaded"); return end
if _G.CM._visualsLoaded then warn("[CM] visuals already loaded"); return end
_G.CM._visualsLoaded = true

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LT = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local P = CM.P
local cam = CM.cam
local page = CM.pages["Visuals"]

print("[CM] visuals: START")

-- ========== DRAWING DETECT ==========
local DrawingAPI = nil
pcall(function()
    local g = (getgenv and getgenv()) or _G
    if g.Drawing then DrawingAPI = g.Drawing end
end)
if not DrawingAPI then
    pcall(function()
        if Drawing then DrawingAPI = Drawing end
    end)
end
print("[CM] Drawing:", DrawingAPI and "YES" or "NO")

-- ========== FOV ==========
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

-- ========== FULLBRIGHT ==========
local fFB = CM.feature(page, "fullbright", false, function(v)
    if v then
        LT.Brightness = 3; LT.ClockTime = 12
        LT.FogEnd = 100000; LT.GlobalShadows = false
    else
        LT.Brightness = 1; LT.FogEnd = 100000; LT.GlobalShadows = true
    end
end)
CM.cfgs["fullbright"] = {set=function(v) fFB.setState(v) end, get=function() return fFB.getState() end}

-- ========== SKYBOX ==========
local skyboxPresets = {
    {name="Night",  up="rbxassetid://159454299", dn="rbxassetid://159454296", lf="rbxassetid://159454293", rt="rbxassetid://159454286", ft="rbxassetid://159454300", bk="rbxassetid://159454288"},
    {name="Space",  up="rbxassetid://159454296", dn="rbxassetid://159454293", lf="rbxassetid://159454300", rt="rbxassetid://159454288", ft="rbxassetid://159454299", bk="rbxassetid://159454286"},
    {name="Dark",   up="rbxassetid://107093",    dn="rbxassetid://107093",    lf="rbxassetid://107093",    rt="rbxassetid://107093",    ft="rbxassetid://107093",    bk="rbxassetid://107093"},
}
local currentSkybox = nil

local function removeSkybox()
    if currentSkybox then
        pcall(function() currentSkybox:Destroy() end)
        currentSkybox = nil
    end
end
local function applySkybox(preset)
    removeSkybox()
    pcall(function()
        local sky = Instance.new("Sky", LT)
        sky.Name = "CM_Sky"
        sky.SkyboxUp = preset.up; sky.SkyboxDn = preset.dn
        sky.SkyboxLf = preset.lf; sky.SkyboxRt = preset.rt
        sky.SkyboxFt = preset.ft; sky.SkyboxBk = preset.bk
        currentSkybox = sky
    end)
end

local fSky = CM.feature(page, "skybox", false, function(v)
    if v then applySkybox(skyboxPresets[1]) else removeSkybox() end
end)

local skyRow = Instance.new("Frame", fSky.settings)
skyRow.Size = UDim2.new(1, 0, 0, 32)
skyRow.BackgroundColor3 = CM.BG2
skyRow.BackgroundTransparency = CM.bgT
skyRow.BorderSizePixel = 0
local skyrc = Instance.new("UICorner", skyRow); skyrc.CornerRadius = UDim.new(0, 6)
local skyBox = Instance.new("Frame", skyRow)
skyBox.Size = UDim2.new(1, -12, 1, -6)
skyBox.Position = UDim2.new(0, 6, 0, 3)
skyBox.BackgroundTransparency = 1
local skyLay = Instance.new("UIListLayout", skyBox)
skyLay.FillDirection = Enum.FillDirection.Horizontal
skyLay.Padding = UDim.new(0, 3)

for i, preset in ipairs(skyboxPresets) do
    local b = Instance.new("TextButton", skyBox)
    b.Size = UDim2.new(0, 100, 1, 0)
    b.BackgroundColor3 = (i == 1) and CM.AC or CM.BG3
    b.BorderSizePixel = 0
    b.Text = preset.name
    b.TextColor3 = CM.TXT
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        applySkybox(preset)
        for _, child in ipairs(skyBox:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = CM.BG3 end
        end
        b.BackgroundColor3 = CM.AC
    end)
end
CM.cfgs["skybox"] = {set=function(v) fSky.setState(v) end, get=function() return fSky.getState() end}

-- ========== ESP (Highlight) ==========
local espFill = Color3.fromRGB(0,170,255)
local espOut = Color3.fromRGB(255,255,255)
local espFT = 0.4
local espOn, espTeam = false, true
local espHL = {}

local function clearESP(p)
    if espHL[p] then pcall(function() espHL[p]:Destroy() end); espHL[p] = nil end
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
CM.colorRow(fESP.settings, "fill", espFill, function(c) espFill = c; refreshESP() end)
CM.colorRow(fESP.settings, "outline", espOut, function(c) espOut = c; refreshESP() end)
CM.slider(fESP.settings, "espft", 0, 100, 40, function(v) espFT = v/100; refreshESP() end)
CM.cfgs["esp"] = {set=function(v) fESP.setState(v) end, get=function() return fESP.getState() end}

-- ========== PLAYER INFO ==========
local playerInfoOn = false
local playerInfoColor = Color3.fromRGB(255, 255, 255)
local playerInfoShowDist = true
local playerInfoShowHP = true

local fInfo = CM.feature(page, "player info", false, function(v)
    playerInfoOn = v
    if not v then
        for _, plr in ipairs(Players:GetPlayers()) do
            local c = plr.Character
            if c then
                local head = c:FindFirstChild("Head")
                if head then
                    local info = head:FindFirstChild("CM_Info")
                    if info then info:Destroy() end
                end
            end
        end
    end
end)
CM.colorRow(fInfo.settings, "color", playerInfoColor, function(c) playerInfoColor = c end)
CM.toggle(fInfo.settings, "distance", true, function(v) playerInfoShowDist = v end)
CM.toggle(fInfo.settings, "health", true, function(v) playerInfoShowHP = v end)
CM.cfgs["playerinfo"] = {set=function(v) fInfo.setState(v) end, get=function() return fInfo.getState() end}

local function updateInfoForPlayer(plr)
    if plr == P then return end
    local c = plr.Character
    if not c then return end
    local head = c:FindFirstChild("Head")
    if not head then return end

    local bg = head:FindFirstChild("CM_Info")
    if not bg then
        bg = Instance.new("BillboardGui")
        bg.Name = "CM_Info"
        bg.Size = UDim2.new(0, 220, 0, 30)
        bg.StudsOffset = Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true
        bg.Parent = head
        local txt = Instance.new("TextLabel", bg)
        txt.Name = "Text"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 13
    end

    local txt = bg:FindFirstChild("Text")
    local myR = CM.hrp()
    local dist = myR and math.floor((head.Position - myR.Position).Magnitude) or 0
    local h = c:FindFirstChildOfClass("Humanoid")
    local hp = h and math.floor(h.Health) or 0
    local parts = { plr.Name }
    if playerInfoShowDist then table.insert(parts, "["..dist.."m]") end
    if playerInfoShowHP then table.insert(parts, "HP:"..hp) end
    txt.Text = table.concat(parts, " ")
    txt.TextColor3 = playerInfoColor
end

RS.RenderStepped:Connect(function()
    if not playerInfoOn then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= P then
            pcall(updateInfoForPlayer, plr)
        end
    end
end)

-- ========== ESP BOX / TRACERS / SKELETON ==========
local fBox, fTracer, fSkel

if DrawingAPI then
    -- ESP BOX
    local espBoxOn = false
    local espBoxColor = Color3.fromRGB(255, 60, 60)
    local espBoxThick = 1.5
    local boxDrawings = {}

    fBox = CM.feature(page, "esp box", false, function(v)
        espBoxOn = v
        if not v then
            for _, d in pairs(boxDrawings) do
                for _, line in pairs(d) do pcall(function() line:Remove() end) end
            end
            boxDrawings = {}
        end
    end)
    CM.colorRow(fBox.settings, "color", espBoxColor, function(c) espBoxColor = c end)
    CM.slider(fBox.settings, "thickness", 1, 5, 2, function(v) espBoxThick = v end)
    CM.cfgs["espbox"] = {set=function(v) fBox.setState(v) end, get=function() return fBox.getState() end}

    RS.RenderStepped:Connect(function()
        if not espBoxOn then return end
        pcall(function()
            for plr, d in pairs(boxDrawings) do
                if not plr.Parent or not plr.Character then
                    for _, line in pairs(d) do pcall(function() line:Remove() end) end
                    boxDrawings[plr] = nil
                end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= P and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local h = plr.Character:FindFirstChildOfClass("Humanoid")
                    if head and hrp and h and h.Health > 0 then
                        local topScreen, topOn = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                        local botScreen, botOn = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        if topOn and botOn then
                            local height = math.abs(topScreen.Y - botScreen.Y)
                            local width = height * 0.55
                            local x = topScreen.X - width/2
                            local y = topScreen.Y
                            if not boxDrawings[plr] then
                                boxDrawings[plr] = {
                                    top = DrawingAPI.new("Line"),
                                    bottom = DrawingAPI.new("Line"),
                                    left = DrawingAPI.new("Line"),
                                    right = DrawingAPI.new("Line"),
                                }
                            end
                            local d = boxDrawings[plr]
                            d.top.From = Vector2.new(x, y); d.top.To = Vector2.new(x + width, y)
                            d.bottom.From = Vector2.new(x, y + height); d.bottom.To = Vector2.new(x + width, y + height)
                            d.left.From = Vector2.new(x, y); d.left.To = Vector2.new(x, y + height)
                            d.right.From = Vector2.new(x + width, y); d.right.To = Vector2.new(x + width, y + height)
                            for _, l in pairs(d) do
                                l.Visible = true
                                l.Color = espBoxColor
                                l.Thickness = espBoxThick
                            end
                        end
                    end
                end
            end
        end)
    end)

    -- TRACERS
    local tracersOn = false
    local tracerColor = Color3.fromRGB(0, 255, 100)
    local tracerThick = 1
    local tracers = {}

    fTracer = CM.feature(page, "tracers", false, function(v)
        tracersOn = v
        if not v then
            for _, l in pairs(tracers) do pcall(function() l:Remove() end) end
            tracers = {}
        end
    end)
    CM.colorRow(fTracer.settings, "color", tracerColor, function(c) tracerColor = c end)
    CM.slider(fTracer.settings, "thickness", 1, 5, 1, function(v) tracerThick = v end)
    CM.cfgs["tracers"] = {set=function(v) fTracer.setState(v) end, get=function() return fTracer.getState() end}

    RS.RenderStepped:Connect(function()
        if not tracersOn then return end
        pcall(function()
            for plr, l in pairs(tracers) do
                if not plr.Parent or not plr.Character then
                    pcall(function() l:Remove() end)
                    tracers[plr] = nil
                end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= P and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local h = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and h and h.Health > 0 then
                        local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            if not tracers[plr] then
                                tracers[plr] = DrawingAPI.new("Line")
                            end
                            local l = tracers[plr]
                            l.Visible = true
                            local viewport = cam.ViewportSize
                            l.From = Vector2.new(viewport.X / 2, viewport.Y)
                            l.To = Vector2.new(pos.X, pos.Y)
                            l.Color = tracerColor
                            l.Thickness = tracerThick
                        end
                    end
                end
            end
        end)
    end)

    -- SKELETON
    local skelOn = false
    local skelColor = Color3.fromRGB(255, 255, 255)
    local skelThick = 1.5
    local skelDrawings = {}
    local bonePairs = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
        {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    }

    fSkel = CM.feature(page, "skeleton esp", false, function(v)
        skelOn = v
        if not v then
            for _, lines in pairs(skelDrawings) do
                for _, l in pairs(lines) do pcall(function() l:Remove() end) end
            end
            skelDrawings = {}
        end
    end)
    CM.colorRow(fSkel.settings, "color", skelColor, function(c) skelColor = c end)
    CM.slider(fSkel.settings, "thickness", 1, 5, 2, function(v) skelThick = v end)
    CM.cfgs["skeleton"] = {set=function(v) fSkel.setState(v) end, get=function() return fSkel.getState() end}

    RS.RenderStepped:Connect(function()
        if not skelOn then return end
        pcall(function()
            for plr, lines in pairs(skelDrawings) do
                if not plr.Parent or not plr.Character then
                    for _, l in pairs(lines) do pcall(function() l:Remove() end) end
                    skelDrawings[plr] = nil
                end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= P and plr.Character then
                    local char = plr.Character
                    local h = char:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        if not skelDrawings[plr] then
                            skelDrawings[plr] = {}
                            for i = 1, #bonePairs do
                                skelDrawings[plr][i] = DrawingAPI.new("Line")
                            end
                        end
                        for i, pair in ipairs(bonePairs) do
                            local p1 = char:FindFirstChild(pair[1])
                            local p2 = char:FindFirstChild(pair[2])
                            local line = skelDrawings[plr][i]
                            if p1 and p2 then
                                local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                                local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then
                                    line.Visible = true
                                    line.From = Vector2.new(s1.X, s1.Y)
                                    line.To = Vector2.new(s2.X, s2.Y)
                                    line.Color = skelColor
                                    line.Thickness = skelThick
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    end
                end
            end
        end)
    end)
else
    warn("[CM] Drawing API не поддерживается — ESP Box, Tracers, Skeleton отключены")
end

-- ========== FREELOOK ==========
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

-- ========== HALO ==========
local haloOn = false
local haloCol = Color3.fromRGB(255,255,255)
local haloModel, haloConn, haloParts = nil, nil, {}
local function removeHalo()
    if haloConn then haloConn:Disconnect(); haloConn = nil end
    if haloModel then pcall(function() haloModel:Destroy() end); haloModel = nil end
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

-- ========== AURA ==========
local auraOn = false
local auraCol = Color3.fromRGB(0,200,255)
local auraAtt, auraEmit
local function removeAura()
    if auraAtt then pcall(function() auraAtt:Destroy() end) end
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

-- ========== SPARKLES ==========
local spOn = false
local spCol = Color3.fromRGB(255,255,180)
local spAtt, spEmit
local function removeSp()
    if spAtt then pcall(function() spAtt:Destroy() end) end
    spAtt, spEmit = nil, nil
end
local function createSp()
    removeSp()
    local c = P.Character
    local h = c and c:FindFirstChild("Head"); if not h then return end
    local a = Instance.new("Attachment", h); a.Position = Vector3.new(0, 3, 0)
    local e = Instance.new("ParticleEmitter", a)
    e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    e.Color = ColorSequence.new(spCol)
    e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,0.5),NumberSequenceKeypoint.new(1,0)})
    e.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.4,0.2),NumberSequenceKeypoint.new(1,1)})
    e.Lifetime = NumberRange.new(0.8,1.5); e.Rate = 40
    e.Speed = NumberRange.new(0.5,2); e.SpreadAngle = Vector2.new(360,360)
    e.LightEmission = 1; e.LightInfluence = 0
    spAtt, spEmit = a, e
end
local fSp = CM.feature(page, "sparkles", false, function(v)
    spOn = v; if v then createSp() else removeSp() end
end)
CM.colorRow(fSp.settings, "color", spCol, function(c)
    spCol = c; if spEmit then spEmit.Color = ColorSequence.new(c) end
end)
CM.cfgs["sparkles"] = {set=function(v) fSp.setState(v) end, get=function() return fSp.getState() end}

-- ========== PLAYER EVENTS ==========
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

P.CharacterAdded:Connect(function()
    task.wait(0.5)
    if haloOn then createHalo() end
    if auraOn then createAura() end
    if spOn then createSp() end
end)

-- ========== BINDS ==========
CM.addBind("ESP", fESP)
CM.addBind("Player Info", fInfo)
CM.addBind("Skybox", fSky)
CM.addBind("FreeLook", fFL)
CM.addBind("Halo", fHalo)
CM.addBind("Aura", fAura)
CM.addBind("Sparkles", fSp)
if fBox then CM.addBind("ESP Box", fBox) end
if fTracer then CM.addBind("Tracers", fTracer) end
if fSkel then CM.addBind("Skeleton", fSkel) end

print("[CM] visuals: DONE")
