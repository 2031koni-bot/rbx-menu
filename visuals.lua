-- VISUALS v4
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

print("[CM] visuals v4: START")

-- Drawing detect
local DrawingAPI = nil
pcall(function()
    local g = (getgenv and getgenv()) or _G
    if g.Drawing then DrawingAPI = g.Drawing end
end)
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

-- ========== SKYBOX (обновлено) ==========
local skyboxPresets = {
    {name="Night",     up="rbxassetid://159454299", dn="rbxassetid://159454296", lf="rbxassetid://159454293", rt="rbxassetid://159454286", ft="rbxassetid://159454300", bk="rbxassetid://159454288", amb=Color3.fromRGB(20,20,60), fog=Color3.fromRGB(10,10,40), clock=0},
    {name="Sunset",    up="rbxassetid://271042516", dn="rbxassetid://271042516", lf="rbxassetid://271042516", rt="rbxassetid://271042516", ft="rbxassetid://271042516", bk="rbxassetid://271042516", amb=Color3.fromRGB(255,140,80), fog=Color3.fromRGB(255,120,60), clock=17.5},
    {name="Cyberpunk", up="rbxassetid://5878404912", dn="rbxassetid://5878404912", lf="rbxassetid://5878404912", rt="rbxassetid://5878404912", ft="rbxassetid://5878404912", bk="rbxassetid://5878404912", amb=Color3.fromRGB(255,100,200), fog=Color3.fromRGB(100,50,150), clock=2},
    {name="Matrix",    up="rbxassetid://4844968236", dn="rbxassetid://4844968236", lf="rbxassetid://4844968236", rt="rbxassetid://4844968236", ft="rbxassetid://4844968236", bk="rbxassetid://4844968236", amb=Color3.fromRGB(50,255,100), fog=Color3.fromRGB(0,80,0), clock=3},
    {name="Arctic",    up="rbxassetid://2377909891", dn="rbxassetid://2377909891", lf="rbxassetid://2377909891", rt="rbxassetid://2377909891", ft="rbxassetid://2377909891", bk="rbxassetid://2377909891", amb=Color3.fromRGB(200,230,255), fog=Color3.fromRGB(180,220,255), clock=14},
    {name="Blood",     up="rbxassetid://159454299", dn="rbxassetid://159454296", lf="rbxassetid://159454293", rt="rbxassetid://159454286", ft="rbxassetid://159454300", bk="rbxassetid://159454288", amb=Color3.fromRGB(255,40,40), fog=Color3.fromRGB(100,0,0), clock=0},
    {name="Deep Space",up="rbxassetid://159454296", dn="rbxassetid://159454293", lf="rbxassetid://159454300", rt="rbxassetid://159454288", ft="rbxassetid://159454299", bk="rbxassetid://159454286", amb=Color3.fromRGB(50,50,100), fog=Color3.fromRGB(20,20,60), clock=0},
    {name="Rainbow",   up="rbxassetid://5878404912", dn="rbxassetid://5878404912", lf="rbxassetid://5878404912", rt="rbxassetid://5878404912", ft="rbxassetid://5878404912", bk="rbxassetid://5878404912", amb=Color3.fromRGB(255,255,255), fog=Color3.fromRGB(255,255,255), clock=12},
}
local currentSkybox = nil
local skyEffects = {}

local function removeSkybox()
    if currentSkybox then
        pcall(function() currentSkybox:Destroy() end)
        currentSkybox = nil
    end
    for _, e in ipairs(skyEffects) do
        pcall(function() e:Destroy() end)
    end
    skyEffects = {}
    -- Убираем атмосферу
    for _, child in ipairs(LT:GetChildren()) do
        if child.Name == "CM_SkyEffect" then
            pcall(function() child:Destroy() end)
        end
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

        LT.Ambient = preset.amb
        LT.OutdoorAmbient = preset.amb
        LT.FogColor = preset.fog
        LT.ClockTime = preset.clock
        LT.Brightness = 2

        -- Bloom для свечения
        local bloom = Instance.new("BloomEffect", LT)
        bloom.Name = "CM_SkyEffect"
        bloom.Intensity = 0.8
        bloom.Size = 24
        bloom.Threshold = 1.5
        table.insert(skyEffects, bloom)

        -- ColorCorrection для насыщенности
        local cc = Instance.new("ColorCorrectionEffect", LT)
        cc.Name = "CM_SkyEffect"
        cc.Saturation = 0.3
        cc.Contrast = 0.15
        cc.Brightness = 0.02
        cc.TintColor = Color3.fromRGB(255,255,255)
        table.insert(skyEffects, cc)

        -- Sun Rays
        local sr = Instance.new("SunRaysEffect", LT)
        sr.Name = "CM_SkyEffect"
        sr.Intensity = 0.05
        sr.Spread = 1
        table.insert(skyEffects, sr)
    end)
end

local fSky = CM.feature(page, "skybox", false, function(v)
    if v then applySkybox(skyboxPresets[1]) else removeSkybox() end
end)

-- Красивая сетка пресетов (2 ряда по 4)
local skyGrid = Instance.new("Frame", fSky.settings)
skyGrid.Size = UDim2.new(1, 0, 0, 74)
skyGrid.BackgroundTransparency = 1
local skyGridLay = Instance.new("UIGridLayout", skyGrid)
skyGridLay.CellSize = UDim2.new(0, 78, 0, 32)
skyGridLay.CellPadding = UDim2.new(0, 4, 0, 4)
skyGridLay.SortOrder = Enum.SortOrder.LayoutOrder

for i, preset in ipairs(skyboxPresets) do
    local b = Instance.new("TextButton", skyGrid)
    b.BackgroundColor3 = (i == 1) and CM.AC or CM.BG3
    b.BorderSizePixel = 0
    b.Text = preset.name
    b.TextColor3 = CM.TXT
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 10
    b.LayoutOrder = i
    local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function()
        applySkybox(preset)
        for _, child in ipairs(skyGrid:GetChildren()) do
            if child:IsA("TextButton") then child.BackgroundColor3 = CM.BG3 end
        end
        b.BackgroundColor3 = CM.AC
    end)
end
CM.cfgs["skybox"] = {set=function(v) fSky.setState(v) end, get=function() return fSky.getState() end}

-- ========== ESP с опцией Show Name ==========
local espFill = Color3.fromRGB(0,170,255)
local espOut = Color3.fromRGB(255,255,255)
local espFT = 0.4
local espOn, espTeam = false, true
local espShowName = true
local espNameColor = Color3.fromRGB(255, 255, 255)
local espHL, espBG = {}, {}

local function clearESP(p)
    if espHL[p] then pcall(function() espHL[p]:Destroy() end); espHL[p] = nil end
    if espBG[p] then pcall(function() espBG[p]:Destroy() end); espBG[p] = nil end
end

local function makeESP(p)
    if not espOn or p == P then return end
    if espTeam and p.Team and P.Team and p.Team == P.Team then clearESP(p); return end
    local c = p.Character; if not c then return end
    clearESP(p)

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.FillColor = espFill; hl.OutlineColor = espOut
    hl.FillTransparency = espFT; hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = c; hl.Parent = c
    espHL[p] = hl

    -- Name tag (если Show Name включен)
    if espShowName then
        local head = c:FindFirstChild("Head")
        if head then
            local bg = Instance.new("BillboardGui")
            bg.Name = "CM_ESP_Name"
            bg.Size = UDim2.new(0, 200, 0, 30)
            bg.StudsOffset = Vector3.new(0, 2.5, 0)
            bg.AlwaysOnTop = true
            bg.Parent = head

            local txt = Instance.new("TextLabel", bg)
            txt.Name = "Text"
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = p.Name
            txt.TextColor3 = espNameColor
            txt.TextStrokeTransparency = 0
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 14
            espBG[p] = bg
        end
    end
end

local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= P then
            if espOn then makeESP(p) else clearESP(p) end
        end
    end
end

-- Обновление цвета ника в реальном времени
RS.RenderStepped:Connect(function()
    if not espShowName then return end
    for _, bg in pairs(espBG) do
        if bg and bg.Parent then
            local txt = bg:FindFirstChild("Text")
            if txt then txt.TextColor3 = espNameColor end
        end
    end
end)

local fESP = CM.feature(page, "esp", false, function(v) espOn = v; refreshESP() end)
CM.colorRow(fESP.settings, "fill", espFill, function(c) espFill = c; refreshESP() end)
CM.colorRow(fESP.settings, "outline", espOut, function(c) espOut = c; refreshESP() end)
CM.slider(fESP.settings, "espft", 0, 100, 40, function(v) espFT = v/100; refreshESP() end)
CM.toggle(fESP.settings, "showname", true, function(v)
    espShowName = v
    refreshESP()
end)
CM.colorRow(fESP.settings, "namecolor", espNameColor, function(c)
    espNameColor = c
    for _, bg in pairs(espBG) do
        if bg and bg.Parent then
            local txt = bg:FindFirstChild("Text")
            if txt then txt.TextColor3 = c end
        end
    end
end)
CM.cfgs["esp"] = {set=function(v) fESP.setState(v) end, get=function() return fESP.getState() end}

-- ========== SKELETON ESP (оставил, полезно) ==========
local fSkel
if DrawingAPI then
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

-- Player events
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

CM.addBind("ESP", fESP)
CM.addBind("Skybox", fSky)
CM.addBind("FreeLook", fFL)
CM.addBind("Halo", fHalo)
CM.addBind("Aura", fAura)
CM.addBind("Sparkles", fSp)
if fSkel then CM.addBind("Skeleton", fSkel) end

print("[CM] visuals v4: DONE")
