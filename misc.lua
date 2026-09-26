-- MISC v2.1
local CM = _G.CM
if not CM then warn("[CM] core not loaded"); return end
if _G.CM._miscLoaded then warn("[CM] misc already loaded"); return end
_G.CM._miscLoaded = true
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Debris = game:GetService("Debris")
local P = CM.P
local page = CM.pages["Misc"]

-- Blink
local blinkOn = false
local blinkInt = 0.5
local blinkDur = 0.15
local blinkFrozen = false
local lastBlink = 0
local savedCF = nil

local fBlink = CM.feature(page, "blink", false, function(v) blinkOn = v end)
CM.slider(fBlink.settings, "interval", 10, 200, 50, function(v) blinkInt = v/100 end)
CM.slider(fBlink.settings, "duration", 5, 100, 15, function(v) blinkDur = v/100 end)
CM.cfgs["blink"] = {set=function(v) fBlink.setState(v) end, get=function() return fBlink.getState() end}

RS.Heartbeat:Connect(function()
    if not blinkOn or blinkFrozen then return end
    if os.clock() - lastBlink < blinkInt then return end
    local r = CM.hrp(); if not r then return end
    blinkFrozen = true
    savedCF = r.CFrame
    r.Anchored = true
    task.delay(blinkDur, function()
        if r and r.Parent then
            r.Anchored = false
            if savedCF then r.CFrame = savedCF end
        end
        blinkFrozen = false
        lastBlink = os.clock()
    end)
end)

-- Anti-AFK
local afkConn
local fAFK = CM.feature(page, "antiafk", false, function(v)
    if v then
        afkConn = P.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController(); vu:ClickButton2(Vector2.new())
        end)
    else
        if afkConn then afkConn:Disconnect(); afkConn = nil end
    end
end)
CM.cfgs["antiafk"] = {set=function(v) fAFK.setState(v) end, get=function() return fAFK.getState() end}

-- Anti-Ragdoll
local antiRagConn
local antiRagOn = false
local fAR = CM.feature(page, "antiragdoll", false, function(v)
    antiRagOn = v
    if v then
        local h = CM.hum()
        if h then
            pcall(function()
                h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                h:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            end)
            if antiRagConn then antiRagConn:Disconnect() end
            antiRagConn = h.StateChanged:Connect(function(_, s)
                if not antiRagOn then return end
                if s == Enum.HumanoidStateType.FallingDown
                    or s == Enum.HumanoidStateType.Ragdoll
                    or s == Enum.HumanoidStateType.Physics then
                    pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                end
            end)
        end
    else
        if antiRagConn then antiRagConn:Disconnect(); antiRagConn = nil end
    end
end)
CM.cfgs["antiragdoll"] = {set=function(v) fAR.setState(v) end, get=function() return fAR.getState() end}

-- Fling
local flingOn = false
local lastFling = 0
local function flingOthers()
    local r = CM.hrp(); if not r then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= P and p.Character then
            local op = p.Character:FindFirstChild("HumanoidRootPart")
            if op and (op.Position - r.Position).Magnitude < 12 then
                for _, c in ipairs(op:GetChildren()) do
                    if c.Name == "FlingForce" then c:Destroy() end
                end
                local b = Instance.new("BodyAngularVelocity")
                b.Name = "FlingForce"
                b.AngularVelocity = Vector3.new(999999,999999,999999)
                b.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
                b.Parent = op
                Debris:AddItem(b, 0.2)
            end
        end
    end
end
local fFling = CM.feature(page, "fling", false, function(v) flingOn = v end)
CM.cfgs["fling"] = {set=function(v) fFling.setState(v) end, get=function() return fFling.getState() end}
RS.Heartbeat:Connect(function()
    if not flingOn then return end
    if os.clock() - lastFling < 0.3 then return end
    lastFling = os.clock()
    flingOthers()
end)

-- TP
local fTP = CM.feature(page, "tp", false, function(v) end)
local pl = Instance.new("ScrollingFrame", fTP.settings)
pl.Size = UDim2.new(1,0,0,180); pl.BackgroundColor3 = CM.BG3
pl.BackgroundTransparency = 0.3; pl.BorderSizePixel = 0
pl.ScrollBarThickness = 4; pl.CanvasSize = UDim2.new(0,0,0,0)
pl.AutomaticCanvasSize = Enum.AutomaticSize.Y
local plc = Instance.new("UICorner", pl); plc.CornerRadius = UDim.new(0,6)
local pll = Instance.new("UIListLayout", pl); pll.Padding = UDim.new(0,3)

local function refreshPL()
    for _, c in ipairs(pl:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= P then
            local b = Instance.new("TextButton", pl)
            b.Size = UDim2.new(1,0,0,26); b.BackgroundColor3 = CM.BG2
            b.BackgroundTransparency = 0.2; b.BorderSizePixel = 0
            b.Text = p.Name; b.TextColor3 = CM.TXT
            b.Font = Enum.Font.Gotham; b.TextSize = 12
            local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0,5)
            b.MouseButton1Click:Connect(function()
                local op = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                local myr = CM.hrp()
                if op and myr then myr.CFrame = op.CFrame + Vector3.new(0,3,3) end
            end)
        end
    end
end
refreshPL()
Players.PlayerAdded:Connect(function() task.wait(0.3); refreshPL() end)
Players.PlayerRemoving:Connect(function() task.wait(0.3); refreshPL() end)
CM.btn(fTP.settings, "refresh", refreshPL)

CM.addBind("Blink", fBlink)
CM.addBind("Anti-Ragdoll", fAR)
CM.addBind("Fling", fFling)

print("[CM] misc loaded")
